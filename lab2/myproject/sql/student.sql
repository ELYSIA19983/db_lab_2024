USE libsystem;
/*
-- 学生信息表
DROP TABLE IF EXISTS Student;
CREATE TABLE Student (
    StudentID VARCHAR(9) PRIMARY KEY,  -- 格式为 PB + 7 位数字
    Name VARCHAR(20) NOT NULL,
    Department VARCHAR(255),
    Email VARCHAR(255) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    CanBorrow BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (StudentID REGEXP '^PB[0-9]{7}$'),
    CHECK (Email REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
);
*/
-- 存储学生信息的存储过程，加入验证密码的功能
DROP PROCEDURE IF EXISTS InsertStudent;
DELIMITER //
CREATE PROCEDURE InsertStudent(
    IN p_StudentID VARCHAR(10),
    IN p_Name VARCHAR(20),
    IN p_Department VARCHAR(255),
    IN p_Email VARCHAR(255),
    IN p_Password VARCHAR(255),
    IN p_PasswordConfirmation VARCHAR(255),
    IN p_CanBorrow BOOLEAN
)
BEGIN
    IF p_Password <> '' AND p_Password = p_PasswordConfirmation THEN
        INSERT INTO Student (StudentID, Name, Department, Email, Password, CanBorrow)
        VALUES (p_StudentID, p_Name, p_Department, p_Email, p_Password, p_CanBorrow);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid password';
    END IF;
END //

DELIMITER ;


-- 注销学生信息的存储过程
DROP PROCEDURE IF EXISTS DeleteStudent;
DELIMITER //
CREATE PROCEDURE DeleteStudent(
    IN p_StudentID VARCHAR(10)
)
BEGIN
    DELETE FROM Student WHERE StudentID = p_StudentID;
END //

DELIMITER ;

-- 更新学生信息的存储过程
DROP PROCEDURE IF EXISTS UpdateStudent;
DELIMITER //
/*id不可更改*/
CREATE PROCEDURE UpdateStudent(
    IN p_StudentID VARCHAR(10),
    IN p_Name VARCHAR(20),
    IN p_Department VARCHAR(255),
    IN p_Email VARCHAR(255),
    IN p_Password VARCHAR(255),
    IN p_PasswordConfirmation VARCHAR(255),
    IN p_CanBorrow BOOLEAN
)
BEGIN
    -- 如果输入了密码，且密码和确认密码相同，则更新密码
    IF p_Password <> '' AND p_Password = p_PasswordConfirmation THEN
        UPDATE Student 
        SET Name = p_Name, 
            Department = p_Department, 
            Email = p_Email, 
            Password = p_Password, 
            CanBorrow = p_CanBorrow
        WHERE StudentID = p_StudentID;
    -- 否则，抛出异常
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid password';
    END IF;
END //
DELIMITER ;
-- 超级管理员更新学生信息的存储过程
DROP PROCEDURE IF EXISTS UpdateStudentBySuperAdmin;
DELIMITER //
CREATE PROCEDURE UpdateStudentBySuperAdmin(
    IN p_StudentID VARCHAR(10),
    IN p_Name VARCHAR(20),
    IN p_Department VARCHAR(255),
    IN p_Email VARCHAR(255),
    IN p_CanBorrow BOOLEAN
)
BEGIN
    UPDATE Student 
    SET StudentID = p_StudentID,
        Name = p_Name, 
        Department = p_Department, 
        Email = p_Email, 
        CanBorrow = p_CanBorrow
    WHERE StudentID = p_StudentID;
END //
DELIMITER ;

-- 查询学生信息的存储过程
DROP PROCEDURE IF EXISTS SearchStudent;
DELIMITER //
CREATE PROCEDURE SearchStudent(
    IN p_StudentID VARCHAR(10),
    IN p_Name VARCHAR(20),
    IN p_Department VARCHAR(255),
    IN p_Email VARCHAR(255),
    IN p_CanBorrow BOOLEAN
)
BEGIN
    SELECT * FROM Student
    WHERE (p_StudentID IS NULL OR StudentID LIKE CONCAT('%', p_StudentID, '%'))
    AND (p_Name IS NULL OR Name LIKE CONCAT('%', p_Name, '%'))
    AND (p_Department IS NULL OR Department LIKE CONCAT('%', p_Department, '%'))
    AND (p_Email IS NULL OR Email LIKE CONCAT('%', p_Email, '%'))
    AND (p_CanBorrow IS NULL OR CanBorrow = p_CanBorrow);
END //
DELIMITER ;