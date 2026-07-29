#!/usr/bin/env bash
set -e

FILE="emp_app/templates/emp_app/employee_list.html"
TMPFILE=$(mktemp)

# Ищем все строки вида {{ image.url }} и меняем на условную конструкцию:
# {% if image.image %}<img src="{{ image.image.url }}">{% endif %}
# Это защитит от ValueError, когда файла нет.

sed -i 's/{{[\t ]*image\.url[\t ]*}}/{% if image.image %}{% if image.image.url %}<img src="{{ image.image.url }}" alt="Photo">{{% endif %}}{% endif %}/g' "$FILE"

echo "✅ Шаблон исправлен: теперь не падает, если у фото нет файла."
