import os
import sys
import django

# Добавляем корень проекта в sys.path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))          # scripts/
PROJECT_ROOT = os.path.dirname(BASE_DIR)                      # ~/django-task-project/
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

# Подключаем настройки Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from emp_app.models import EmployeeProfile, Skill, EmployeeSkill, EmployeeImage

print("Создаём навыки...")
skills = {}
for name in ["Python", "Django", "Git", "SQL", "Flutter", "Bash", "HTML/CSS"]:
    skill, created = Skill.objects.get_or_create(name=name)
    skills[name] = skill
    if created:
        print(f"  + навык: {name}")

print("Создаём сотрудников и навыки...")
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
    print(f"  + сотрудник: {emp.full_name}")

    # Добавляем навыки
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

# Создаём заглушки фото
print("Создаём заглушки изображений...")
for emp in created_employees:
    img_path = os.path.join(PROJECT_ROOT, "media", f"{emp.id}_test.jpg")
    os.makedirs(os.path.dirname(img_path), exist_ok=True)
    with open(img_path, "w", encoding="utf-8") as f:
        f.write("fake image content")
    
    EmployeeImage.objects.create(
        employee=emp,
        image=f"{emp.id}_test.jpg",
        order=1
    )
    print(f"  + фото для: {emp.full_name}")

print(f"\nГотово! Создано {len(created_employees)} сотрудников.")
