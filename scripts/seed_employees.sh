#!/usr/bin/env bash
set -e

echo "🔧 Создаём тестовые данные для Django..."

# Убеждаемся, что есть папка media
mkdir -p media

# Запускаем Python-скрипт через manage.py shell
python manage.py shell << 'PYTHON_EOF'
from emp_app.models import EmployeeProfile, Skill, EmployeeSkill, EmployeeImage
import os

# Создаём базовые навыки
skills = {}
for name in ["Python", "Django", "Git", "SQL", "Flutter", "Bash", "HTML/CSS"]:
    skill, created = Skill.objects.get_or_create(name=name)
    skills[name] = skill

# Список тестовых сотрудников
employees_data = [
    {"full_name": "Анна Иванова", "gender": "F", "position": "Junior Python Developer"},
    {"full_name": "Борис Петров", "gender": "M", "position": "DevOps Engineer"},
    {"full_name": "Виктор Сидоров", "gender": "M", "position": "Team Lead"},
    {"full_name": "Галина Смирнова", "gender": "F", "position": "Frontend Developer"},
    {"full_name": "Дмитрий Козлов", "gender": "M", "position": "QA Engineer"},
    {"full_name": "Елена Васильева", "gender": "F", "position": "Data Analyst"},
    {"full_name": "Иван Соколов", "gender": "M", "position": "Backend Developer"},
]

created_employees = []

for data in employees_data:
    emp = EmployeeProfile.objects.create(
        full_name=data["full_name"],
        gender=data["gender"],
        position=data["position"]
    )
    created_employees.append(emp)

    # Добавляем 2–3 навыка каждому
    if data["full_name"] == "Анна Иванова":
        EmployeeSkill.objects.create(employee=emp, skill=skills["Python"], level=3)
        EmployeeSkill.objects.create(employee=emp, skill=skills["Django"], level=2)
    elif data["full_name"] == "Борис Петров":
        EmployeeSkill.objects.create(employee=emp, skill=skills["Git"], level=4)
        EmployeeSkill.objects.create(employee=emp, skill=skills["Bash"], level=5)
    elif data["full_name"] == "Виктор Сидоров":
        EmployeeSkill.objects.create(employee=emp, skill=skills["Python"], level=5)
        EmployeeSkill.objects.create(employee=emp, skill=skills["SQL"], level=4)
    else:
        EmployeeSkill.objects.create(employee=emp, skill=skills["HTML/CSS"], level=3)
        EmployeeSkill.objects.create(employee=emp, skill=skills["Git"], level=2)

    # Создаём «заглушку» фото
    img_path = f"media/{emp.id}_test.jpg"
    with open(img_path, "w") as f:
        f.write("fake image content")
    
    EmployeeImage.objects.create(
        employee=emp,
        image=f"{emp.id}_test.jpg",
        order=1
    )

print(f"✅ Создано {len(created_employees)} сотрудников, навыки и фото‑заглушки.")
PYTHON_EOF

echo "🎉 Готово!"
