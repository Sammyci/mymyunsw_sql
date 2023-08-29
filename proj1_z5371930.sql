-- comp9311 22T1 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(subject_name)
as
select name as subject_name from subjects where
code like 'COMP%'
and
_prereq like '%COMP3%%COMP%' or _prereq like '%COMP%%COMP3%'
;

-- Q2:
create or replace view Q2(course_id)
as
select distinct c.id as course_id from buildings b, rooms r, classes cl, class_types ct, courses c
where b.id = r.building and r.id = cl.room and cl.ctype = ct.id and c.id = cl.course
and ct.name = 'Studio' group by c.id having count(distinct b.id) > 2
;

-- Q3:
create or replace view Q3(course_id, use_rate)
as 
select * from
    (
    select c.id as course_id,count(course) as use_rate from
    classes cl,courses c where c.id = cl.course and startdate >= '2008-01-01' and enddate <= '2008-12-31'
    and cl.room in (select r.id from rooms r,buildings b where b.name = 'Central Lecture Block' and b.id = r.building)
    group by c.id order by use_rate desc
    )
    as tmp
    where use_rate = (
        select count(course) as use_rate from
        classes cl,courses c where c.id = cl.course and startdate >= '2008-01-01' and enddate <= '2008-12-31'
        and cl.room in
        (select r.id from rooms r,buildings b where b.name = 'Central Lecture Block' and b.id = r.building)
        group by c.id order by use_rate desc limit 1
                      )
;

-- Q4:
create or replace view Q4(facility)
as
select description as facility from facilities f
where f.id not in
(select rf.facility from room_facilities rf
where room in
(select r.id from rooms r
where r.building in
(select b.id from buildings b where b.campus = 'K' and gridref like 'C%')
)
)
;

--Q5:
create or replace view Q5(unsw_id, student_name)
as
select p.unswid unsw_id,p.name student_name from people p where p.id in
(select id from students where stype = 'local')
and
p.id not in
(select distinct student from (select student from course_enrolments where grade != 'HD')
as stu order by student asc)
;

-- Q6:
create or replace view Q6_1 as
select id,count(name) from
(select sub.name,c.id,ce.mark from subjects sub, courses c, course_enrolments ce, semesters sem
where sub.id = c.subject and ce.course = c.id and c.semester = sem.id and sem.name = 'Sem1 2006' and ce.mark is null)
as tmp group by id having count(name) > 10 order by count(name) desc
;

create or replace view Q6_2 as
select id,count(name) from
(select sub.name,c.id,ce.mark from subjects sub, courses c, course_enrolments ce, semesters sem
where sub.id = c.subject and ce.course = c.id and c.semester = sem.id and sem.name = 'Sem1 2006' and ce.mark is not null)
as tmp group by id order by count(name) desc
;

create or replace view Q6_3 as
select sub.name,c.id from subjects sub, courses c, course_enrolments ce, semesters sem
where sub.id = c.subject and ce.course = c.id and c.semester = sem.id and sem.name = 'Sem1 2006' and ce.mark is not null
;

create or replace view Q6(subject_name, non_null_mark_count, null_mark_count)
as
select distinct Q6_3.name as subject_name, Q6_2.count as non_null_mark_count, Q6_1.count as null_mark_count
from Q6_3 inner join Q6_1 on Q6_3.id = Q6_1.id inner join Q6_2 on Q6_3.id = Q6_2.id
;

-- Q7:
create or replace view Q7_1 as
select ou.id,ou.longname from orgunits ou where ou.id in
(select s1.offeredby from streams s1 group by s1.offeredby having count(*) > 
(select count(*) from streams s2 where s2.offeredby =
(select id from orgunits where longname = 'School of Computer Science and Engineering')))
;

create or replace view Q7_2 as
select s1.offeredby, count(*) from streams s1 group by s1.offeredby having count(*) >
(select count(*) from streams s2 where s2.offeredby =
(select id from orgunits where longname = 'School of Computer Science and Engineering'))
;

create or replace view Q7(school_name, stream_count)
as
select Q7_1.longname as school_name,Q7_2.count as stream_count from Q7_1 inner join Q7_2
on Q7_1.id = Q7_2.offeredby where Q7_1.longname like 'School%' order by stream_count desc;
;

-- Q8:
create or replace view Q8_1 as
select p.name student_name_intl,ce2.mark from people p,course_enrolments ce2 where p.id in
(select s.id from students s where s.stype = 'intl' and s.id in
(select ce.student from course_enrolments ce where ce.course =
(select c.id from courses c where c.semester = (select id from semesters where name = 'Sem1 2012') and
c.subject = (select id from subjects where name = 'Engineering Design')) and ce.mark > 98)) and
p.id = ce2.student and ce2.course = (select c.id from courses c where c.semester =
(select id from semesters where name = 'Sem1 2012') and
c.subject = (select id from subjects where name = 'Engineering Design'))
;

create or replace view Q8_2 as
select p.name student_name_local,ce2.mark from people p,course_enrolments ce2 where p.id in
(select s.id from students s where s.stype = 'local' and s.id in
(select ce.student from course_enrolments ce where ce.course =
(select c.id from courses c where c.semester = (select id from semesters where name = 'Sem1 2012') and
c.subject = (select id from subjects where name = 'Engineering Design')) and ce.mark > 98)) and
p.id = ce2.student and ce2.course = (select c.id from courses c where c.semester =
(select id from semesters where name = 'Sem1 2012') and
c.subject =(select id from subjects where name = 'Engineering Design'))
;

create or replace view Q8(student_name_local, student_name_intl)
as
select Q8_2.student_name_local,Q8_1.student_name_intl from Q8_1 inner join Q8_2 on Q8_1.mark = Q8_2.mark;
;

-- Q9:
create or replace view Q9(ranking, course_id, subject_name, student_diversity_score)
as
select * from (select rank()over(order by count(distinct cy.id) desc) ranking,c.id course_id,sub.name subject_name,
count(distinct cy.id) student_diversity_score from students s, people p, course_enrolments ce, countries cy,
subjects sub,courses c where cy.id = p.origin and p.id = s.id and ce.course = c.id and ce.student = s.id and
c.subject = sub.id group by c.id,sub.name order by count(distinct cy.id) desc) as tmp where ranking < 7
;

-- Q10:
create or replace view Q10_1 as
select ou.longname,sub.code,ce.mark from orgunits ou,subjects sub,semesters sem,courses c,course_enrolments ce
where ou.id = sub.offeredby and c.subject = sub.id and c.semester = sem.id and sem.name = 'Sem1 2010'
and ce.course = c.id and sub.career = 'PG' and ou.longname = 'School of Computer Science and Engineering'
;

create or replace view Q10_2 as
select code,round(avg(fmark),2) from (select code,coalesce(mark,0) as fmark from Q10_1) as tmp group by code
;

create or replace view Q10_3 as
select code,count(code) from Q10_1 group by code having count(code) > 10
;

create or replace view Q10(subject_code, avg_mark)
as
select Q10_3.code as subject_code,Q10_2.round as avg_mark from Q10_3 inner join Q10_2 on Q10_3.code = Q10_2.code
order by avg_mark desc
;

-- Q11:
create or replace view Q11_1 as
select su.code, round(avg(ce.mark),2) from course_enrolments ce,subjects su,courses cs where su.id = cs.subject and
cs.id = ce.course and ce.course in (select c.id from courses c where c.subject in
(select sub.id from subjects sub where sub.offeredby in (select ou.id from orgunits ou
where ou.longname = 'School of Chemistry' or ou.longname = 'School of Accounting')) and c.semester =
(select se.id from semesters se where se.name = 'Sem1 2008')) group by su.code order by round(avg(ce.mark),2) desc
;

create or replace view Q11_2 as
select su.code,round(avg(ce.mark),2) from course_enrolments ce,subjects su,courses cs where su.id = cs.subject and
cs.id = ce.course and ce.course in (select c.id from courses c where c.subject in (select sub.id from subjects sub
where sub.offeredby in (select ou.id from orgunits ou where ou.longname = 'School of Chemistry' or
ou.longname = 'School of Accounting')) and c.semester = (select se.id from semesters se where se.name = 'Sem2 2008'))
group by su.code order by round(avg(ce.mark),2) desc
;

create or replace view Q11(subject_code, inc_rate)
as
select * from (select Q11_1.code as subject_code,round(((Q11_2.round - Q11_1.round)/Q11_1.round),4) as inc_rate
from Q11_1 inner join Q11_2 on Q11_1.code = Q11_2.code order by inc_rate desc) as tmp
where inc_rate is not null limit 1
;

-- Q12:
create or replace view Q12_1 as
select p.name, sub.code, sem.year, sem.term, (cl.endtime - cl.starttime) as labtime
from classes cl, courses c, subjects sub, semesters sem, course_staff cff, people p
where p.id = cff.staff and p.title = 'Dr' and cff.course = c.id and sem.id = c.semester and c.id = cl.course
and c.subject = sub.id and sub.code like 'COMP%' and cl.ctype = (select id from class_types where unswid = 'LAB')
and cff.role in (select id from staff_roles where name like '%Lecturer%')
;

create or replace view Q12(name, subject_code, year, term, lab_time_per_week)
as
select name,code as subject_code, year, term, sum(labtime) as lab_time_per_week from Q12_1
group by name, code, year, term order by year asc
;

-- Q13:
create or replace view Q13_1 as
select code,year,term,count(student) from
(select ce.student,sub.code, sem.year,sem.term,ce.mark from courses c, course_enrolments ce, subjects sub, semesters sem
where ce.course = c.id and c.subject = sub.id and c.semester = sem.id and sub.code like 'COMP%' and ce.mark is not null)
as tmp group by code,year,term order by count(student) desc
;

create or replace view Q13_2 as
select code,year,term,count(student) from
(select ce.student,sub.code, sem.year,sem.term,ce.mark from courses c, course_enrolments ce, subjects sub, semesters sem
where ce.course = c.id and c.subject = sub.id and c.semester = sem.id and sub.code like 'COMP%')
as tmp group by code,year,term having count(student) > 149 order by count(student) desc
;

create or replace view Q13_3 as
select code,year,term,count(student) from
(select ce.student,sub.code, sem.year,sem.term,ce.mark from courses c, course_enrolments ce, subjects sub, semesters sem
where ce.course = c.id and c.subject = sub.id and c.semester = sem.id and sub.code like 'COMP%' and
ce.mark is not null and ce.mark <50) as tmp
group by code,year,term order by count(student) desc
;

create or replace view Q13_4 as
select Q13_2.code,Q13_2.year,Q13_2.term,round(Q13_3.count::numeric/Q13_1.count::numeric,4) as fail_rate,Q13_2.count
from Q13_2
inner join Q13_1 on Q13_2.code = Q13_1.code and Q13_2.year = Q13_1.year and Q13_2.term = Q13_1.term
inner join Q13_3 on Q13_2.code = Q13_3.code and Q13_2.year = Q13_3.year and Q13_2.term = Q13_3.term
;

create or replace view Q13(subject_code, year, term, fail_rate)
as
select code as subject_code,year,term,fail_rate from
(select code,year,term,fail_rate,rank()over(partition by code order by count desc) as rank from Q13_4) as tmp
where rank = 1
;
