####第四题####
drop procedure if exists borrowBook;
DELIMITER //
CREATE procedure  borrowBook(IN r_ID CHAR(8),IN b_ID CHAR(8))
BEGIN
	DECLARE cnt int;
    -- 如果该图书存在预约记录，而当前借阅者没有预约，则不许借阅；
	IF EXISTS(SELECT 1 FROM reserve where book_ID=b_ID and r_ID!=reader_ID)  THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'This book has been reserved';
    END IF;
    
    -- 同一天不允许同一个读者重复借阅同一本读书
    IF EXISTS(SELECT 1 FROM borrow where book_ID=b_ID and r_ID=reader_ID and borrow_date=curdate())  THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'You have borrowed this book';
    END IF;
    
    -- 一个读者最多只能借阅 3 本图书
    select count(*) into cnt from borrow where r_ID=reader_ID AND return_Date IS NULL;
    IF cnt>=3 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'You have borrowed 3 books';
    END IF;
    
    -- 可以借阅
    UPDATE Book
        SET bstatus = 1, borrow_Times = borrow_Times + 1
        WHERE bid = b_ID;
	INSERT INTO Borrow VALUES (b_ID, r_ID, curdate(),NULL);
    
    -- 借阅完成后删除借阅者对该图书的预约记录
    IF EXISTS(SELECT 1 FROM reserve where book_ID=b_ID and r_ID=reader_ID) THEN
        DELETE FROM Reserve
        WHERE book_ID = b_ID AND reader_ID = r_ID;
    END IF;
END//
DELIMITER ; 
-- 测试
call borrowBook('R001','B008');
call borrowBook('R001','B001');
select * from book;
select * from borrow;
select * from reserve;
call borrowBook('R001','B001');
call borrowBook('R005','B008');
