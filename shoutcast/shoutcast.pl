#!/usr/bin/php4 -q
<?
	$timeout=5;
	$url=$argv[1];

	ereg("^((.*)://)?([^:\/]+):?([0-9]+)?(.*)$", $url, $match);
	list(,,$proto,$host,$port,$file) = $match;
	if(!$proto) {
		$proto="http";
	}
	if(!$port) {
		switch($proto) {
			case "http":
				$port=80;
				break;
			case "ftp":
				$port=21;
				break;
			default:
				$port=80;
				break;
		}
	}
	if(!$file) {
		$file="/";
	}
	if(!$host) {
		echo "supply valid arguments\n";
		exit;
	}
	$fd=fsockopen($host, $port, $errno, $errstr, 30);
	if(!$fd) {
		echo "could not connect to $host:$port\n";
		exit;
	}

	$request ="GET $file HTTP/1.0\r\n";
	$request.="Host: $host\r\n";
	$request.="User-Agent: WinampMPEG/2.8\r\n";
	$request.="Accept: */*\r\n";
	$request.="Icy-MetaData:1\r\n";
	$request.="Connection: close\r\n";
	$request.="\r\n";
	fputs($fd, $request);

	while(!feof($fd)) {
		$line=fgets($fd,4096);
		$line=preg_replace("/\r?\n$|\r[^\n]$/", "", $line);
		if(!$line) {
			$stop=1;
			break;
		}

		if(ereg("^icy-metaint: *(.*)$", $line, $regs)) {
			$metaint=$regs[1];
		}
		if(ereg("^icy-br: *(.*)$", $line, $regs)) {
			$rate=$regs[1];
		}

		if(ereg("^icy-(.*): *(.*)$", $line, $regs)) {
#			echo $regs[1]." = ".$regs[2]."\n";
		}
	}

	if(!$metaint) {
		echo "No metadata in that stream\n";
		exit;
	}

	$begin=time();
	
	while(!feof($fd)) {
		if( (time()-$begin) >= $timeout) {
			echo "timeout\n";
			exit;
		}
		$mp3data=fread($fd, $metaint);
		$metalength=ord(fread($fd, 1));
		if($metalength) {
			$metadata=fread($fd, $metalength*16);
#			echo "len: $metalength data='$metadata'\n";
			break;
		}
	}
	fclose($fd);

	$meta=explode(";", $metadata);
	foreach($meta as $data) {
		$v=explode("=", $data);
		$var=$v[0];
		$val=ereg_replace("^'(.*)'$", "\\1", $v[1]);
		if($var=="StreamTitle") {
			echo "$val\n";
		}
	}

?>
