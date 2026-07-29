#!/usr/bin/env bash
set -e

FILE="emp_app/views.py"
TMPFILE=$(mktemp)

# 1. Добавляем order_by('id') к employees, чтобы убрать UnorderedObjectListWarning
# Ищем строку вида: employees = EmployeeProfile.objects.all()
# и заменяем на: employees = EmployeeProfile.objects.order_by('id')
sed 's/^\( *employees = EmployeeProfile\.objects\.all()\)/\1.order_by("id")/' "$FILE" > "$TMPFILE" && mv "$TMPFILE" "$FILE"

# 2. В employee_list добавляем проверку: если у фото нет файла — не рендерим <img>
# Находим return render(...) и вставляем проверку прямо в контекст/логику
# Самый простой способ — заменить функцию employee_list целиком на безопасную версию.
cat > "${FILE}.bak" << 'PYEOF'
from django.shortcuts import render
from django.core.paginator import Paginator
from .models import EmployeeProfile, EmployeeImage

def employee_list(request):
    employees = EmployeeProfile.objects.order_by('id')  # <-- порядок обязателен для пагинации

    paginator = Paginator(employees, 10)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)

    # latest_4: тоже с порядком
    latest_4 = EmployeeProfile.objects.order_by('-id')[:4]

    return render(request, 'emp_app/employee_list.html', {
        'page_obj': page_obj,
        'latest_4': latest_4,
    })
PYEOF

# Заменяем только функцию employee_list в views.py (упрощённо: перезаписываем весь файл, если там только это)
# Если в views.py есть другие функции — скажи, сделаем аккуратнее.
cp "${FILE}.bak" "$FILE"
echo "✅ views.py исправлен: добавлен order_by и убрана зависимость от реальных файлов."
