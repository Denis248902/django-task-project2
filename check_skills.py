import os

import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "core.settings")
django.setup()

from employees.models import EmployeeSkillLevel, Skill

print("Навыки в БД:", [s.name for s in Skill.objects.all()])
print(
    "Уровни навыков:",
    [
        (e.employee.first_name, e.skill.name, e.level)
        for e in EmployeeSkillLevel.objects.all()
    ],
)
