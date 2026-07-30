from datetime import date

from django.core.exceptions import ValidationError
from django.db import models


class EmployeeProfile(models.Model):
    GENDER_CHOICES = [
        ("M", "Мужской"),
        ("F", "Женский"),
    ]
    ROLE_CHOICES = [
        ("tester", "Тестировщик"),
        ("backend", "Бэкенд‑разработчик"),
        ("frontend", "Фронтенд‑разработчик"),
        ("fullstack", "Fullstack"),
        ("devops", "DevOps"),
        ("manager", "Менеджер"),
    ]

    full_name = models.CharField(max_length=255)
    gender = models.CharField(max_length=1, choices=GENDER_CHOICES)
    position = models.CharField(max_length=100)
    years_of_experience = models.IntegerField(default=0)
    role = models.CharField(max_length=50, choices=ROLE_CHOICES, default="backend")
    skills = models.JSONField(default=list, blank=True)
    desk_number = models.IntegerField(null=True, blank=True)
    hire_date = models.DateField(
        null=True, blank=True
    )  # важно: у тебя используется в tenure_days

    def clean(self):
        super().clean()
        if self.desk_number is None:
            return

        developer_roles = ["backend", "frontend", "fullstack"]
        is_dev_or_tester = (self.role in developer_roles) or (self.role == "tester")

        if is_dev_or_tester:
            neighbors = EmployeeProfile.objects.filter(
                role__in=developer_roles + ["tester"],
                desk_number__in=[self.desk_number - 1, self.desk_number + 1],
            ).exclude(pk=self.pk)
            if neighbors.exists():
                raise ValidationError(
                    "Тестировщики и разработчики не могут занимать соседние столы."
                )

    def __str__(self):
        return self.full_name


class Photo(models.Model):
    employee = models.ForeignKey(
        EmployeeProfile, related_name="photos", on_delete=models.CASCADE
    )
    image = models.ImageField(upload_to="employee_photos/")
    order = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ["order"]

    def __str__(self):
        return f"Photo for {self.employee}"

    @property
    def tenure_days(self):
        today = date.today()
        if self.hire_date:
            return (today - self.hire_date).days
        return 0
