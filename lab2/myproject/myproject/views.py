from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.db import connection
from django.urls import reverse
from django.views.decorators.csrf import csrf_protect
from django.contrib import messages


def index(request):
    return render(request, 'index.html')

def superadmin_login(request):
    # 仿照student_login函数，实现超级管理员登录 
    if request.method == 'POST':
        # 获取用户输入
        superadmin_id = request.POST.get('superadmin_id')
        password = request.POST.get('password')
        # 从数据库中获取超级管理员的SuperAdminID和密码
        with connection.cursor() as cursor:
            cursor.execute('SELECT SuperAdminID, password FROM superadmin WHERE SuperAdminID = %s', [superadmin_id])
            result = cursor.fetchone()
        if not result:
            messages.error(request, 'no such superadmin') # 登录失败，显示错误消息
        # 验证用户输入的id和密码
        elif result and result[1] == password:
            return redirect('superadmin_home',superadmin_id=result[0])  # 登录成功，重定向到超级管理员主页
        else:
            messages.error(request, 'Invalid superadmin ID or password')  # 登录失败，显示错误消息  
    return render(request, 'superadmin_login.html')

def student_login(request):
    if request.method == 'POST':
        # 获取用户输入
        student_id = request.POST.get('student_id')
        password = request.POST.get('password')
        # 从数据库中获取学生的StudentID和密码
        with connection.cursor() as cursor:
            cursor.execute('SELECT StudentID, password FROM student WHERE StudentID = %s', [student_id])
            result = cursor.fetchone()
        if not result:
            messages.error(request, 'no such student') # 登录失败，显示错误消息
        # 验证用户输入的id和密码
        elif result and result[1] == password:
            return redirect('student_home',student_id=result[0])  # 登录成功，重定向到学生主页
        else:
            messages.error(request, 'Invalid student ID or password')  # 登录失败，显示错误消息

    return render(request, 'student_login.html')

