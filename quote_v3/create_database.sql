create table quotes (
	id serial not null primary key,
	quote text not null,
	time_added timestamp with time zone default now(),
	realuser text,
	unique (quote),
);
create table quote_votes (
	id serial not null primary key,
	realuser text not null,
	quote_id int not null,
	vote int,
	unique (realuser, quote_id),
	foreign key (quote_id) references quotes (id)
);
