# -*- coding: utf-8 -*-
import os
import sys
import django

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(BASE_DIR)
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from emp_app.models import EmployeeProfile, EmployeeImage

employees_data = [
    {"full_name": "Борис Петров", "gender": "M", "position": "DevOps Engineer"},
    {"full_name": "Виктор Сидоров", "gender": "M", "position": "Team Lead"},
    {"full_name": "Галина Смирнова", "gender": "F", "position": "Frontend Developer"},
    {"full_name": "Дмитрий Козлов", "gender": "M", "position": "QA Engineer"},
    {"full_name": "Елена Васильева", "gender": "F", "position": "Data Analyst"},
]

print("🔧 Создаём сотрудников...")
for data in employees_data:
    emp = EmployeeProfile.objects.create(
        full_name=data["full_name"],
        gender=data["gender"],
        position=data["position"],
    )
    # Для seed’а не создаём реальные картинки — только запись в БД
    EmployeeImage.objects.create(employee=emp, order=1)

print(f"✅ Создано {len(employees_data)} сотрудников и по одной пустой записи фото.")
print("🎉 Готово!")
