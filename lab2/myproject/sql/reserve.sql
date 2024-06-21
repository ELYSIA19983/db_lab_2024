use libsystem;
SET GLOBAL event_scheduler = ON;

-- 预定图书
DROP PROCEDURE IF EXISTS ReserveBook;
DELIMITER //
CREATE PROCEDURE ReserveBook(
    IN p_StudentID VARCHAR(10),
    IN p_BookID INT
)
BEGIN
	DECLARE v_ReservationDate DATE;
    DECLARE v_ExpirationDate DATE;
    DECLARE v_BookTitle VARCHAR(255);
    -- 如果该图书可借阅数为0则不可预定
    IF (SELECT CopiesAvailable FROM Book WHERE BookID = p_BookID) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The book is not available for reservation';
    END IF;
    -- 不允许同一个读者重复预定同一本读书
    IF EXISTS (SELECT * FROM Reservation WHERE StudentID = p_StudentID AND BookID = p_BookID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You have reserved this book.';
    END IF;
    -- 一个读者最多只能预定 3 本图书
    IF (SELECT COUNT(*) FROM Reservation WHERE StudentID = p_StudentID) >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You have reserved too many books.';
    END IF;
    -- 如果该读者已经借阅该书，则不可预定
    IF EXISTS (SELECT * FROM Borrowing WHERE StudentID = p_StudentID AND BookID = p_BookID AND ReturnDate IS NULL) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You have borrowed this book.';
    END IF;

    -- 设置预定日期为当天
    SET v_ReservationDate = CURDATE();
    
    -- 设置预定过期日期为一个月后
    SET v_ExpirationDate = DATE_ADD(v_ReservationDate, INTERVAL 1 MONTH);
    SET v_BookTitle = (SELECT Title FROM Book WHERE BookID = p_BookID);
    -- 插入预定信息
    INSERT INTO Reservation (StudentID, BookID, BookTitle, ReservationDate, ExpirationDate)
    VALUES (p_StudentID, p_BookID,v_BookTitle, v_ReservationDate, v_ExpirationDate);
END //
DELIMITER ;

-- 当预定图书时触发触发器是该图书可借阅数减一
DROP TRIGGER IF EXISTS ReservationTrigger;
DELIMITER //
CREATE TRIGGER ReservationTrigger
AFTER INSERT ON Reservation
FOR EACH ROW
BEGIN
    UPDATE Book SET CopiesAvailable = CopiesAvailable - 1
    WHERE BookID = NEW.BookID;
END //
DELIMITER ;

-- 当预定过期时，删除预定信息，使用事件调度器实现
DROP EVENT IF EXISTS DeleteExpiredReservation;

CREATE EVENT DeleteExpiredReservation
ON SCHEDULE EVERY 1 SECOND
DO
    -- 可借阅数加一
    UPDATE Book SET CopiesAvailable = CopiesAvailable + 1
    WHERE BookID IN (SELECT BookID FROM Reservation WHERE ExpirationDate < CURDATE());
    -- 删除过期预定
	SET SQL_SAFE_UPDATES = 0;
    DELETE FROM Reservation WHERE ExpirationDate < CURDATE();
    SET SQL_SAFE_UPDATES = 1;

-- 取消预定
DROP PROCEDURE IF EXISTS CancelReservation;
DELIMITER //
CREATE PROCEDURE CancelReservation(
    IN p_ReservationID INT
)
BEGIN
    DELETE FROM Reservation WHERE ReservationID = p_ReservationID;
END //
DELIMITER ;

-- 取消预定时触发触发器是该图书可借阅数加一
DROP TRIGGER IF EXISTS CancelReservationTrigger;
DELIMITER //
CREATE TRIGGER CancelReservationTrigger
AFTER DELETE ON Reservation
FOR EACH ROW
BEGIN
    UPDATE Book SET CopiesAvailable = CopiesAvailable + 1
    WHERE BookID = OLD.BookID;
END //
DELIMITER ;

-- 查询预定信息
DROP PROCEDURE IF EXISTS SearchReserve;
DELIMITER //
CREATE PROCEDURE SearchReserve(
    IN ReservationID INT,
    IN StudentID VARCHAR(10),
    IN BookID INT,
    IN BookTitle VARCHAR(255),
    IN ReservationDate DATE,
    IN ExpirationDate DATE
)
BEGIN
    SELECT * FROM Reservation
    WHERE (ReservationID IS NULL OR ReservationID LIKE CONCAT('%', ReservationID, '%'))
    AND (StudentID IS NULL OR StudentID LIKE CONCAT('%', StudentID, '%'))
    AND (BookID IS NULL OR BookID LIKE CONCAT('%', BookID, '%'))
    AND (BookTitle IS NULL OR BookTitle LIKE CONCAT('%', BookTitle, '%'))
    AND (ReservationDate IS NULL OR ReservationDate = ReservationDate)
    AND (ExpirationDate IS NULL OR ExpirationDate = ExpirationDate);
END //
DELIMITER ;

-- 管理员更新预定信息
DROP PROCEDURE IF EXISTS UpdateReservationByAdmin;
DELIMITER //
CREATE PROCEDURE UpdateReservationByAdmin(
    IN p_ReservationID INT,
    IN p_StudentID VARCHAR(10),
    IN p_BookID INT,
    IN p_BookTitle VARCHAR(255),
    IN p_ReservationDate DATE,
    IN p_ExpirationDate DATE
)
BEGIN
    UPDATE Reservation SET
    ReservationID = p_ReservationID,
    StudentID = p_StudentID,
    BookID = p_BookID,
    BookTitle = p_BookTitle,
    ReservationDate = p_ReservationDate,
    ExpirationDate = p_ExpirationDate
    WHERE ReservationID = p_ReservationID;
END //
DELIMITER ;

-- 插入预定信息
DROP PROCEDURE IF EXISTS InsertReservation;
DELIMITER //
CREATE PROCEDURE InsertReservation(
    IN p_StudentID VARCHAR(10),
    IN p_BookID INT,
    IN p_BookTitle VARCHAR(255),
    IN p_ReservationDate DATE,
    IN p_ExpirationDate DATE
)
BEGIN
    INSERT INTO Reservation (StudentID, BookID, BookTitle, ReservationDate, ExpirationDate)
    VALUES (p_StudentID, p_BookID, p_BookTitle, p_ReservationDate, p_ExpirationDate);
END //
DELIMITER ;

