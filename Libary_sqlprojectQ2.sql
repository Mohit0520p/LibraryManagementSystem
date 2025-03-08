--SQL PROJECT - LIBRARY MANAGEMENT SYSTEM Q2
select * from books;
select * from branch;
select * from return_status;
select * from issues_status;
select * from employees;
select * from members;
--All data in all the tables looks good.

/* 
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
create table overdue_books as 
(
select ist.issued_member_id , m.member_name , ist.issued_book_name , ist.issued_date,
CURRENT_DATE - ist.issued_date as days_overdue 
from issues_status as ist 
join members as m 
on ist.issued_member_id = m.member_id
left join 
return_status as rst
on rst.issued_id = ist.issued_id
where rst.return_date is null
)

select * from overdue_books where days_overdue >= 336 order by issued_member_id ;

-- to check the current date , use SELECT CURRENT_DATE FXN OF SQL.

/*
Task 14: Update Book Status on Return :
Write a query to update the status of books in the books table to
"Yes" when they are returned (based on entries in the return_status table).
*/

select * from return_status;
alter table return_status ADD book_quality varchar(50)
select * from books where status = 'no';


--stored procedure 
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id varchar(10), p_issued_id varchar(10) , p_bookQuality varchar(50))
LANGUAGE plpgsql
AS $$
DECLARE 
 v_isbn varchar(50);
 v_bookName varchar(80);
 
BEGIN
     INSERT INTO return_status (return_id , issued_id ,return_date,book_quality)
	 VALUES
	 (p_return_id , p_issued_id,CURRENT_DATE, p_bookQuality );

	 select issued_book_isbn,issued_book_name
	 into v_isbn , v_bookName
	 from issues_status
	 where issued_id = p_issued_id;

	 UPDATE BOOKS  
	 SET status = 'yes'
	 WHERE isbn = v_isbn;

	 --select * from issues_status;

         -- print message on console .
	   RAISE NOTICE 'Thank you for returning the book %',v_bookName;
END;
$$

drop PROCEDURE add_return;
select * from issues_status where issued_id ='IS135';
select * from return_status;

--calling stored procedure .
CALL add_return_records('RS119','IS135','Good');
select * from return_status where return_id='RS119';
select * from books where book_title ='Sapiens: A Brief History of Humankind';

/* 
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

/*SELECT br.branch_address,count(ist.issued_id) , count(rst.return_id) , 
SUM(bk.rental_price)
FROM branch as br
JOIN issues_status as ist 
JOIN return_status as rst
JOIN books as bk
ON*/

--select * from issues_status;

CREATE TABLE BRANCH_REPORT AS (

select br.branch_address , 
SUM(b.rental_price) as total_revenue,
count(ist.issued_id) as books_issued,
count(rst.return_id) as books_returned
from employees as e 
join issues_status as ist 
on e.emp_id = ist.issued_emp_id
join branch as br 
on br.branch_id = e.branch_id
left join return_status as rst 
on rst.issued_id = ist.issued_id
join books as b
on b.isbn = ist.issued_book_isbn
group by 1 
);

/*select * from branch_report;
select * from expensive_books;*/


/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create 
a new table active_members containing members who have issued at least one book in the last 2 months.
*/
create table active_member AS(
select m.member_name as active_members , count(ist.issued_id) as books_issued  from members as m 
join issues_status as ist 
on m.member_id = ist.issued_member_id
where issued_date > current_date - interval'48 month'
group by m.member_name)

select * from active_member;

/* 
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed 
the most book issues. Display the employee name, number of books processed, and their branch.
*/
select e.emp_name as employee_name, count(ist.issued_id) as books_issued  ,br.branch_address  from employees as  e 
JOIN Issues_status as ist 
on e.emp_id = ist.issued_emp_id
Join branch as br 
on e.branch_id = br.branch_id
group by 1,3
order by count(ist.issued_id) desc 
limit 3

/*
Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.
Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/




create or replace procedure issue_book(p_issued_id varchar(20)  , p_member_id varchar(20) , p_issued_book_isbn varchar(50) , p_issued_emp_id varchar(20))
language plpgsql
AS $$
DECLARE 
 v_status varchar(20);

BEGIN

      select status into v_status 
	  from books 
	  where isbn = p_issued_book_isbn;

	  -- if status yes, insert record in issued_status table .
	  if v_status = 'yes' then 
	      insert into issues_status(issued_id , issued_member_id , issued_date , issued_book_isbn , issued_emp_id) 
		  VALUES(p_issued_id,p_member_id,CURRENT_DATE,p_issued_book_isbn,p_issued_emp_id);
           -- 
		  RAISE NOTICE 'Book Record added successfully for isbn :%',p_issued_book_isbn;
		  
          -- once book issued , change availability status to = NO . 
		  
		  update books set status ='no'
		  WHERE isbn = p_issued_book_isbn;
      else 
	       RAISE NOTICE 'Book not available  for isbn :%',p_issued_book_isbn;
		  
	   end if ;
END;
$$

select * from issues_status;
select * from books where status ='no';
call issue_book('IS141','C105','978-0-375-41398-8','E104');
