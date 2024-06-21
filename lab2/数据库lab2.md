# 数据库lab2

## 1.需求分析

#### 1.1 超级管理员需求

超级管理员需要具备以下功能：

- 增删改查学生信息
- 增删改查图书信息
- 增删改查借阅信息
- 增删改查预定信息
- 增删改查逾期信息
- 修改自己的基本信息

#### 1.2 学生需求

学生需要具备以下功能：

- 查询图书信息
- 预定图书
- 取消预定
- 借书
- 还书
- 查询逾期信息
- 修改自己的基本信息

## 2概要设计

### ER图

![image-20240618171117986](C:\Users\xzkyyds\AppData\Roaming\Typora\typora-user-images\image-20240618171117986.png)

## 3.数据库设计合理性分析

- 每个表都有明确的主键ID号，没有传递依赖和局部传递，满足3NF范式的设计需求

- 设计逻辑：用户类型选择——>对应的登录界面——>对应的操作界面

## 4.框架和核心代码

### 4.1.框架

- 使用B/S架构，前端使用django框架完成

### 4.2.核心代码

- url.py文件

```python
from django.urls import path
 
from . import views
 
urlpatterns = [
    path('superadmin/<int:superadmin_id>', views.superadmin_home, name='superadmin_home'),  # 超级管理员登录
    path('superadmin/<int:superadmin_id>/modify_info', views.sa_modify_info, name='sa_modify_info'),  # 修改基本信息
    path('superadmin/manage_students',views.manage_students,name='manage_students'),  #管理学生
    path('superadmin/manage_books',views.manage_books,name='manage_books'),  #管理图书
    path('superadmin/manage_overdue',views.manage_overdue,name='manage_overdue'),#管理逾期信息
    path('superadmin/manage_borrowing',views.manage_borrowing,name='manage_borrowing'),    #查询借阅信息
    path('superadmin/manage_reserve',views.manage_reserve,name='manage_reserve'),    #查询预约信息

    
    path('student/<str:student_id>/', views.student_home, name='student_home'), # 学生登录
    path('student/<str:student_id>/modify_info', views.st_modify_info, name='st_modify_info'),  # 修改基本信息 
    path('student/<str:student_id>/borrowing_info', views.st_borrowing_info, name='st_borrowing_info'),  # 查询借阅信息
    path('student/<str:student_id>/overdue_info', views.st_overdue_info, name='st_overdue_info'),  # 查询逾期信息  
    path('student/<str:student_id>/reserve_info', views.st_reserve_info, name='st_reserve_info'),  # 查询预约信息
    path('student/<str:student_id>/search_books', views.st_search_books, name='st_search_books'),  # 查询图书
]
```

- views.py文件

```python
from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.db import connection
from django.urls import reverse
from django.views.decorators.csrf import csrf_protect
from django.http import HttpResponseNotFound
from django.contrib import messages
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from django.views.decorators.http import require_http_methods

def superadmin_home(request,superadmin_id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT SuperAdminID, Name, Email FROM superadmin where SuperAdminID = %s", [superadmin_id])
        superadmin_data = cursor.fetchone()
    context = {
        'superadminid': superadmin_data[0],      # SuperAdminID 对应元组中的第一个元素
        'superadminname': superadmin_data[1],    # Name 对应元组中的第二个元素
        'email': superadmin_data[2],             # Email 对应元组中的第三个元素
    }
    return render(request, 'superadmin/superadmin.html',context)

def sa_modify_info(request,superadmin_id):
    if request.method == 'POST':
        Name = request.POST.get('p_Name')
        Email = request.POST.get('p_Email')
        Password = request.POST.get('p_Password')
        PasswordConfirmation = request.POST.get('p_PasswordConfirmation')
        try:
            with connection.cursor() as cursor:
                cursor.callproc('UpdateSuperAdmin', [superadmin_id, Name, Email, Password, PasswordConfirmation])
                messages.success(request, '修改成功')
                return redirect('superadmin_login')
        except Exception as e:
            error_message = str(e)
            if 'Invalid password' in error_message:
                messages.error(request, 'Invalid password')
            else:
                messages.error(request, '操作失败，请重试或联系管理员')
    return render(request, 'superadmin/modify_info.html')


def manage_students(request):
    student_list = []
    if request.method == 'GET':
        # 获取查询参数
        student_id = request.GET.get('student_id')
        name = request.GET.get('name')
        department = request.GET.get('department')
        email = request.GET.get('email')
        canborrow = request.GET.get('canborrow')
        if not student_id:
            student_id = None
        if not name:
            name = None
        if not department:
            department = None
        if not email:
            email = None
        if canborrow == 'true':
            canborrow = True
        elif canborrow == 'false':
            canborrow = False
        else:
            canborrow = None            

        with connection.cursor() as cursor:
            cursor.callproc('SearchStudent',[student_id,name,department,email,canborrow])
            student_list = cursor.fetchall()

        context = {
            'student_list': student_list,
        }
        return render(request, 'superadmin/manage_students.html', context)

    elif request.method == 'POST':
        action = request.POST.get('action')
        if action == 'edit':
            student_id = request.POST.get('student_id')
            # 修改学生信息
            name = request.POST.get('edit_name')
            department = request.POST.get('edit_department')
            email = request.POST.get('edit_email')
            canborrow = request.POST.get('edit_borrowable')
            if canborrow == 'false':
                canborrow = False
            else:
                canborrow = True
            print(student_id, name, department, email, canborrow)
            with connection.cursor() as cursor:
                try:
                    cursor.callproc('UpdateStudentBySuperAdmin', [student_id, name, department, email, canborrow])
                    messages.success(request, '成功修改学生信息')
                except Exception as e:
                    messages.error(request, f'修改学生信息失败: {str(e)}')
            return redirect('manage_students')
        
        elif action == 'delete':
            student_id = request.POST.get('student_id')
            # 执行删除操作
            with connection.cursor() as cursor:
                try:
                    cursor.callproc('DeleteStudent', [student_id])
                    messages.success(request, '成功删除学生信息')
                except Exception as e:
                    messages.error(request, f'删除学生信息失败: {str(e)}')
            return redirect('manage_students')

        elif action == 'add':
            student_id = request.POST.get('student_id')
            name = request.POST.get('name')
            department = request.POST.get('department')
            email = request.POST.get('email')
            password = request.POST.get('password')
            password_confirmation = request.POST.get('confirm_password')
            # 执行添加学生操作
            with connection.cursor() as cursor:
                try:
                    cursor.callproc('InsertStudent', [student_id, name, department, email, password, password_confirmation,True])
                    messages.success(request, '成功添加学生信息')
                except Exception as e:
                    messages.error(request, f'添加学生信息失败: {str(e)}')
            return redirect('manage_students')

    return render(request, 'superadmin/manage_students.html')
```

- 有关学生信息存储过程的sql文件

```sql
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
```

- 管理学生界面的html模版

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理学生</title>
    <!-- Bootstrap CSS -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container">
        <h1>管理学生</h1>
        <!-- 错误信息展示 -->
        {% if messages %}
            <div class="alert alert-danger mt-3" role="alert">
                {% for message in messages %}
                    {{ message }}
                    <br>
                {% endfor %}
            </div>
        {% endif %}
        <!-- 查询学生表单 -->
        <h2>查询学生</h2>
        <form method="get">
            <div class="form-group">
                <label for="student_id">学生ID</label>
                <input type="text" class="form-control" id="student_id" name="student_id">
            </div>
            <div class="form-group">
                <label for="name">姓名</label>
                <input type="text" class="form-control" id="name" name="name">
            </div>
            <div class="form-group">
                <label for="department">部门</label>
                <input type="text" class="form-control" id="department" name="department">
            </div>
            <div class="form-group">
                <label for="email">邮箱</label>
                <input type="email" class="form-control" id="email" name="email">
            </div>
            <div class="form-group">
                <label for="borrowable">可借状态</label>
                <select class="form-control" id="borrowable" name="canborrow">
                    <option value="all">全部</option>
                    <option value="true">可借</option>
                    <option value="false">不可借</option>
                </select>
            </div>    
            <button type="submit" class="btn btn-primary">搜索</button>
        </form>

        <!-- 学生列表 -->
<h2>学生列表</h2>
<table class="table table-striped">
    <thead>
    <tr>
        <th scope="col">学生ID</th>
        <th scope="col">姓名</th>
        <th scope="col">部门</th>
        <th scope="col">邮箱</th>
        <th scope="col">可借状态</th>
        <th scope="col">修改</th>
        <th scope="col">注销</th>
    </tr>
    </thead>
        <tbody>
        {% if student_list %}
            {% for student in student_list %}
            <tr>
                <td>{{ student.0 }}</td>
                <td>{{ student.1 }}</td>
                <td>{{ student.2 }}</td>
                <td>{{ student.3 }}</td>
                <td>{% if student.5 %}是{% else %}否{% endif %}</td>
                <td>
                    <!-- 显示编辑表单 -->
                    <button class="btn btn-primary btn-sm" onclick="toggleEditForm('{{ student.0 }}')">修改信息</button>
                </td>
                <td>
                    <!-- 删除学生表单 -->
                    <form method="post" class="mr-1">
                        {% csrf_token %}
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="student_id" value="{{ student.0 }}">
                        <button type="submit" class="btn btn-danger btn-sm">注销</button>
                    </form>
                </td>
            </tr>
            <tr id="edit-form-{{ student.0 }}" style="display:none;">
                <td colspan="7">
                    <!-- 编辑学生信息表单 -->
                    <form method="post">
                        {% csrf_token %}
                        <input type="hidden" name="action" value="edit">
                        <input type="hidden" name="student_id" value="{{ student.0 }}">
                        <div class="form-row">
                            <div class="form-group col-md-3">
                                <label for="edit_name_{{ student.0 }}">姓名</label>
                                <input type="text" class="form-control" id="edit_name_{{ student.0 }}" name="edit_name" value="{{ student.1 }}" required>
                            </div>
                            <div class="form-group col-md-3">
                                <label for="edit_department_{{ student.0 }}">部门</label>
                                <input type="text" class="form-control" id="edit_department_{{ student.0 }}" name="edit_department" value="{{ student.2 }}">
                            </div>
                            <div class="form-group col-md-3">
                                <label for="edit_email_{{ student.0 }}">邮箱</label>
                                <input type="email" class="form-control" id="edit_email_{{ student.0 }}" name="edit_email" value="{{ student.3 }}" required>
                            </div>
                            <div class="form-group col-md-3">
                                <label for="edit_borrowable_{{ student.0 }}">可借状态</label>
                                <select class="form-control" id="edit_borrowable_{{ student.0 }}" name="edit_borrowable">
                                    <option value="true" {% if student.5 %}selected{% endif %}>可借</option>
                                    <option value="false" {% if not student.5 %}selected{% endif %}>不可借</option>
                                </select>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary btn-sm">保存</button>
                    </form>
                </td>
            </tr>
            {% endfor %}
        {% else %}
            <tr>
                <td colspan="7">暂无学生信息</td>
            </tr>
        {% endif %}
        </tbody>
    </table>

    <script>
    function toggleEditForm(studentId) {
        var form = document.getElementById('edit-form-' + studentId);
        if (form.style.display === 'none') {
            form.style.display = 'table-row';
        } else {
            form.style.display = 'none';
        }
    }
    </script>


        <!-- 添加学生表单 -->
        <h2>添加学生</h2>
        <form method="post">
            {% csrf_token %}
            <input type="hidden" name="action" value="add">
            <div class="form-group">
                <label for="student_id">学生ID</label>
                <input type="text" class="form-control" id="student_id" name="student_id" pattern="^PB[0-9]{8}$" required>
                <small id="student_id_help" class="form-text text-muted">格式为 PB + 8 位数字</small>
            </div>
            <div class="form-group">
                <label for="name">姓名</label>
                <input type="text" class="form-control" id="name" name="name" required>
            </div>
            <div class="form-group">
                <label for="department">部门</label>
                <input type="text" class="form-control" id="department" name="department">
            </div>
            <div class="form-group">
                <label for="email">邮箱</label>
                <input type="email" class="form-control" id="email" name="email" required>
            </div>
            <div class="form-group">
                <label for="password">密码</label>
                <input type="password" class="form-control" id="password" name="password" required>
            </div>
            <div class="form-group">
                <label for="confirm_password">确认密码</label>
                <input type="password" class="form-control" id="confirm_password" name="confirm_password" required>
            </div>
            <button type="submit" class="btn btn-success">添加学生</button>
        </form>

        
    </div>
</body>
</html>
```
## 5.项目运行演示

- 登录页面可进行管理员和学生两种身份的登录

![](C:\Users\xzkyyds\Desktop\lesson\db\lab\lab2\image\3W30N8}FV8TT`ICGKHELX$T.png)

![](C:\Users\xzkyyds\Desktop\lesson\db\lab\lab2\image\LANEB$~4]@I`ZF5V]}5_MU4.png)

![](C:\Users\xzkyyds\Desktop\lesson\db\lab\lab2\image\L((L6ZK4Z5}1JU45X38)RPY.png)


- 学生可以进行修改基本信息，借书预约，取消预约，查询书籍，预约信息，借书信息，逾期信息的功能

![](C:\Users\xzkyyds\Desktop\lesson\db\lab\lab2\image\6Z_%Y~}IA78IN7$SJX@[53V.png)

![](C:\Users\xzkyyds\Desktop\lesson\db\lab\lab2\image\3.png)

- 管理员可以增删改查绝大部分信息

![](C:\Users\xzkyyds\Desktop\lesson\db\lab\lab2\image\$8AC~{2SZ2VAD$UCWZJ9X@5.png)

![](C:\Users\xzkyyds\Desktop\lesson\db\lab\lab2\image\1.png)

![](C:\Users\xzkyyds\Desktop\lesson\db\lab\lab2\image\2.png)
