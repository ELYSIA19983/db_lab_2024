-- 创建数据库
DROP DATABASE IF EXISTS libsystem;
CREATE DATABASE libsystem;

-- 使用数据库
USE libsystem;
SET GLOBAL event_scheduler = ON;

-- 创建图书信息表
DROP TABLE IF EXISTS Book;
CREATE TABLE Book (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Author VARCHAR(255) NOT NULL,
    Publisher VARCHAR(255),
    YearPublished YEAR,
    ISBN VARCHAR(20),
    CopiesAvailable INT DEFAULT 0
);

-- 创建超级管理员信息表
DROP TABLE IF EXISTS SuperAdmin;
CREATE TABLE SuperAdmin (
    SuperAdminID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(20) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL
);

-- 创建学生信息表
DROP TABLE IF EXISTS Student;
CREATE TABLE Student (
    StudentID VARCHAR(10) PRIMARY KEY,  -- 格式为 PB + 8 位数字
    Name VARCHAR(20) NOT NULL,
    Department VARCHAR(255),
    Email VARCHAR(255) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    CanBorrow BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (StudentID REGEXP '^PB[0-9]{8}$')
);

-- 创建学生借阅信息表
DROP TABLE IF EXISTS Borrowing;
CREATE TABLE Borrowing (
    BorrowID INT AUTO_INCREMENT PRIMARY KEY,
    StudentID VARCHAR(10),
    BookID INT,
    BookTitle VARCHAR(255),
    BorrowDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE CASCADE,
    FOREIGN KEY (BookID) REFERENCES Book(BookID) ON DELETE CASCADE
);

-- 创建学生预定信息表
DROP TABLE IF EXISTS Reservation;
CREATE TABLE Reservation (
    ReservationID INT AUTO_INCREMENT PRIMARY KEY,
    StudentID VARCHAR(10),
    BookID INT,
    BookTitle VARCHAR(255),
    ReservationDate DATE NOT NULL,
    ExpirationDate DATE NOT NULL,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE CASCADE,
    FOREIGN KEY (BookID) REFERENCES Book(BookID) ON DELETE CASCADE
);

-- 创建学生借阅违期信息表
DROP TABLE IF EXISTS Overdue;
CREATE TABLE Overdue (
    OverdueID INT AUTO_INCREMENT PRIMARY KEY,
    BorrowID INT,
    BookTitle VARCHAR(255),
    FineAmount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (BorrowID) REFERENCES Borrowing(BorrowID) ON DELETE CASCADE
);
ALTER TABLE Overdue ADD UNIQUE (BorrowID);

