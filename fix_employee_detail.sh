#!/usr/bin/env bash
set -e

# 1. Добавляем функцию employee_detail в views.py
FILE="emp_app/views.py"
TMPFILE=$(mktemp)

# Проверяем, есть ли уже функция employee_detail — если нет, дописываем в конец файла
if grep -q "def employee_detail" "$FILE"; then
    echo "✅ Функция employee_detail уже есть в views.py — пропускаем."
else
    cat >> "$FILE" << 'PYEOF'

from django.shortcuts import render, get_object_or_404
from .models import EmployeeProfile

def employee_detail(request, pk):
    employee = get_object_or_404(EmployeeProfile, pk=pk)
    # Получаем связанные фото с порядком по полю order
    images = employee.images.order_by('order')

    return render(request, 'emp_app/employee_detail.html', {
        'employee': employee,
        'images': images,
    })
PYEOF
    echo "✅ Добавлена функция employee_detail в emp_app/views.py"
fi

# 2. Создаём шаблон employee_detail.html, если его нет
TEMPLATE_DIR="emp_app/templates/emp_app"
mkdir -p "$TEMPLATE_DIR"
TEMPLATE_FILE="$TEMPLATE_DIR/employee_detail.html"

if [ -f "$TEMPLATE_FILE" ]; then
    echo "✅ Шаблон employee_detail.html уже существует — пропускаем."
else
    cat > "$TEMPLATE_FILE" << 'HTMLEOF'
{% extends "base.html" %}

{% block content %}
<h1>{{ employee.full_name }}</h1>
<p>Должность: {{ employee.position }}</p>
<p>Роль: {{ employee.role }}</p>

<h2>Галерея</h2>
{% if images %}
  <div class="image-gallery">
    {% for image in images %}
      {% if image.image %}
        <div style="margin: 5px;">
          <img src="{{ image.image.url }}" alt="Photo #{{ image.order }}" width="200">
          <p>Фото №{{ image.order }}</p>
        </div>
      {% else %}
        <p><em>Нет файла для фото №{{ image.order }}</em></p>
      {% endif %}
    {% endfor %}
  </div>
{% else %}
  <p>У этого сотрудника пока нет фотографий.</p>
{% endif %}
{% endblock %}
HTMLEOF
    echo "✅ Создан шаблон emp_app/templates/emp_app/employee_detail.html"
fi

echo ""
echo "🔍 Проверяем синтаксис..."
python -m py_compile "$FILE" && echo "✅ views.py OK" || (echo "❌ Ошибка синтаксиса в views.py" && exit 1)
python -m py_compile "$TEMPLATE_FILE" 2>/dev/null || echo "⚠️ Шаблон не проверяется через py_compile — это нормально"

echo ""
echo "🚀 Готово. Теперь можно запускать тесты:"
echo "python manage.py test emp_app"
