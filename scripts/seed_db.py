import os
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
while not os.path.isfile(os.path.join(BASE_DIR, "manage.py")):
    BASE_DIR = os.path.dirname(BASE_DIR)
    if BASE_DIR == os.path.dirname(BASE_DIR):
        print("❌ Не удалось найти manage.py. Запускай скрипт из корня проекта.")
        sys.exit(1)

sys.path.insert(0, BASE_DIR)
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "core.settings")

import django

django.setup()

from django.contrib.auth import get_user_model

from emp_app.models import EmployeeProfile

User = get_user_model()

if len(sys.argv) < 4:
    print("❌ Ошибка: нужно передать 3 пароля: admin, watcher, visitor")
    print("Пример: python scripts/seed_db.py SuperSecretPass123! watcher123 visitor123")
    sys.exit(1)

admin_pass = sys.argv[1]
watcher_pass = sys.argv[2]
visitor_pass = sys.argv[3]


def create_or_skip_user(username, password, is_staff, is_superuser):
    try:
        user = User.objects.get(username=username)
        print(f"⚠️ Пользователь {username} уже существует, пропускаем.")
        return user
    except User.DoesNotExist:
        user = User.objects.create_user(
            username=username,
            password=password,
            is_staff=is_staff,
            is_superuser=is_superuser,
        )
        print(f"✅ Пользователь {username} создан.")
        return user


create_or_skip_user("admin", admin_pass, True, True)
create_or_skip_user("watcher", watcher_pass, True, False)
create_or_skip_user("visitor", visitor_pass, False, False)

# Получаем список разрешённых полей у модели
allowed_fields = {f.name for f in EmployeeProfile._meta.get_fields()}

employees_data = [
    {
        "full_name": "Иванов Иван",
        "position": "Разработчик",
        "years_of_experience": 3,
        "desk_number": 101,
    },
    {
        "full_name": "Петрова Анна",
        "position": "Тестировщик",
        "years_of_experience": 5,
        "desk_number": 102,
    },
    {
        "full_name": "Сидоров Алексей",
        "position": "Аналитик",
        "years_of_experience": 2,
        "desk_number": 103,
    },
    {
        "full_name": "Кузнецова Елена",
        "position": "Дизайнер",
        "years_of_experience": 4,
        "desk_number": 104,
    },
    {
        "full_name": "Смирнов Дмитрий",
        "position": "DevOps",
        "years_of_experience": 6,
        "desk_number": 105,
    },
    {
        "full_name": "Васильева Ольга",
        "position": "PM",
        "years_of_experience": 7,
        "desk_number": 106,
    },
    {
        "full_name": "Николаев Сергей",
        "position": "Frontend",
        "years_of_experience": 1,
        "desk_number": 107,
    },
]

for data in employees_data:
    # Оставляем только те поля, которые реально есть в модели
    clean_data = {k: v for k, v in data.items() if k in allowed_fields}
    EmployeeProfile.objects.update_or_create(
        full_name=clean_data["full_name"], defaults=clean_data
    )

count = EmployeeProfile.objects.count()
print(f"✅ В базе теперь {count} сотрудников.")
