import os

import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "core.settings")
django.setup()

from django.contrib.auth.models import User
from employees.models import EmployeeProfile, EmployeeSkillLevel, Skill
from workplaces.models import Workplace

print("🚀 Seed script started")

# 1. Пользователь
user, created = User.objects.get_or_create(
    username="ivan_petrov",
    defaults={
        "first_name": "Иван",
        "last_name": "Петров",
        "email": "ivan.petrov@example.com",
    },
)
if created:
    user.set_password("password123")
    user.save()
    print(f"✅ Пользователь создан: {user.username}")
else:
    print(f"ℹ️ Пользователь уже существует: {user.username}")

# 2. Профиль
employee, created = EmployeeProfile.objects.get_or_create(
    user=user,
    defaults={
        "first_name": "Иван",
        "last_name": "Петров",
        "middle_name": "Сергеевич",
        "gender": "M",
        "description": "Разработчик, стаж 3 года",
    },
)
print(
    f"✅ Профиль сотрудника: {employee.first_name} {employee.middle_name or ''} {employee.last_name}"
)

# 3. Рабочее место
workplace, created = Workplace.objects.get_or_create(
    desk_number="101", defaults={"extra_info": "Главный офис, Москва"}
)
workplace.employee = employee
workplace.save()
print(f"✅ Рабочее место: стол {workplace.desk_number} ({workplace.extra_info})")

# 4. Навыки (ключевой блок)
skills_data = [
    ("Frontend", 7),
    ("Backend", 8),
    ("Тестирование", 5),
    ("Управление проектами", 6),
]

for name, level in skills_data:
    skill, _ = Skill.objects.get_or_create(name=name)
    obj, created = EmployeeSkillLevel.objects.update_or_create(
        employee=employee, skill=skill, defaults={"level": level}
    )
    if created:
        print(f"   → навык добавлен: {skill.name}, уровень: {level}")
    else:
        print(f"   → навык обновлён: {skill.name}, уровень: {level}")

print("🎉 Тестовые данные (включая навыки) созданы!")
