-- 插入学生信息，管理员信息，超级管理员信息
use libsystem;
INSERT INTO SuperAdmin (Name, Email, Password)
VALUES ('Alice', 'alice@admin.com', 's1');
INSERT INTO Student (StudentID, Name, Department, Email, Password)
VALUES ('PB21111651', '胡磊', '计算机科学与技术', 'hulei651@mail.ustc.edu.cn', '123456');
INSERT INTO Student (StudentID, Name, Department, Email, Password, CanBorrow) VALUES
('PB00000001', '学生一号', '计算机', 'one@edu.cn', 'pass1', TRUE),
('PB00000002', '学生二号', '计算机', 'two@edu.cn', 'pass2', TRUE),
('PB00000003', '学生三号', '计算机', 'three@edu.cn', 'pass3', TRUE),
('PB00000004', '学生四号', '计算机', 'four@edu.cn', 'pass4', TRUE),
('PB00000005', '学生五号', '计算机', 'five@edu.cn', 'pass5', TRUE),
('PB00000006', '学生六号', '计算机', 'six@edu.cn', 'pass6', TRUE),
('PB00000007', '学生七号', '计算机', 'seven@edu.cn', 'pass7', TRUE),
('PB00000008', '学生八号', '计算机', 'eight@edu.cn', 'pass8', TRUE),
('PB00000009', '学生九号', '计算机', 'nine@edu.cn', 'pass9', TRUE),
('PB00000010', '学生十号', '计算机', 'ten@edu.cn', 'pass10', TRUE);


INSERT INTO Book (Title, Author, Publisher, YearPublished, ISBN, CopiesAvailable) VALUES
('活着', '余华', '作家出版社', 1993, '9787506365437', 5),
('围城', '钱锺书', '人民文学出版社', 1947, '9787020003672', 3),
('红楼梦', '曹雪芹', '人民文学出版社', 1991, '9787020002200', 7),
('平凡的世界', '路遥', '人民文学出版社', 1986, '9787020024776', 4),
('白鹿原', '陈忠实', '人民文学出版社', 1993, '9787020003603', 2),
('三体', '刘慈欣', '重庆出版社', 2008, '9787229003585', 6),
('弟子规', '李毓秀', '中华书局', 2004, '9787101020484', 10),
('西游记', '吴承恩', '人民文学出版社', 1991, '9787020021843', 5),
('射雕英雄传', '金庸', '明河社', 1957, '9789624513284', 8),
('水浒传', '施耐庵', '人民文学出版社', 1997, '9787020000000', 4),
('狼图腾', '姜戎', '长江文艺出版社', 2004, '9787535438064', 7),
('解忧杂货店', '东野圭吾', '南海出版公司', 2014, '9787544270878', 6),
('长恨歌', '王安忆', '上海文艺出版社', 1996, '9787532101238', 3),
('许三观卖血记', '余华', '作家出版社', 1995, '9787506363549', 2),
('呐喊', '鲁迅', '人民文学出版社', 1923, '9787020024758', 5),
('边城', '沈从文', '北岳文艺出版社', 1934, '9787537839500', 4),
('京华烟云', '林语堂', '湖南人民出版社', 1939, '9787556104005', 3),
('骆驼祥子', '老舍', '人民文学出版社', 1936, '9787020024758', 6),
('家', '巴金', '人民文学出版社', 1933, '9787020000000', 5),
('繁花', '金宇澄', '上海文艺出版社', 2013, '9787532146738', 7);


-- 调用存储过程插入借阅信息
CALL InsertBorrowing('PB21111651', 11);
CALL InsertBorrowing('PB21111651',12);
CALL InsertBorrowing('PB21111651',12);
CALL InsertBorrowing('PB21111651',13);
call returnbook(4);
call ReserveBook('PB21111651',13);
call searchbook(NULL,NULL,'华',NULL,NULL,NULL);
UPDATE Borrowing
SET BorrowDate = '2024-05-10', DueDate = DATE_ADD('2024-05-10', INTERVAL 1 MONTH)
WHERE BorrowID = 1;
delete from borrowing where BorrowID >0;
delete from book where bookid>0;
delete from overdue where overdueid>0;
select * from borrowing;
select * from overdue;
select * from reservation;
select * from book;
select * from superadmin;
select * from student;
use libsystem;
SHOW EVENTS;
SELECT VERSION();
SHOW VARIABLES LIKE 'event_scheduler';
