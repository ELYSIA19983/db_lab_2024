use libsystem;
/*CREATE TABLE Borrowing (
    BorrowID INT AUTO_INCREMENT PRIMARY KEY,
    StudentID INT,
    BookID INT,
    BorrowDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (BookID) REFERENCES Book(BookID)
);*/

-- 学生插入借阅信息，借书日期为当天，预定归还日期为一个月后
DROP PROCEDURE IF EXISTS InsertBorrowing;
DELIMITER //
CREATE PROCEDURE InsertBorrowing(
    IN p_StudentID VARCHAR(10),
    IN p_BookID INT
)
BEGIN
	DECLARE v_BorrowDate DATE;
    DECLARE v_DueDate DATE;
    DECLARE v_BookTitle VARCHAR(255);
    -- 如果该图书可借阅数为0则不可借阅；
    IF (SELECT CopiesAvailable FROM Book WHERE BookID = p_BookID) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This book is not available.';
    END IF;
    
    -- 没还书前，不允许同一个读者重复借阅同一本书
    IF EXISTS (SELECT * FROM Borrowing WHERE StudentID = p_StudentID AND BookID = p_BookID AND ReturnDate IS NULL) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You have borrowed this book.';
    END IF;
    -- 一个读者最多只能借阅 3 本图书
    IF (SELECT COUNT(*) FROM Borrowing WHERE StudentID = p_StudentID AND ReturnDate IS NULL) >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You have borrowed too many books.';
    END IF;
    
    -- 设置借书日期为当天
    SET v_BorrowDate = CURDATE();
    
    -- 设置预定归还日期为一个月后
    SET v_DueDate = DATE_ADD(v_BorrowDate, INTERVAL 1 MONTH);
    
    SET v_BookTitle = (SELECT Title FROM Book WHERE BookID = p_BookID);
    -- 插入借阅信息
    INSERT INTO Borrowing (StudentID, BookID, BookTitle,BorrowDate, DueDate)
    VALUES (p_StudentID, p_BookID,v_BookTitle, v_BorrowDate, v_DueDate);
END //
DELIMITER ;

-- 借书时触发触发器是该图书可借阅数减一
DROP TRIGGER IF EXISTS BorrowingTrigger;
DELIMITER //
CREATE TRIGGER BorrowingTrigger
AFTER INSERT ON Borrowing
FOR EACH ROW
BEGIN
    UPDATE Book SET CopiesAvailable = CopiesAvailable - 1
    WHERE BookID = NEW.BookID;
END //
DELIMITER ;

-- 借书时删除对应预定信息
DROP TRIGGER IF EXISTS BorrowingTrigger2;
DELIMITER //
CREATE TRIGGER BorrowingTrigger2
AFTER INSERT ON Borrowing
FOR EACH ROW
BEGIN
    DELETE FROM Reservation WHERE StudentID = NEW.StudentID AND BookID = NEW.BookID;
END //
DELIMITER ;

-- 归还书籍
DROP PROCEDURE IF EXISTS ReturnBook;
DELIMITER //
CREATE PROCEDURE ReturnBook(
    IN p_BorrowID INT
)
BEGIN
    UPDATE Borrowing SET ReturnDate = CURDATE()
    WHERE BorrowID = p_BorrowID;
    -- 该图书可借阅数加一
    UPDATE Book SET CopiesAvailable = CopiesAvailable + 1
    WHERE BookID = (SELECT BookID FROM Borrowing WHERE BorrowID = p_BorrowID);
END //
DELIMITER ;

-- 查询借阅信息
DROP PROCEDURE IF EXISTS SearchBorrowing;
DELIMITER //
CREATE PROCEDURE SearchBorrowing(
    IN p_BorrowID INT,
    IN p_StudentID VARCHAR(10),
    IN p_BookID INT,
    IN p_BookTitle VARCHAR(255),
    IN p_BorrowDate DATE,
    IN p_DueDate DATE,
    IN p_ReturnDate DATE
)
BEGIN
    SELECT * FROM Borrowing
    WHERE (p_BorrowID IS NULL OR BorrowID LIKE CONCAT('%', p_BorrowID, '%'))
    AND (p_StudentID IS NULL OR StudentID LIKE CONCAT('%', p_StudentID, '%'))
    AND (p_BookID IS NULL OR BookID LIKE CONCAT('%', p_BookID, '%'))
    AND (p_BookTitle IS NULL OR BookTitle LIKE CONCAT('%', p_BookTitle, '%'))
    AND (p_BorrowDate IS NULL OR BorrowDate = p_BorrowDate)
    AND (p_DueDate IS NULL OR DueDate = p_DueDate)
    AND (p_ReturnDate IS NULL OR ReturnDate = p_ReturnDate);
END //
DELIMITER ;

-- 管理员更新借阅信息
DROP PROCEDURE IF EXISTS UpdateBorrowingByAdmin;
DELIMITER //
CREATE PROCEDURE UpdateBorrowingByAdmin(
    IN p_BorrowID INT,
    IN p_StudentID VARCHAR(10),
    IN p_BookID INT,
    IN p_BorrowDate DATE,
    IN p_DueDate DATE,
    IN p_ReturnDate DATE
)
BEGIN
    UPDATE Borrowing SET
    BorrowID = p_BorrowID,
    StudentID = p_StudentID,
    BookID = p_BookID,
    BorrowDate = p_BorrowDate,
    DueDate = p_DueDate,
    ReturnDate = p_ReturnDate
    WHERE BorrowID = p_BorrowID;
END //
DELIMITER ;

-- 删除借阅信息
DROP PROCEDURE IF EXISTS DeleteBorrowing;
DELIMITER //
CREATE PROCEDURE DeleteBorrowing(
    IN p_BorrowID INT
)
BEGIN
    DELETE FROM Borrowing WHERE BorrowID = p_BorrowID;
END //
DELIMITER ;

-- 管理员添加借阅信息
DROP PROCEDURE IF EXISTS InsertBorrowingByAdmin;
DELIMITER //
CREATE PROCEDURE InsertBorrowingByAdmin(
    IN p_StudentID VARCHAR(10),
    IN p_BookID INT,
    IN p_BookTitle VARCHAR(255),
    IN p_BorrowDate DATE,
    IN p_DueDate DATE,
    IN p_ReturnDate DATE
)
BEGIN
    INSERT INTO Borrowing (StudentID, BookID, BookTitle, BorrowDate, DueDate, ReturnDate)
    VALUES (p_StudentID, p_BookID, p_BookTitle, p_BorrowDate, p_DueDate, p_ReturnDate);
END //
DELIMITER ;