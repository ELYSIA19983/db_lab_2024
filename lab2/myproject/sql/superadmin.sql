use libsystem;
/*CREATE TABLE SuperAdmin (
    SuperAdminID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(20) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    CHECK (Email REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
);*/
-- 插入超级管理员信息表
DROP PROCEDURE IF EXISTS InsertSuperAdmin;
DELIMITER //
CREATE PROCEDURE InsertSuperAdmin(
    IN p_Name VARCHAR(20),
    IN p_Email VARCHAR(255),
    IN p_Password VARCHAR(255),
    IN p_PasswordConfirmation VARCHAR(255)
)
BEGIN
    IF p_Password <> '' AND p_Password = p_PasswordConfirmation THEN
        INSERT INTO SuperAdmin (Name, Email, Password)
        VALUES (p_Name, p_Email, p_Password);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid password';
    END IF;
END //
DELIMITER ;

-- 删除超级管理员信息表
DROP PROCEDURE IF EXISTS DeleteSuperAdmin;
DELIMITER //
CREATE PROCEDURE DeleteSuperAdmin(
    IN p_SuperAdminID INT
)
BEGIN
    DELETE FROM SuperAdmin WHERE SuperAdminID = p_SuperAdminID;
END //
DELIMITER ;

-- 更新超级管理员信息表
DROP PROCEDURE IF EXISTS UpdateSuperAdmin;
DELIMITER //
CREATE PROCEDURE UpdateSuperAdmin(
    IN p_SuperAdminID INT,
    IN p_Name VARCHAR(20),
    IN p_Email VARCHAR(255),
    IN p_Password VARCHAR(255),
    IN p_PasswordConfirmation VARCHAR(255)
)
BEGIN
    IF p_Password <> '' AND p_Password = p_PasswordConfirmation THEN
        UPDATE SuperAdmin SET Name = p_Name, Email = p_Email, Password = p_Password
        WHERE SuperAdminID = p_SuperAdminID;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid password';
    END IF;
END //
DELIMITER ;

-- 查询所有超级管理员信息表
DROP PROCEDURE IF EXISTS SelectSuperAdmin;
DELIMITER //
CREATE PROCEDURE SelectSuperAdmin()
BEGIN
    SELECT * FROM SuperAdmin;
END //
DELIMITER ;


