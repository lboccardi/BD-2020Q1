
create table YEAR (
	year integer not null check (year < 2500),
	isleap boolean default false,
	primary key(year)
);

create table QUARTER (
	id serial not null,
	quarternumber integer not null check(quarternumber between 1 and 4),
	yearfk integer not null, 
	primary key(id), 
	unique(quarternumber, yearfk), 
	foreign key(yearfk) references year
);


create table MONTH (
	id serial not null,
	monthid integer not null check (monthid between 1 and 12),
	monthdesc varchar(20) check (monthdesc in ('enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre')),
	quarterfk integer not null,
	primary key(id),
	unique(monthid, quarterfk),
	foreign key (quarterfk) references quarter
);


create table DATEDETAIL (
	id serial not null, 
	day integer not null check (day between 1 and 31),
	dayofweek varchar(20) check (dayofweek in ('lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo')),
	weekend boolean default false, 
	monthfk integer not null,
	primary key(id), 
	unique(day, monthfk), 
	foreign key(monthfk) references month
);



