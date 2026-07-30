from django.db import models

from emp_app.models import EmployeeProfile


class Workplace(models.Model):
    desk_number = models.CharField(max_length=20, unique=True)
    extra_info = models.TextField(blank=True, null=True)
    employee = models.OneToOneField(
        "emp_app.EmployeeProfile", on_delete=models.SET_NULL, null=True, blank=True
    )

    def __str__(self):
        return f"Стол {self.desk_number}"
