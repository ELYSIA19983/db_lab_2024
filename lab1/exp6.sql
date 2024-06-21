####第五题####
drop trigger if exists after_reserve_book;
drop trigger if exists after_cancel_reserve;
drop trigger if exists  after_last_cancel_reserve;
DELIMITER //
CREATE TRIGGER after_reserve_book 
AFTER insert ON reserve 
FOR EACH ROW
BEGIN
-- 更新图书表中相应图书的 bstatus 为 2
	UPDATE book
    SET bstatus = 2,
        reserve_Times = reserve_Times + 1
    WHERE bid = NEW.book_ID;
END//

CREATE TRIGGER after_cancel_reserve
AFTER DELETE ON reserve
FOR EACH ROW
BEGIN
    -- 减少相应图书的 reserve_Times
    UPDATE book
    SET reserve_Times = reserve_Times - 1
    WHERE bid = OLD.book_ID;
END;

CREATE TRIGGER after_last_cancel_reserve
AFTER DELETE ON reserve
FOR EACH ROW
BEGIN
    DECLARE reserve_count INT;
    DECLARE book_state INT;
    -- 获取相应图书的预约数量
    SELECT COUNT(*) INTO reserve_count FROM reserve WHERE book_ID = OLD.book_ID;
	SELECT bstatus INTO book_state FROM book WHERE bid = OLD.book_ID;
    -- 如果预约数量为 0，且修改前bstatus 为 2，则将图书状态改为 0
    IF reserve_count = 0 AND book_state = 2 THEN
        UPDATE book
        SET bstatus = 0
        WHERE bid = OLD.book_ID;
    END IF;
END;//
DELIMITER ; 
select * FROM BOOK;
select * FROM BORROW;
select * FROM BOOK where bid='B012';
select * from reserve;
INSERT INTO reserve (book_id, reader_id, take_date) VALUES ('B012', 'R001', '2024-06-20');
INSERT INTO reserve (book_id, reader_id, take_date) VALUES ('B012', 'R002', '2024-06-20');
delete from reserve where book_id='B012' and reader_id='R001' and take_date= '2024-06-20';
delete from reserve where book_id='B012' and reader_id='R002' and take_date= '2024-06-20';
