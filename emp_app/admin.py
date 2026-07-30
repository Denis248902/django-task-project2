from django.contrib import admin

from .models import EmployeeProfile, Photo


@admin.register(EmployeeProfile)
class EmployeeProfileAdmin(admin.ModelAdmin):
    list_display = ["full_name", "position"]


@admin.register(Photo)
class PhotoAdmin(admin.ModelAdmin):
    list_display = ["employee", "order"]
