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

def manage_books(request):
    book_list = []
    if request.method == 'GET':
        # 获取查询参数
        book_id = request.GET.get('book_id')
        title = request.GET.get('title')
        author = request.GET.get('author')
        publisher = request.GET.get('publisher')
        year_published = request.GET.get('year_published')
        isbn = request.GET.get('isbn')
        if not book_id:
            book_id = None
        if not title:
            title = None
        if not author:
            author = None
        if not publisher:
            publisher = None
        if not year_published:
            year_published = None
        if not isbn:
            isbn = None
        with connection.cursor() as cursor:
            cursor.callproc('SearchBook', [book_id, title, author, publisher, year_published, isbn])
            book_list = cursor.fetchall()

        context = {
            'book_list': book_list,
        }
        return render(request, 'superadmin/manage_books.html', context)

    elif request.method == 'POST':
        action = request.POST.get('action')
        if action == 'edit':
            book_id = request.POST.get('book_id')
            # 修改图书信息
            title = request.POST.get('edit_title')
            author = request.POST.get('edit_author')
            publisher = request.POST.get('edit_publisher')
            year_published = request.POST.get('edit_year_published')
            isbn = request.POST.get('edit_isbn')
            copies_available = request.POST.get('edit_copies_available')

            with connection.cursor() as cursor:
                try:
                    cursor.callproc('UpdateBookBySuperAdmin', [book_id, title, author, publisher, year_published, isbn, copies_available])
                    messages.success(request, '成功修改图书信息')
                except Exception as e:
                    messages.error(request, f'修改图书信息失败: {str(e)}')
            return redirect('manage_books')

        elif action == 'delete':
            book_id = request.POST.get('book_id')
            # 执行删除操作
            with connection.cursor() as cursor:
                try:
                    cursor.callproc('DeleteBook', [book_id])
                    messages.success(request, '成功删除图书信息')
                except Exception as e:
                    messages.error(request, f'删除图书信息失败: {str(e)}')
            return redirect('manage_books')

        elif action == 'add':
            title = request.POST.get('title')
            author = request.POST.get('author')
            publisher = request.POST.get('publisher')
            year_published = request.POST.get('year_published')
            isbn = request.POST.get('isbn')
            copies_available = request.POST.get('copies_available')

            # 执行添加图书操作
            with connection.cursor() as cursor:
                try:
                    cursor.callproc('InsertBook', [title, author, publisher, year_published, isbn, copies_available])
                    messages.success(request, '成功添加图书信息')
                except Exception as e:
                    messages.error(request, f'添加图书信息失败: {str(e)}')
            return redirect('manage_books')

    return render(request, 'superadmin/manage_books.html')


def manage_overdue(request):
    overdue_list = []
    if request.method == 'GET':
        overdue_id = request.GET.get('overdue_id')
        borrow_id = request.GET.get('borrow_id')
        book_title = request.GET.get('book_title')
        fine_amount = request.GET.get('fine_amount')
        if not overdue_id:
            overdue_id = None
        if not borrow_id:
            borrow_id = None
        if not book_title:
            book_title = None
        if not fine_amount:
            fine_amount = None
            
        with connection.cursor() as cursor:
            cursor.callproc('SearchOverdue', [overdue_id, borrow_id,book_title, fine_amount])
            overdue_list = cursor.fetchall()

        context = {
            'overdue_list': overdue_list,
        }
        return render(request, 'superadmin/manage_overdue.html', context)

    elif request.method == 'POST':
        action = request.POST.get('action')
        if action == 'edit':
            overdue_id = request.POST.get('overdue_id')
            borrow_id = request.POST.get('edit_borrow_id')
            book_title = request.POST.get('edit_book_title')
            fine_amount = request.POST.get('edit_fine_amount')

            with connection.cursor() as cursor:
                try:
                    cursor.callproc('UpdateOverdue', [overdue_id, borrow_id, book_title, fine_amount])
                    messages.success(request, '成功修改逾期信息')
                except Exception as e:
                    messages.error(request, f'修改逾期信息失败: {str(e)}')
            return redirect('manage_overdue')

        elif action == 'delete':
            overdue_id = request.POST.get('overdue_id')

            with connection.cursor() as cursor:
                try:
                    cursor.callproc('DeleteOverdue', [overdue_id])
                    messages.success(request, '成功删除逾期信息')
                except Exception as e:
                    messages.error(request, f'删除逾期信息失败: {str(e)}')
            return redirect('manage_overdue')

        elif action == 'add':
            borrow_id = request.POST.get('borrow_id')
            book_title = request.POST.get('book_title')
            fine_amount = request.POST.get('fine_amount')

            with connection.cursor() as cursor:
                try:
                    cursor.callproc('InsertOverdue', [borrow_id, book_title, fine_amount])
                    messages.success(request, '成功添加逾期信息')
                except Exception as e:
                    messages.error(request, f'添加逾期信息失败: {str(e)}')
            return redirect('manage_overdue')

    return render(request, 'superadmin/manage_overdue.html')



def manage_borrowing(request):
    borrowing_list = []
    if request.method == 'GET':
        borrow_id = request.GET.get('borrow_id')
        student_id = request.GET.get('student_id')
        book_id = request.GET.get('book_id')
        book_title = request.GET.get('book_title')
        borrow_date = request.GET.get('borrow_date')
        due_date = request.GET.get('due_date')
        return_date = request.GET.get('return_date')
        if not borrow_id:
            borrow_id = None
        if not student_id:
            student_id = None
        if not book_id:
            book_id = None
        if not book_title:
            book_title = None
        if not borrow_date:
            borrow_date = None
        if not due_date:
            due_date = None
        if not return_date:
            return_date = None
        with connection.cursor() as cursor:
            cursor.callproc('SearchBorrowing', [borrow_id, student_id, book_id, book_title, borrow_date, due_date, return_date])
            borrowing_list = cursor.fetchall()

        context = {
            'borrowing_list': borrowing_list,
        }
        return render(request, 'superadmin/manage_borrowing.html', context)

    elif request.method == 'POST':
        action = request.POST.get('action')
        if action == 'edit':
            borrow_id = request.POST.get('borrow_id')
            student_id = request.POST.get('edit_student_id')
            book_id = request.POST.get('edit_book_id')

            borrow_date = request.POST.get('edit_borrow_date')
            due_date = request.POST.get('edit_due_date')
            return_date = request.POST.get('edit_return_date')
            if not return_date:
                return_date = None
            with connection.cursor() as cursor:
                try:
                    cursor.callproc('UpdateBorrowingByAdmin', [borrow_id, student_id, book_id,borrow_date, due_date, return_date])
                    messages.success(request, '成功修改借阅信息')
                except Exception as e:
                    messages.error(request, f'修改借阅信息失败: {str(e)}')
            return redirect('manage_borrowing')

        elif action == 'delete':
            borrow_id = request.POST.get('borrow_id')

            with connection.cursor() as cursor:
                try:
                    cursor.callproc('DeleteBorrowing', [borrow_id])
                    messages.success(request, '成功删除借阅信息')
                except Exception as e:
                    messages.error(request, f'删除借阅信息失败: {str(e)}')
            return redirect('manage_borrowing')

        elif action == 'add':
            student_id = request.POST.get('student_id')
            book_id = request.POST.get('book_id')
            book_title = request.POST.get('book_title')
            borrow_date = request.POST.get('borrow_date')
            due_date = request.POST.get('due_date')
            return_date = request.POST.get('return_date')
            if not return_date:
                return_date = None

            with connection.cursor() as cursor:
                try:
                    cursor.callproc('InsertBorrowingByAdmin', [student_id, book_id, book_title, borrow_date, due_date, return_date])
                    messages.success(request, '成功添加借阅信息')
                except Exception as e:
                    messages.error(request, f'添加借阅信息失败: {str(e)}')
            return redirect('manage_borrowing')

    return render(request, 'superadmin/manage_borrowing.html')


def manage_reserve(request):
    reserve_list = []
    if request.method == 'GET':
        reservation_id = request.GET.get('reservation_id')
        student_id = request.GET.get('student_id')
        book_id = request.GET.get('book_id')
        book_title = request.GET.get('book_title')
        reservation_date = request.GET.get('reservation_date')
        expiration_date = request.GET.get('expiration_date')
        if not reservation_id:
            reservation_id = None
        if not student_id:
            student_id = None
        if not book_id:
            book_id = None
        if not book_title:
            book_title = None
        if not reservation_date:
            reservation_date = None
        if not expiration_date:
            expiration_date = None

        with connection.cursor() as cursor:
            cursor.callproc('SearchReserve', [reservation_id, student_id, book_id, book_title, reservation_date, expiration_date])
            reserve_list = cursor.fetchall()

        context = {
            'reserve_list': reserve_list,
        }
        return render(request, 'superadmin/manage_reserve.html', context)

    elif request.method == 'POST':
        action = request.POST.get('action')
        if action == 'edit':
            reservation_id = request.POST.get('reservation_id')
            student_id = request.POST.get('edit_student_id')
            book_id = request.POST.get('edit_book_id')
            book_title = request.POST.get('edit_book_title')
            reservation_date = request.POST.get('edit_reservation_date')
            expiration_date = request.POST.get('edit_expiration_date')

            with connection.cursor() as cursor:
                try:
                    cursor.callproc('UpdateReservationByAdmin', [reservation_id, student_id, book_id, book_title, reservation_date, expiration_date])
                    messages.success(request, '成功修改预订信息')
                except Exception as e:
                    messages.error(request, f'修改预订信息失败: {str(e)}')
            return redirect('manage_reserve')

        elif action == 'delete':
            reservation_id = request.POST.get('reservation_id')

            with connection.cursor() as cursor:
                try:
                    cursor.callproc('CancelReservation', [reservation_id])
                    messages.success(request, '成功删除预订信息')
                except Exception as e:
                    messages.error(request, f'删除预订信息失败: {str(e)}')
            return redirect('manage_reserve')

        elif action == 'add':
            student_id = request.POST.get('student_id')
            book_id = request.POST.get('book_id')
            book_title = request.POST.get('book_title')
            reservation_date = request.POST.get('reservation_date')
            expiration_date = request.POST.get('expiration_date')

            with connection.cursor() as cursor:
                try:
                    cursor.callproc('InsertReservation', [student_id, book_id, book_title, reservation_date, expiration_date])
                    messages.success(request, '成功添加预订信息')
                except Exception as e:
                    messages.error(request, f'添加预订信息失败: {str(e)}')
            return redirect('manage_reserve')

    return render(request, 'superadmin/manage_reserve.html')
      

def student_home(request,student_id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT StudentID, Name, Department, Email, CanBorrow FROM student where StudentID = %s", [student_id])
        student_data = cursor.fetchone()

    context = {
        'studentid': student_data[0],      # StudentID 对应元组中的第一个元素
        'studentname': student_data[1],    # Name 对应元组中的第二个元素
        'department': student_data[2],     # Department 对应元组中的第三个元素
        'email': student_data[3],          # Email 对应元组中的第四个元素
        'canborrow': student_data[4],      # CanBorrow 对应元组中的第五个元素
    }
    return render(request, 'student/student.html', context)

def st_modify_info(request,student_id):
    #调用过程完成基本信息的修改
    if request.method == 'POST':
        Name = request.POST.get('p_Name')
        Department = request.POST.get('p_Department')
        Email = request.POST.get('p_Email')
        Password = request.POST.get('p_Password')
        PasswordConfirmation = request.POST.get('p_PasswordConfirmation')
        try:
            with connection.cursor() as cursor:
                cursor.callproc('UpdateStudent', [student_id,Name, Department, Email, Password, PasswordConfirmation,True])
                messages.success(request, '修改成功')
                redirect('student_login')
        except Exception as e:
            error_message = str(e)
            if 'Invalid password' in error_message:
                messages.error(request, 'Invalid password')
            else:
                messages.error(request, '操作失败，请重试或联系管理员')
            
    return render(request, 'student/modify_info.html')


def st_borrowing_info(request, student_id):
    if request.method == 'POST':
        borrowing_id = request.POST.get('borrowing_id')

        # 更新数据库中的归还日期
        with connection.cursor() as cursor:
            cursor.callproc('ReturnBook', [borrowing_id])

        # 重定向到借阅信息页面
        return redirect('st_borrowing_info', student_id=student_id)
    
    else:
        # GET 请求时获取借阅信息
        with connection.cursor() as cursor:
            cursor.callproc('SearchBorrowing', [None, student_id, None, None, None, None, None])
            result = cursor.fetchall()
        context = {
            'borrowing_list': result,  
        }
        return render(request, 'student/borrowing_info.html', context)

def st_overdue_info(request,student_id):
    # 调用过程完成逾期信息的查询
    with connection.cursor() as cursor:
        cursor.callproc('SelectOverdue', [student_id])
        result = cursor.fetchall()
    # 将查询到的逾期信息传递给模板的 overdue_list 变量
    context = {
        'overdue_list': result,  
    }
    return render(request, 'student/overdue_info.html', context)

def st_reserve_info(request,student_id):
    if request.method == 'POST':
        ReservationID = request.POST.get('ReservationID')

        # 更新数据库中的归还日期
        with connection.cursor() as cursor:
            cursor.callproc('CancelReservation', [ReservationID])

        # 重定向到借阅信息页面
        return redirect('st_reserve_info', student_id=student_id)
    
    else:
        with connection.cursor() as cursor:
            cursor.callproc('SearchReserve', [None,student_id,None,None,None,None])
            result = cursor.fetchall()
        context = {
            'reserve_list': result,  
        }
        return render(request, 'student/reserve_info.html', context)

@require_http_methods(["GET", "POST"])
def st_search_books(request,student_id):
    book_list = []
    if request.method == "GET":
        book_id = request.GET.get('book_id')
        title = request.GET.get('title')
        author = request.GET.get('author')
        publisher = request.GET.get('publisher')
        year_published = request.GET.get('year_published')
        isbn = request.GET.get('isbn')
        if not book_id:
            book_id = None
        if not title:
            title = None
        if not author:
            author = None
        if not publisher:
            publisher = None
        if not year_published:
            year_published = None
        if not isbn:
            isbn = None
        with connection.cursor() as cursor:
            cursor.callproc('SearchBook', [book_id, title, author, publisher, year_published, isbn])
            book_list = cursor.fetchall()
    
    if request.method == "POST":
        action = request.POST.get('action')
        book_id = request.POST.get('book_id')

        with connection.cursor() as cursor:
            cursor.execute('SELECT canborrow FROM student WHERE StudentID = %s', [student_id])
            if cursor.fetchone()[0] == False:
                messages.error(request, 'You have fines to pay, please pay the fines first.')
            elif action == 'borrow':
                try:
                    cursor.callproc('InsertBorrowing', [student_id, book_id])
                    messages.success(request, '借阅成功')
                except Exception as e:
                    error_message = str(e)
                    messages.error(request,error_message)
            elif action == 'reserve':
                try:
                    cursor.callproc('ReserveBook', [student_id, book_id])
                    messages.success(request, '预约成功')
                except Exception as e:
                    error_message = str(e)
                    messages.error(request,error_message)
            else:
                messages.error(request, 'Invalid action')
        return redirect('st_search_books', student_id=student_id)

    context = {
        'book_list': book_list,
    }
    return render(request, 'student/search_books.html', context)