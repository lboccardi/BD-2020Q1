drop table if exists YEAR,QUARTER,MONTH,DATEDETAIL,EVENT,EVENT_AUX;

set datestyle to dmy;

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
	monthdesc varchar(20) check (monthdesc in ('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre')),
	quarterfk integer not null,
	primary key(id),
	unique(monthid, quarterfk),
	foreign key (quarterfk) references quarter
);

create or replace function fillMonth (monthNum Integer, quarterId integer)
returns Integer as $$
 declare
	 monthDesc varchar(20);
     monthID integer;
 begin
	 monthDesc := GetMonthDescription(monthNum);
     insert into month(monthid,monthdesc,quarterfk) values (monthNum, monthDesc, quarterId);
	 
	 select id into monthID from month where month.monthid = monthNum and month.quarterfk = quarterId;
	 
	 if monthID is null then
	 	raise exception 'Month wasnt inserted';
	 end if;
	 
	 return monthID;
	 
 end;
     $$ language plpgsql;

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

create or replace function FillDateDetails (date date, monthId integer)
returns integer as $$
 declare
 	dayNum integer;
	dow varchar(20);
	isWeekend boolean:= false;
	dateId integer;
 begin
	 dayNum := extract (day from date);
	 dow := extract(dow from date);
	 if dow = 0 or dow = 6 then
	 	isWeekend:= true;
	end if;
	
	insert into datedetail(day,dayofweek,weekend,monthfk) values (dayNum, dow,isWeekend, monthId);
	 
	select id into dateId from datedetail where dayNum = datedetail.day and monthId = datedetail.monthfk;
	
	return dateId;
 end;
     $$ language plpgsql;

create table EVENT (
	Declaration_Number varchar(20) check (Declaration_Number like 'DR-_%'),
	Declaration_Type varchar(30) check (Declaration_Type in ('Disaster', 'Fire', 'Emergency')),
	Declaration_Date integer not null,
	State varchar(2) check( State in ('AK','AL','AR','AZ','CA','CO','CT','DC','DE','FL','GA','HI','IA','ID','IL','IN','KS','KY','LA','MA','MD','ME','MI','MN','MS','MO','MT','NC','NE','NH','NJ','NM','NV','NY','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY')),
	Disaster_Type varchar(20) check( Disaster_Type in ('Tornado','Flood','Fire','Other','Earthquake','Hurricane','Volcano','Storm','Chemical','Typhoon','Drought','Dam/Levee Break','Snow','Ice','Winter','Mud/Landslide','Human Cause','Terrorism','Tsunami','Water')),
	primary key (Declaration_Number),
	foreign key (Declaration_Date) references DATEDETAIL
);

create table EVENT_AUX (
	Declaration_Number varchar(20) check (Declaration_Number like 'DR-_%'),
	Declaration_Type varchar(30) check (Declaration_Type in ('Disaster', 'Fire', 'Emergency')),
	Declaration_Date date not null,
	State varchar(2) check( State in ('AK','AL','AR','AZ','CA','CO','CT','DC','DE','FL','GA','HI','IA','ID','IL','IN','KS','KY','LA','MA','MD','ME','MI','MN','MS','MO','MT','NC','NE','NH','NJ','NM','NV','NY','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY')),
	Disaster_Type varchar(20) check( Disaster_Type in ('Tornado','Flood','Fire','Other','Earthquake','Hurricane','Volcano','Storm','Chemical','Typhoon','Drought','Dam/Levee Break','Snow','Ice','Winter','Mud/Landslide','Human Cause','Terrorism','Tsunami','Water')),
	primary key (Declaration_Number)
);

create or replace function get_weekday (IN weekday integer)
returns varchar as $$
    begin
        case weekday
        when 0 then return 'domingo';
        when 1 then return 'lunes';
        when 2 then return 'martes';
        when 3 then return 'miercoles';
        when 4 then return 'jueves';
        when 5 then return 'viernes';
        when 6 then return 'sabado';
        else raise exception 'error number';
        end case;
end;
$$ language plpgsql;

create or replace function checkLeapYear( year int ) 
returns boolean as $$
    begin
    	return (year % 4 = 0) AND ((year % 100 <> 0) or (year % 400 = 0));
    end;
$$ language plpgsql;

create or replace function fillYear ( date Date )
returns void as $$
 	declare
    	year int := 0;
    	is_leap bool := 0;
 	begin
    	year := extract (year from date);
    	is_leap := checkLeapYear(year);
     	insert into year values (year, is_leap);
 	end;
$$ language plpgsql;

create or replace function fillQuarter ( quarter_num integer, year integer)
returns integer as $$
	declare
		ret integer;
	begin
		insert into quarter(quarternumber,yearfk) values (quarter_num, year);
		select id into ret from quarter where quarternumber = quarter_num and yearfk = year;
		return ret;
	end;
$$ language plpgsql;
		 
	
	 

CREATE OR REPLACE FUNCTION GetMonthDescription(month integer)
RETURNS varchar AS
$$	
	BEGIN
		case month
			when 1 then return'Enero';
			when 2 then return'Febrero';
			when 3 then return'Marzo';
			when 4 then return'Abril';
			when 5 then return'Mayo';
			when 6 then return'Junio';
			when 7 then return'Julio';
			when 8 then return'Agosto';
			when 9 then return'Septiembre';
			when 10 then return'Octubre';
			when 11 then return'Noviembre';
			when 12 then return'Diciembre';
			else raise exception 'Invalid Month';
			end case;
	END;
$$ LANGUAGE plpgsql;
 
DO $$
  	DECLARE
  		d1 integer:= 0;
  		d2 integer:= 2;
  		d3 integer:= 3;
  	begin
      	raise notice '%',get_weekday(d1);
      	raise notice '%',get_weekday(d2);
     	raise notice '%',get_weekday(d3);
  	end;
$$;

DO $$
 	DECLARE
		mes integer :=12;
		aa varchar(20);
	BEGIN
		aa := GetMonthDescription(mes);		
		raise notice '%', aa;
	END;
 $$;







create or replace FUNCTION checking()
RETURNS Trigger
AS $$
	DECLARE
		date date = new.Declaration_Date;
	    month integer = extract(month from date);
		vyear integer = extract(year from date);
		vday integer = extract(day from date);
		quarter integer = (month/4) + 1;
		quarterId integer = -1;
		monthId integer = -1;
		dateDetail integer = -1;
	BEGIN
		if not exists (select t1.year from YEAR as t1 where t1.year = vyear) then
			execute fillYear(date);
		end if;
		select t1.id into quarterId from QUARTER as t1 where t1.quarternumber=quarter;
		if  quarterId is null then
			quarterId := fillQuarter(quarter,vyear);
		end if;
		select t1.id into monthId from MONTH as t1 where t1.monthid=month;
		if  monthId is null then
			monthid := fillMonth(month,quarterId);
		end if;
		select t1.id into dateDetail from DATEDETAIL as t1 where t1.day=vday and t1.monthfk=monthId;
		if  dateDetail is null then
			dateDetail := FillDateDetails(date,monthId);
		end if;
		raise notice 'hola';
		new.Declaration_Date := dateDetail;
        raise notice '%',new.Declaration_Date;
		insert into EVENT values (new.Declaration_Number,new.Declaration_Type,new.Declaration_Date,new.State,new.Disaster_Type);
        return new;
	END;
$$ LANGUAGE plpgsql;

create trigger fill_data
before insert on EVENT_AUX
for each row
execute procedure checking();

copy EVENT_AUX from 'C:\temp\fed_emergency_disaster.csv' delimiter ',' csv header;
