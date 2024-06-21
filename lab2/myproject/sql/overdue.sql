use libsystem;
SET GLOBAL event_scheduler = ON;

/*CREATE TABLE Overdue (
    OverdueID INT AUTO_INCREMENT PRIMARY KEY,
    BorrowID INT,
    FineAmount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (BorrowID) REFERENCES Borrowing(BorrowID)
);*/
-- 当超过预定还书日期未还书时，插入逾期信息，使用事件调度
DROP EVENT IF EXISTS InsertOverdue;

CREATE EVENT InsertOverdue
ON SCHEDULE EVERY 1 SECOND
DO
    INSERT ignore Overdue (BorrowID, BookTitle, FineAmount)
    SELECT BorrowID, BookTitle, DATEDIFF(CURDATE(), DueDate) * 0.5
    FROM Borrowing
    WHERE DueDate < CURDATE() AND ReturnDate IS NULL;
	
-- 插入逾期信息时，触发触发器使逾期学生的canborrow属性为false
DROP TRIGGER IF EXISTS InsertOverdueTrigger;
DELIMITER //
CREATE TRIGGER InsertOverdueTrigger
AFTER INSERT ON Overdue
FOR EACH ROW
BEGIN
    UPDATE Student SET CanBorrow = FALSE
    WHERE StudentID = (SELECT StudentID FROM Borrowing WHERE BorrowID = NEW.BorrowID);
END //
DELIMITER ;

-- 当删除逾期信息时，检查学生是否有逾期信息，若没有，触发触发器使逾期学生的canborrow属性为true
DROP TRIGGER IF EXISTS DeleteOverdueTrigger;
DELIMITER //
CREATE TRIGGER DeleteOverdueTrigger
AFTER DELETE ON Overdue
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT * FROM Overdue WHERE BorrowID = OLD.BorrowID) THEN
        UPDATE Student SET CanBorrow = TRUE
        WHERE StudentID = (SELECT StudentID FROM Borrowing WHERE BorrowID = OLD.BorrowID);
    END IF;
END //
DELIMITER ;
-- 插入逾期信息
DROP PROCEDURE IF EXISTS InsertOverdue;
DELIMITER //
CREATE PROCEDURE InsertOverdue(
    IN p_BorrowID INT,
    IN p_BookTitle VARCHAR(255),
    IN p_FineAmount DECIMAL(10, 2)
)
BEGIN
    INSERT INTO Overdue (BorrowID, BookTitle, FineAmount)
    VALUES (p_BorrowID, p_BookTitle, p_FineAmount);
END //
DELIMITER ;
-- 删除逾期信息
DROP PROCEDURE IF EXISTS DeleteOverdue;
DELIMITER //
CREATE PROCEDURE DeleteOverdue(
    IN p_OverdueID INT
)
BEGIN
    DELETE FROM Overdue WHERE OverdueID = p_OverdueID;
END //
DELIMITER ;

-- 查询某个学生的逾期信息
DROP PROCEDURE IF EXISTS SelectOverdue;
DELIMITER //
CREATE PROCEDURE SelectOverdue(
    IN p_StudentID VARCHAR(10)
)
BEGIN
    SELECT * FROM Overdue WHERE BorrowID IN (SELECT BorrowID FROM Borrowing WHERE StudentID = p_StudentID);
END //
DELIMITER ;

-- 查询逾期信息
DROP PROCEDURE IF EXISTS SearchOverdue;
DELIMITER //
CREATE PROCEDURE SearchOverdue(
    IN p_OverdueID INT,
    IN p_BorrowID INT,
    IN p_BookTitle VARCHAR(255),
    IN p_FineAmount DECIMAL(10, 2)
)
BEGIN
    SELECT * FROM Overdue
    WHERE (p_OverdueID IS NULL OR OverdueID LIKE CONCAT('%', p_OverdueID, '%'))
    AND (p_BorrowID IS NULL OR BorrowID LIKE CONCAT('%', p_BorrowID, '%'))
    AND (p_BookTitle IS NULL OR BookTitle LIKE CONCAT('%', p_BookTitle, '%'))
    AND (p_FineAmount IS NULL OR FineAmount LIKE CONCAT('%', p_FineAmount, '%'));
END //
DELIMITER ;
-- 更新逾期信息
DROP PROCEDURE IF EXISTS UpdateOverdue;
DELIMITER //
CREATE PROCEDURE UpdateOverdue(
    IN p_OverdueID INT,
    IN p_BorrowID INT,
    IN p_BookTitle VARCHAR(255),
    IN p_FineAmount DECIMAL(10, 2)
)
BEGIN
    UPDATE Overdue SET
    BorrowID = p_BorrowID,
    BookTitle = p_BookTitle,
    FineAmount = p_FineAmount
    WHERE OverdueID = p_OverdueID;
END //