use libsystem;
/*
CREATE TABLE Book (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Author VARCHAR(255) NOT NULL,
    Publisher VARCHAR(255),
    YearPublished YEAR,
    ISBN VARCHAR(20),
    CopiesAvailable INT DEFAULT 0
);
*/
-- 插入图书信息;
DROP PROCEDURE IF EXISTS InsertBook;
DELIMITER //
CREATE PROCEDURE InsertBook(
    IN p_Title VARCHAR(255),
    IN p_Author VARCHAR(255),
    IN p_Publisher VARCHAR(255),
    IN p_YearPublished YEAR,
    IN p_ISBN VARCHAR(20),
    IN p_CopiesAvailable INT
)
BEGIN
    INSERT INTO Book (Title, Author, Publisher, YearPublished, ISBN, CopiesAvailable)
    VALUES (p_Title, p_Author, p_Publisher, p_YearPublished, p_ISBN, p_CopiesAvailable);
END //
DELIMITER ;

-- 删除图书信息
DROP PROCEDURE IF EXISTS DeleteBook;
DELIMITER //
CREATE PROCEDURE DeleteBook(
    IN p_BookID INT
)
BEGIN
    DELETE FROM Book WHERE BookID = p_BookID;
END //
DELIMITER ;

-- 更新图书信息
DROP PROCEDURE IF EXISTS UpdateBookBySuperAdmin;
DELIMITER //
CREATE PROCEDURE UpdateBookBySuperAdmin(
    IN p_BookID INT,
    IN p_Title VARCHAR(255),
    IN p_Author VARCHAR(255),
    IN p_Publisher VARCHAR(255),
    IN p_YearPublished YEAR,
    IN p_ISBN VARCHAR(20),
    IN p_CopiesAvailable INT
)
BEGIN
    UPDATE Book SET
    BookID = p_BookID,
    Title = p_Title,
    Author = p_Author,
    Publisher = p_Publisher,
    YearPublished = p_YearPublished,
    ISBN = p_ISBN,
    CopiesAvailable = p_CopiesAvailable
    WHERE BookID = p_BookID;
END //
DELIMITER ;


-- 查询图书信息
DROP PROCEDURE IF EXISTS SearchBook;
DELIMITER //
CREATE PROCEDURE SearchBook(
    IN p_BookID INT,
    IN p_Title VARCHAR(255),
    IN p_Author VARCHAR(255),
    IN p_Publisher VARCHAR(255),
    IN p_YearPublished YEAR,
    IN p_ISBN VARCHAR(20)
)
BEGIN
    SELECT * FROM Book
    WHERE (p_BookID IS NULL OR BookID LIKE CONCAT('%', p_BookID, '%'))
    AND (p_Title IS NULL OR Title LIKE CONCAT('%', p_Title, '%'))
    AND (p_Author IS NULL OR Author LIKE CONCAT('%', p_Author, '%'))
    AND (p_Publisher IS NULL OR Publisher LIKE CONCAT('%', p_Publisher, '%'))
    AND (p_YearPublished IS NULL OR YearPublished = p_YearPublished)
    AND (p_ISBN IS NULL OR ISBN LIKE CONCAT('%', p_ISBN, '%'));
END //
DELIMITER ;