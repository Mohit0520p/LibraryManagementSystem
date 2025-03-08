                                             -- LIBRARY MANAGEMENT SYSTEM --


-- creating branch table (dropping to make sure table does not exist prior to this .)

drop table if exists branch;
create table branch(branch_id varchar(10) primary key ,
manager_id varchar(10),
branch_address varchar(50) ,
contact_number varchar(50));

--creating table employees

drop table if exists employees;
create table employees(
emp_id varchar(10) PRIMARY KEY ,
emp_name varchar(65),
emp_position varchar(55),
salary int,
branch_id varchar(10)
);

alter table employees
alter column salary type varchar(25);



drop table if exists books;
create table books (
isbn varchar(20) primary key ,
book_title varchar(75),
category varchar(10),
rental_price float,
status varchar(15),
author varchar(35),
publisher varchar(50) 
);


drop table if exists members ;
create table members (
member_id varchar(10) PRIMARY KEY ,
member_name varchar(25),
member_address varchar(50),
reg_address DATE
);

)

drop table if exists issued_status;
create table issues_status (
issued_id varchar(10) primary key ,
issued_member_id varchar(10),-- fk
issued_book_name varchar(40),
issued_date DATE,
issued_book_isbn varchar(25), -- fk
issued_emp_id varchar(10) -- fk
);

alter table issues_status
alter column issued_book_name type varchar(75);
--alter column issued_book_isbn type varchar(75)


drop table if exists return_status;
create table return_status(

return_id varchar(10) primary key ,
issued_id varchar(10),
return_date DATE,
return_book_name varchar(75),
return_book_isbn varchar(20)
);
	
--FOREIGN KEYS
alter table issues_status 
ADD CONSTRAINT fk_members 
FOREIGN KEY(issued_member_id)
REFERENCES members(member_id)
;

ALTER TABLE ISSUES_STATUS
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn)
;


ALTER TABLE ISSUES_STATUS
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id)
;

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id)
;


ALTER TABLE return_status
ADD CONSTRAINT fk_issues_status
FOREIGN KEY (issued_id)
REFERENCES issues_status(issued_id)
;



alter table books
alter column category type varchar(30);

--checking all data successfully imported. 
select * from employees;


                                                       -- PROJECT TASKS --


/* Task 1 -  
Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird',
'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')" */

insert into books (
isbn,
book_title ,
category,
rental_price,
status,
author,
publisher
) values ('978-1-60129-456-2','To Kill a Mockingbird','Classic',6.00,'yes','Harper Lee','J.B. Lippincott & Co.');



select count(*) as total_records from books ;

/* Task 2 - Update an existing member address 
*/

select * from members;
update members set member_address = '125 Main Street' where member_id = 'C101' ;

/* Task 3 - Delete the record from the issued status table with issue_id = 'IS121'
*/
select * from issues_status;
Delete from issues_status where issued_id = 'IS121';


/* Task 4 - Retrive all books by a specific employee(emp_id = E101)
*/
select issued_book_name as books_issued from issues_status where issued_emp_id = 'E101';

/* Task 5 - List members who have issued more than 1 book . 
*/

select * from issues_status;

select issued_emp_id , 
count(issued_id) as total_books from issues_status 
group by 1
having count (issued_id) > 1
;

/* Task 6 - Create summary tables : Use CTAS to generate new tables based on query results-each book and total_book_issued_cnt
*/
create table book_count as 

SELECT b.isbn,
b.book_title,
COUNT(ist.issued_id) as books_issued 
from books b JOIN issues_status as ist 
on ist.issued_book_isbn = b.isbn
group by 1 ,2
;

select * from book_count;

/* Task 7 - Retrive all books in a specifc category 
*/

select * from books where category IN ('Classic','Literary Fiction');


/* Task 8 - Find total rental income by category .
*/

--select * from issues_status;
--select * from books ;
--select category , sum(rental_price) as total_rental_income from books group by 1 ; 

-- as the books will be rented more than once so including all that data here also .
select b.category,
sum(b.rental_price) as rented_price,
count(*) as number_oftimes_rented
from books as b join issues_status as ist 
on b.isbn = ist.issued_book_isbn
group by 1 ;


/* Task 9 - List the name of members who signed up in the last 180 days  .
*/
select * from members;
insert into members (member_id,member_name,member_address,reg_address)
values
('C120','Mohit Partap','144 Main Street','2025-03-01'),
('C121','Rohit Jain','134 Main Street','2025-02-01');

--update members set member_name = 'Mohit Pratap' where member_id = 'C120';

select member_name from members where reg_address >= current_date - interval '180 days' ;

/* Task 10 - List Employee's with their branch manager's name and branch details .
*/
/*select * from branch;
select * from employees;*/

select e1.emp_id, e1.emp_name , b.manager_id,b.branch_address from employees as e1 
JOIN 
branch as b 
on 
b.branch_id = e1.branch_id
join employees as e2 
on b.manager_id = e2.emp_id;


/* Task 11 - Create a table of books with rental price above a particular threshold
books with rental price >= 7.00*/

create table expensive_books as 
(select * from books where rental_price >= 7.00);

select * from expensive_books;

/* Task 12 - Retrive the set of books not returned yet 
*/

select * from issues_status;
select * from return_status;

select * from return_status where return_date is NULL;

select ist.issued_id , ist.issued_book_name,ist.issued_date from issues_status as ist 
left join return_status as rst on
ist.issued_id = rst.issued_id 
where rst.return_id is null





