from django.contrib import admin
from .models import EmployeeProfile, EmployeeImage

@admin.register(EmployeeProfile)
class EmployeeProfileAdmin(admin.ModelAdmin):
    list_display = ('full_name', 'role', 'desk_number', 'gender')

@admin.register(EmployeeImage)
class EmployeeImageAdmin(admin.ModelAdmin):
    list_display = ('employee', 'order_index')
