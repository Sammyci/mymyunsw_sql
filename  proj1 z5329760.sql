-- comp9311 22T1 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(subject_name)
as select name as subject_name from Subjects where  _prereq like '%COMP3%%COMP%' or _prereq like '%COMP%%COMP3%' 
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q2:
create or replace view Q2(course_id)
as select c.id as course_id from courses c,classes cla,rooms r,buildings b,Class_types ct where cla.ctype=ct.id and ct.name='Studio' and b.id = r.building and c.id = cla.course and r.id = cla.room group by c.id having count(distinct b.id)>=3
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q3:
create view Q_3 as select c.id as course_id, count(c.id) as use_rate from courses c, Classes cla where c.id=cla.course and cla.startdate>='2008-1-1' and cla.enddate<='2008-12-31' and cla.room in (select r.id from rooms r,buildings b where b.id=r.building and b.name='Central Lecture Block') group by c.id
;
create or replace view Q3(course_id, use_rate)
as select course_id,  use_rate from Q_3 where Q_3.use_rate=(select count(c.id) as use_rate from courses c, Classes cla where c.id=cla.course and cla.startdate>='2008-1-1' and cla.enddate<='2008-12-31' and cla.room in (select r.id from rooms r,buildings b where b.id=r.building and b.name='Central Lecture Block') group by c.id order by use_rate desc limit 1)
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q4:
create or replace view Q4(facility)
as select description as facility from facilities where description not in (select distinct description from facilities fa,rooms r,room_facilities rf,buildings b where fa.id=rf.facility and r.building=b.id and rf.room=r.id and b.gridref like 'C%' and b.campus='K')

--... SQL statements, possibly using other views/functions defined by you ...
;

--Q5:
create or replace view Q5(unsw_id, student_name)
as select distinct unswid as unsw_id, name as student_name from People as p , students as s, course_enrolments as ce where p.id = s.id and p.id = ce.student and s.stype='local' and ce.grade = 'HD' and s.id not in ( select distinct student from Course_enrolments where grade != 'HD' )
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q6:
create view QQ6 as select id,name,count(name) from (select c.id , sub.name from courses as c , Course_enrolments as ce, semesters as se, subjects as sub  where  se.name = 'Sem1 2006' and  c.semester = se.id and ce.course = c.id and c.subject = sub.id and ce.mark is null) as dio group by (id,name) having count(name)>10 ;
create view QQQ6 as select id, count(id) from (select c.id , sub.name from courses as c , Course_enrolments as ce, semesters as se, subjects as sub  where  se.name = 'Sem1 2006' and  c.semester = se.id and ce.course = c.id and c.subject = sub.id and ce.mark is not null) as dio group by (id,name) ;
create view QQQQ6 as select sub.name, c.id from subjects as sub, courses as c, Course_enrolments as ce, semesters as se where  c.semester = se.id and ce.course = c.id and c.subject = sub.id and ce.mark is not null and se.name = 'Sem1 2006';
create or replace view Q6(subject_name, non_null_mark_count, null_mark_count)
as select distinct QQQQ6.name as subject_name , QQQ6.count as non_null_mark_count, QQ6.count as null_mark_count from QQ6 inner join QQQ6 on QQ6.id = QQQ6.id inner join QQQQ6 on QQQ6.id=QQQQ6.id;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q7:
create view QQ7 as select count(o.longname) from Orgunits as o, streams as s where s.offeredBy = o.id and o.longname='School of Computer Science and Engineering';
create or replace view Q7(school_name, stream_count)
as select o.longname as school_name, count(o.longname) as stream_count from Orgunits as o, streams as s where s.offeredBy = o.id and o.longname in (select longname from Orgunits where longname!='School of Computer Science and Engineering') group by o.id having count(o.longname)>(select QQ7.count from QQ7) and o.longname like 'School%' order by stream_count desc;


--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q8: 
create view Q8_localname as select distinct ce.mark, p.name from Subjects sub, courses c,semesters se, program_enrolments  pe,people p, students stu, course_enrolments ce where sub.id = c.subject and ce.course = c.id and se.id = c.semester and stu.id =ce.student and stu.id = p.id and stu.stype='local' and ce.mark>98 and se.longname = '2012 Semester 1' and sub.name='Engineering Design';
create view Q8_intlname as select distinct ce.mark, p.name from Subjects sub, courses c,semesters se, program_enrolments  pe,people p, students stu, course_enrolments ce where sub.id = c.subject and ce.course = c.id and se.id = c.semester and stu.id =ce.student and stu.id = p.id and stu.stype='intl' and ce.mark>98 and se.longname = '2012 Semester 1' and sub.name='Engineering Design';
create or replace view Q8(student_name_local, student_name_intl)
as select Q8_localname.name as student_name_local, Q8_intlname.name as student_name_intl from Q8_localname inner join Q8_intlname on  Q8_intlname.mark=Q8_localname.mark
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q9:
create or replace view Q9(ranking, course_id, subject_name, student_diversity_score)
as select ranking,course_id,subject_name,student_diversity_score from (select rank() over(order by count(distinct p.origin) desc) as ranking, c.id as course_id , sub.name as subject_name , count(distinct p.origin) as student_diversity_score from courses c, subjects sub, people p, course_enrolments ce ,students stu, Countries cou where sub.id = c.subject and ce.course = c.id and stu.id = ce.student and stu.id = p.id and cou.id = p.origin group by (c.id,sub.name) order by count(distinct p.origin) desc) as dior where ranking <=6  
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q10:
create or replace view QQ10 as select sub.code,count(sub.code),se.name,o.longname,sub.career from subjects sub, semesters se, courses c,classes cla,course_enrolments  ce ,orgunits o where sub.id= c.subject and ce.course = c.id and sub.offeredBy = o.id and   se.id = c.semester and se.name = 'Sem1 2010' and o.longname ='School of Computer Science and Engineering'  and sub.career='PG' group by (sub.code,se.name,o.longname,sub.career) having count(sub.code) > 10;
create or replace view Q10(subject_code, avg_mark)
as select code as subject_code   from select sub.code , AVG(coalesce(ce.mark,0)) from subjects sub, semesters se, courses c, students stu,classes cla,course_enrolments  ce ,orgunits o where sub.id= c.subject and ce.course = c.id and se.name = 'Sem1 2010' and  c.semester = se.id  and o.longname ='School of Computer Science and Engineering' and sub.offeredBy = o.id and sub.career='PG' group by (sub.code)
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q11:
create or replace view QQ11 as select se.year , sub.code , round(avg(coalesce(ce.mark,0)),2), se.name ,o.longname from subjects sub,semesters se, courses c, course_enrolments ce,orgunits o  where sub.id= c.subject and ce.course = c.id and se.id = c.semester and sub.offeredBy = o.id and se.year = 2008 and (o.longname = 'School of Accounting' or o.longname = 'School of Chemistry') and se.name = 'Sem1 2008' and ce.mark is not null group by (sub.code,se.year,se.name,o.longname);

create or replace view QQQ11 as select se.year , sub.code , round(avg(coalesce(ce.mark,0)),2), se.name ,o.longname from subjects sub,semesters se, courses c, course_enrolments ce,orgunits o  where sub.id= c.subject and ce.course = c.id and se.id = c.semester and sub.offeredBy = o.id and se.year = 2008 and (o.longname = 'School of Accounting' or o.longname = 'School of Chemistry') and se.name = 'Sem2 2008' group by (sub.code,se.year,se.name,o.longname);
create or replace view Q11(subject_code, inc_rate)
as select QQ11.code as subject_code, round(((QQQ11.round-QQ11.round)/QQ11.round),4) as inc_rate from QQ11,QQQ11 where QQQ11.code=QQ11.code  order by (QQQ11.round-QQ11.round) desc limit 1;  
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q12:
create or replace view QQ12 as select p.name ,sub.code , sem.year , sem.term  ,(cla.endtime - cla.starttime) as labtime
from course_staff  cs, Semesters sem, people p, classes  cla, courses  c, subjects  sub
where p.id=cs.staff and cs.course = c.id and sem.id = c.semester and c.id=cla.course and c.subject = sub.id 
and cs.role in (select id from Staff_roles where name like '%Lecturer%') 
and cla.ctype = (select id from class_types where unswid='LAB') 
and p.title = 'Dr' 
and sub.code like 'COMP%' ;

create or replace view Q12(name, subject_code, year, term, lab_time_per_week)
as select name, code as subject_code, year, term, sum(labtime) as lab_time_per_week from QQ12 group by(name,code,year,term)
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q13:
create or replace view Q13(subject_code, year, term, fail_rate)
as
--... SQL statements, possibly using other views/functions defined by you ...
;