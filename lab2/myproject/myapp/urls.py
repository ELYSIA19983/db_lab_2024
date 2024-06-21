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