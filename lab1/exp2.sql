####第二题####

##(1)##
SELECT b.bid, b.bname, br.borrow_Date
FROM Book b
JOIN Borrow br ON b.bid=br.book_ID
JOIN Reader r  ON r.rid=br.reader_ID
WHERE r.rname = 'Rose';

##(2)##
select rid,rname
from   Reader
where  rid not in ((select reader_ID from Borrow) union (select reader_ID from reserve));

##(3)##
SELECT b.author, SUM(borrow_Times) AS total_borrow_times
FROM Book b
GROUP BY b.author
ORDER BY total_borrow_times DESC
LIMIT 1;

SELECT b.author, count(*) AS total_borrow_times
FROM borrow br
JOIN book b ON b.bid=br.book_ID
GROUP BY b.author
ORDER BY total_borrow_times DESC
LIMIT 1;

##(4)##
SELECT b.bid, b.bname
FROM Book b
JOIN Borrow br ON b.bid = br.book_ID
WHERE br.return_Date IS NULL AND b.bname LIKE '%MySQL%';

##(5)##
SELECT r.rname
FROM READER R
join borrow br on r.rid=br.reader_ID
group by r.rid having count(*)>3;

##(6)##
select r.rid,r.rname
from reader r
where r.rid not in(
	select br.reader_ID
    from borrow br
    join book b on b.bid=br.book_id
    where b.author='J.K. Rowling');

    
##(7)##
SELECT r.rid, r.rname, COUNT(*) AS borrow_sum
FROM Reader r
JOIN Borrow b ON r.rid = b.reader_ID
WHERE YEAR(b.borrow_Date) = 2024
GROUP BY r.rid, r.rname
ORDER BY borrow_sum DESC
LIMIT 3;

##(8)##
CREATE VIEW BorrowInfo
AS SELECT r.rid, r.rname, br.book_ID, b.bname, br.borrow_Date
   FROM Reader r
   LEFT JOIN Borrow br ON r.rid = br.reader_ID
   LEFT JOIN Book b ON br.book_ID = b.bid;

SELECT rid, COUNT(DISTINCT book_ID) AS book_num
FROM BorrowInfo
WHERE YEAR(borrow_Date) = 2024
GROUP BY rid; 