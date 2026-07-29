#!/usr/bin/env bash
set -e

FILE="emp_app/views.py"
TMPFILE=$(mktemp)

# 1. Проверяем, есть ли уже функция employee_upload_photo
if grep -q "def employee_upload_photo" "$FILE"; then
    echo "✅ Функция employee_upload_photo уже есть — пропускаем."
else
    cat >> "$FILE" << 'PYEOF'

from django.shortcuts import render, get_object_or_404, redirect
from .models import EmployeeProfile, EmployeeImage
from django.forms import ModelForm

class PhotoUploadForm(ModelForm):
    class Meta:
        model = EmployeeImage
        fields = ['image', 'order']

def employee_upload_photo(request, pk):
    employee = get_object_or_404(EmployeeProfile, pk=pk)

    if request.method == 'POST':
        form = PhotoUploadForm(request.POST, request.FILES)
        if form.is_valid():
            photo = form.save(commit=False)
            photo.employee = employee
            # Если порядок не указан, ставим следующий доступный
            if not photo.order:
                next_order = employee.images.aggregate(max_order=models.Max('order'))['max_order'] or 0
                photo.order = next_order + 1
            photo.save()
            return redirect('employee_detail', pk=employee.pk)
    else:
        form = PhotoUploadForm()

    return render(request, 'emp_app/upload_photo.html', {
        'employee': employee,
        'form': form,
    })
PYEOF

    # Важно: нужно добавить импорт models, если его нет
    # Проверяем наличие "import models" или "from django.db import models"
    if ! grep -q "from django.db import models" "$FILE" && ! grep -q "import models" "$FILE"; then
        # Вставляем импорт в начало файла (после первых импортов)
        sed -i '1i from django.db import models' "$FILE"
        echo "✅ Добавлен 'from django.db import models'"
    fi

    echo "✅ Добавлена функция employee_upload_photo в emp_app/views.py"
fi

# 2. Создаём шаблон upload_photo.html
TEMPLATE_DIR="emp_app/templates/emp_app"
mkdir -p "$TEMPLATE_DIR"
TEMPLATE_FILE="$TEMPLATE_DIR/upload_photo.html"

if [ -f "$TEMPLATE_FILE" ]; then
    echo "✅ Шаблон upload_photo.html уже существует — пропускаем."
else
    cat > "$TEMPLATE_FILE" << 'HTMLEOF'
{% extends "base.html" %}

{% block content %}
<h1>Загрузить фото для {{ employee.full_name }}</h1>

<form method="post" enctype="multipart/form-data">
  {% csrf_token %}
  {{ form.as_p }}
  <button type="submit">Загрузить</button>
</form>

<p><a href="{% url 'employee_detail' pk=employee.pk %}">← Назад к сотруднику</a></p>
{% endblock %}
HTMLEOF
    echo "✅ Создан шаблон emp_app/templates/emp_app/upload_photo.html"
fi

echo ""
echo "🔍 Проверяем синтаксис..."
python -m py_compile "$FILE" && echo "✅ views.py OK" || (echo "❌ Ошибка синтаксиса в views.py" && exit 1)

echo ""
echo "🚀 Готово. Теперь можно запускать тесты:"
echo "python manage.py test emp_app"
