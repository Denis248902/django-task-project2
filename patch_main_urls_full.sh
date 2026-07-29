#!/usr/bin/env bash
set -e

FILE="django_task_project/urls.py"

echo "🔗 Настраиваем подключение emp_app в главном urls.py..."

# 1. Добавляем импорт include, если его нет
if ! grep -q "from django.urls import include" "$FILE"; then
    sed -i "1i from django.urls import include\n" "$FILE"
    echo "✅ Добавлен 'from django.urls import include'."
else
    echo "✅ Импорт include уже есть."
fi

# 2. Проверяем, есть ли уже подключение emp_app
if grep -q "path('employees/', include('emp_app.urls'))" "$FILE"; then
    echo "✅ Приложение emp_app уже подключено — пропускаем."
else
    # Находим строку с закрывающей скобкой urlpatterns] и вставляем перед ней
    # Используем временный файл, чтобы не сломать отступы
    TMPFILE=$(mktemp)
    awk '
    {
        print
        if ($0 ~ /^\]\s*$/) {
            print "    path(\047employees/\047, include(\047emp_app.urls\047)),"
        }
    }
    ' "$FILE" > "$TMPFILE" && mv "$TMPFILE" "$FILE"
    echo "✅ Добавлено подключение path('employees/', include('emp_app.urls'))."
fi

echo ""
echo "🔍 Проверяем синтаксис urls.py..."
python -m py_compile "$FILE" && echo "✅ urls.py OK" || (echo "❌ Ошибка в urls.py" && exit 1)
