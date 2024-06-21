####第五题####
drop procedure if exists returnBook;
DELIMITER //
CREATE procedure  returnBook(IN r_ID CHAR(8),IN b_ID CHAR(8))
BEGIN

	IF  NOT EXISTS(SELECT 1 FROM borrow where book_ID=b_ID and r_ID=reader_ID )  THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = '未借阅';
    END IF;

	UPDATE borrow SET return_Date='2024-05-10' WHERE book_ID=b_ID and r_ID=reader_ID;

	IF  EXISTS(SELECT 1 FROM reserve where book_ID=b_ID) THEN
		UPDATE BOOK SET bstatus = 2 WHERE BID=b_ID;
	ELSE 
		UPDATE BOOK SET bstatus = 0 WHERE BID=b_ID;
	END IF;
END//
DELIMITER ; 
CALL returnBook('R001','B008');

select * FROM BOOK;
select * FROM BORROW;
CALL returnBook('R001','B001');