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
create or replace view Q6(subject_name, non_null_mark_count, null_mark_count)
as 
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
as select c.id 
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q10:
create or replace view Q10(subject_code, avg_mark)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q11:
create or replace view Q11(subject_code, inc_rate)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q12:
create or replace view Q12(name, subject_code, year, term, lab_time_per_week)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q13:
create or replace view Q13(subject_code, year, term, fail_rate)
as
--... SQL statements, possibly using other views/functions defined by you ...
;