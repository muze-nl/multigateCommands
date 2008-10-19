package config;

use strict;
require Exporter;
our @ISA = qw/ Exporter /;

our @EXPORT = qw/ %channels /;

our %channels = ( # tvinfo.nl name, multilink !tv name
		1	=> ['Nederland 1',		'Nederland1'],
		2	=> ['Nederland 2',		'Nederland2'],
		3	=> ['Nederland 3',		'Nederland3'],
		4	=> ["RTL 4",			'RTL4'],
		5	=> ["Eén",				'VRT_TV1'],
		6	=> ["KETNET/Canvas",	'Ketnet_Canvas'],
		7	=> ["BBC 1",			'BBC1'],
		8	=> ["BBC 2",			'BBC2'],
#		9	=> ["ARD"],
#		10	=> ["ZDF"],
#		11	=> ["RTLTelevision"],
#		12	=> ["WDR"],
#		13	=> ["N3"],
#		14	=> ["Sudwest3"],
#		15	=> ["La_Une"],
#		16	=> ["La_Deux"],
#		17	=> ["TV_5"],
#		18	=> ["NGC"],
#		19	=> ["Eurosport"],
#		20	=> ["TCM"],
#		21	=> ["CartoonNetwork"],
#		22	=> ["Kindernet"],
#		24	=> ["Canal+1"],
#		25	=> ["MTV"],
#		26	=> ["CNN"],
#		27	=> ["RAIUNO"],
#		28	=> ["Sat1"],
		29	=> ["Discovery Channel",'Discovery'],
		31	=> ["RTL 5",			'RTL5'],
#		32	=> ["TRTInt"],
		34	=> ["Veronica",			'Veronica'],
#		35	=> ["TMF"
		36	=> ["SBS 6",			'SBS6'],
		37	=> ["NET 5",			'Net5'],
#		39	=> ["Canal+2"],
#		40	=> ["AT5"],
		46	=> ["RTL 7",			'RTL7'],
#		49	=> ["VTM"],
#		50	=> ["3sat"],
#		58	=> ["Pro7"],
#		59	=> ["Kanaal2"],
#		60	=> ["VT4"],
#		65	=> ["Animal"],
#		86	=> ["BBCworld"],
#		87	=> ["TVE"],
#		89	=> ["Nickelodeon"],
#		90	=> ["BVN-TV"],
        92	=> ["RTL 8",			'RTL8'],
	);

1;
