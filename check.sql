-- COMP9311 22T1 Project Check
--
-- MyMyUNSW Check

create or replace function
	proj1_table_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='r';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_view_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='v';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_function_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_proc
	where proname=tname;
	return (_check > 0);
end;
$$ language plpgsql;

-- proj1_check_result:
-- * determines appropriate message, based on count of
--   excess and missing tuples in user output vs expected output

create or replace function
	proj1_check_result(nexcess integer, nmissing integer) returns text
as $$
begin
	if (nexcess = 0 and nmissing = 0) then
		return 'correct';
	elsif (nexcess > 0 and nmissing = 0) then
		return 'too many result tuples';
	elsif (nexcess = 0 and nmissing > 0) then
		return 'missing result tuples';
	elsif (nexcess > 0 and nmissing > 0) then
		return 'incorrect result tuples';
	end if;
end;
$$ language plpgsql;

-- proj1_check:
-- * compares output of user view/function against expected output
-- * returns string (text message) containing analysis of results

create or replace function
	proj1_check(_type text, _name text, _res text, _query text) returns text
as $$
declare
	nexcess integer;
	nmissing integer;
	excessQ text;
	missingQ text;
begin
	if (_type = 'view' and not proj1_view_exists(_name)) then
		return 'No '||_name||' view; did it load correctly?';
	elsif (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (not proj1_table_exists(_res)) then
		return _res||': No expected results!';
	else
		excessQ := 'select count(*) '||
				 'from (('||_query||') except '||
				 '(select * from '||_res||')) as X';
		-- raise notice 'Q: %',excessQ;
		execute excessQ into nexcess;
		missingQ := 'select count(*) '||
					'from ((select * from '||_res||') '||
					'except ('||_query||')) as X';
		-- raise notice 'Q: %',missingQ;
		execute missingQ into nmissing;
		return proj1_check_result(nexcess,nmissing);
	end if;
	return '???';
end;
$$ language plpgsql;

-- proj1_rescheck:
-- * compares output of user function against expected result
-- * returns string (text message) containing analysis of results

create or replace function
	proj1_rescheck(_type text, _name text, _res text, _query text) returns text
as $$
declare
	_sql text;
	_chk boolean;
begin
	if (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (_res is null) then
		_sql := 'select ('||_query||') is null';
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	else
		_sql := 'select ('||_query||') = '||quote_literal(_res);
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	end if;
	if (_chk) then
		return 'correct';
	else
		return 'incorrect result';
	end if;
end;
$$ language plpgsql;

-- check_all:
-- * run all of the checks and return a table of results

drop type if exists TestingResult cascade;
create type TestingResult as (test text, result text);

create or replace function
	check_all() returns setof TestingResult
as $$
declare
	i int;
	testQ text;
	result text;
	out TestingResult;
	tests text[] := array['q1', 'q2', 'q3', 'q4', 'q5','q6','q7','q8','q9','q10','q11','q12', 'q13'];
begin
	for i in array_lower(tests,1) .. array_upper(tests,1)
	loop
		testQ := 'select check_'||tests[i]||'()';
		execute testQ into result;
		out := (tests[i],result);
		return next out;
	end loop;
	return;
end;
$$ language plpgsql;


--
-- Check functions for specific test-cases in Project 1
--

create or replace function check_q1() returns text
as $chk$
select proj1_check('view','q1','q1_expected',
									 $$select * from q1$$)
$chk$ language sql;

create or replace function check_q2() returns text
as $chk$
select proj1_check('view','q2','q2_expected',
									 $$select * from q2$$)
$chk$ language sql;

create or replace function check_q3() returns text
as $chk$
select proj1_check('view','q3','q3_expected',
									 $$select * from q3$$)
$chk$ language sql;

create or replace function check_q4() returns text
as $chk$
select proj1_check('view','q4','q4_expected',
									 $$select * from q4$$)
$chk$ language sql;

create or replace function check_q5() returns text
as $chk$
select proj1_check('view','q5','q5_expected',
									 $$select * from q5$$)
$chk$ language sql;

create or replace function check_q6() returns text
as $chk$
select proj1_check('view','q6','q6_expected',
									 $$select * from q6$$)
$chk$ language sql;

create or replace function check_q7() returns text
as $chk$
select proj1_check('view','q7','q7_expected',
									 $$select * from q7$$)
$chk$ language sql;

create or replace function check_q8() returns text
as $chk$
select proj1_check('view','q8','q8_expected',
									 $$select * from q8$$)
$chk$ language sql;

create or replace function check_q9() returns text
as $chk$
select proj1_check('view','q9','q9_expected',
									 $$select * from q9$$)
$chk$ language sql;

create or replace function check_q10() returns text
as $chk$
select proj1_check('view','q10','q10_expected',
									 $$select * from q10$$)
$chk$ language sql;

create or replace function check_q11() returns text
as $chk$
select proj1_check('view','q11','q11_expected',
									 $$select * from q11$$)
$chk$ language sql;

create or replace function check_q12() returns text
as $chk$
select proj1_check('view','q12','q12_expected',
									 $$select * from q12$$)
$chk$ language sql;

create or replace function check_q13() returns text
as $chk$
select proj1_check('view','q13','q13_expected',
									 $$select * from q13$$)
$chk$ language sql;
--
-- Tables of expected results for test cases
--

drop table if exists q1_expected;
create table q1_expected (
	subject_name mediumname
);

drop table if exists q2_expected;
create table q2_expected (
	course_id integer
);

drop table if exists q3_expected;
create table q3_expected (
	course_id integer, use_rate integer
);

drop table if exists q4_expected;
create table q4_expected (
	facility mediumstring
);

drop table if exists q5_expected;
create table q5_expected (
	unsw_id integer, student_name longname
);

drop table if exists q6_expected;
create table q6_expected (
	subject_name mediumname, 
	non_null_mark_count integer, 
	null_mark_count integer
);

drop table if exists q7_expected;
create table q7_expected (
	school_name longstring, stream_count integer
);

drop table if exists q8_expected;
create table q8_expected (
	student_name_local longname,student_name_intl longname
);

drop table if exists q9_expected;
create table q9_expected (
	ranking integer,
	course_id integer, 
	subject_name mediumname, 
	student_diversity_score integer
);

drop table if exists q10_expected;
create table q10_expected (
	subject_code character(8), 
	avg_mark numeric
);

drop table if exists q11_expected;
create table q11_expected (
		subject_code character(8), inc_rate numeric
);

drop table if exists q12_expected;
create table q12_expected (
	name longname, 
	subject_code character(8), 
	year courseyeartype, 
	term character(2), 
	lab_time_per_week integer
);

drop table if exists q13_expected;
create table q13_expected (
	subject_code character(8), 
	year courseyeartype, 
	term character(2), 
	fail_rate numeric
);
-- ( )+\|+( )+

COPY q1_expected (subject_name) FROM stdin;
Real Time Systems
Advanced & Parallel Algorithms
Design Project B
Knowledge Representation
User Interface Design & Constr
Distributed Systems
Neural Networks
Ext Neural Networks
Security Engineering Workshop
Computer Vision
Multimedia Systems
Web Applications Engineering
Real Time Instrumentation
Programming Challenges A
Software Architecture
First-order Logic
\.

COPY q2_expected (course_id) FROM stdin;
68619
70427
\.

COPY q3_expected (course_id, use_rate) FROM stdin;
36854	9
36855	9
36857	9
\.

COPY q4_expected (facility) FROM stdin;
Document camera
Fan ventilation
Slide projector
Whiteboard
Hearing loop
Neck microphone
\.

COPY q5_expected (unsw_id, student_name) FROM stdin;
3461389	Ros Mccrindle
3456650	Belinda Browitt
3368663	Jemille Ambler
3307887	Jana Sikorski
2230438	William McGinniss
3119674	Anna Basford
3397891	Katie Cai
3326984	Kylie Sui
3378291	Elijah Burns-Woods
3342602	Adrian Hynes
3476003	Joseph Leblond
3485061	Valerie Cheng
3191036	Cheaseth Heng
3013927	Lachlan Paoloni
3483850	Imad Schuman
3312751	Sydney McClintock
3266368	Bandarage Das
3305385	Shu Kwong
3312005	Po Chim
3498534	Mui Kok
2202270	Scott Karmakar
3464715	Juita Abdullah Jalani
3109454	Joel Raveendran
3376647	Yanmin Qian
3224767	Nigel Smallbone
3398209	Matthew Stephens
3437727	Vincy Thorpe
3385991	Michelle Croker
3387921	Barry Cane
3082954	Bryan Joye
3392463	Lisa Bullivant
3461061	Hamad Osmani
3193144	Megan Mendelsohn
3421409	Larissa Tofts
3444213	Meredith Fagundez
3417457	Russell Kalinowski
3417244	Kingsley Siu
3345752	Daniel Black
3307879	Jason Tong
3429557	Kimberly Black
3103161	Avinash Mohd Miran
3360868	Campbell Munday
\.

COPY q6_expected (subject_name, non_null_mark_count, null_mark_count) FROM stdin;
Mathematics 1A	121	12
Computers and I...Technology	57	16
Psychology 1A	92	14
Essentials of Chemistry 1A	65	14
Microeconomics 1	93	11
Molecules, Cells and Genes	91	20
\.

COPY q7_expected (school_name, stream_count) FROM stdin;
School of Education	127
School of Biological, Earth and Environmental Sciences	111
School of International Studies	111
School of the Arts and Media	108
School of Social Sciences	92
School of Humanities and Languages	83
School of Economics	57
School of Public Health & Community Medicine	54
\.

COPY q8_expected (student_name_local, student_name_intl) FROM stdin;
Lap Siu	Chantelle Sevitt
Dominique Kendrigan	William Maye
Angelie Veenstra	William Maye
Eita Vakafua	Chantelle Sevitt
Sanghwa Jeoung	Chantelle Sevitt
\.

COPY q9_expected (
	ranking,
	course_id, 
	subject_name, 
	student_diversity_score
) FROM stdin;
1	55833	Mathematics 1A	63
1	59046	Mathematics 1B	63
3	47105	Accounting & Financial Mgt 1A	57
4	66061	Mathematics 1B	56
5	54911	Microeconomics 1	55
6	55074	Engineering Design	54
6	49019	Managing Organisations&People	54
6	47425	Molecules, Cells and Genes	54
6	62762	Mathematics 1A	54
6	52145	Mathematics 1B	54
\.

COPY q10_expected (subject_code, avg_mark) FROM stdin;
COMP9441	76.58
COMP9317	76.17
COMP9414	68.75
GSOE9210	66.17
COMP9101	62.07
COMP9020	60.04
COMP9024	59.20
COMP9021	55.39
COMP9331	55.35
\.


COPY q11_expected (subject_code, inc_rate) FROM stdin;
ACCT3610	0.1984
\.

COPY q12_expected (name, subject_code, year, term, lab_time_per_week) FROM stdin;
Hui Guo	COMP3222	2010	S2	6
Hui Guo	COMP9222	2010	S2	6
Hye-Young Paik	COMP9321	2009	S2	32
Jahan Hassan	COMP9021	2010	S2	11
Malcolm Ryan	COMP1400	2010	S2	14
Malcolm Ryan	COMP1400	2011	S2	10
Nadine Marcus	COMP3511	2008	S2	12
Nadine Marcus	COMP3511	2009	S2	20
Nadine Marcus	COMP3511	2010	S2	20
Nadine Marcus	COMP9511	2008	S2	20
Nadine Marcus	COMP9511	2009	S2	20
Nadine Marcus	COMP9511	2010	S2	20
Xuemin Lin	COMP9311	2010	S1	10
Xuemin Lin	COMP9311	2011	S1	12
Xuemin Lin	COMP9311	2012	S1	10
\.

COPY q13_expected (subject_code, year, term, fail_rate) FROM stdin;
COMP1917	2012	S1	0.1030
COMP1927	2012	S2	0.1812
COMP1911	2011	S1	0.1212
\.

