####第三题####
drop procedure if exists updateReaderID;
DELIMITER //
CREATE procedure updateReaderID(IN old_ID CHAR(8),IN new_ID CHAR(8))
BEGIN
	IF EXISTS(SELECT 1 FROM reader WHERE rid = new_ID) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'New reader ID already exists';
    END IF;
    IF NOT EXISTS(SELECT 1 FROM reader WHERE rid = old_ID) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'reader ID not exists';
    END IF;
    SET FOREIGN_KEY_CHECKS=0; -- to disable them

	UPDATE borrow SET reader_ID = new_ID WHERE reader_ID=old_ID;
    UPDATE reserve SET reader_ID =new_ID WHERE reader_ID=old_ID;
    UPDATE reader SET rid=new_ID WHERE rid=old_ID;
    -- SET SQL_SAFE_UPDATES = 1;
    SET FOREIGN_KEY_CHECKS=1;
END//
DELIMITER ; 
call updateReaderID('R006','R999');
select * FROM reader;
select * FROM borrow;
select * FROM reserve;