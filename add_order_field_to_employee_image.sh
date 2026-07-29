#!/usr/bin/env bash
set -e

MODEL_FILE="emp_app/models.py"

# 1. Проверяем, есть ли уже поле order в классе EmployeeImage
if grep -q "order = models.PositiveIntegerField" "$MODEL_FILE"; then
    echo "✅ Поле order уже есть в модели EmployeeImage — пропускаем."
else
    echo "🔍 Поле order не найдено. Добавляем его в модель..."

    # Вставляем поле order перед закрывающей скобкой класса EmployeeImage.
    # Используем временный файл, чтобы безопасно отредактировать модель.
    TMPFILE=$(mktemp)

    awk '
    BEGIN { in_class = 0 }
    /^class EmployeeImage(models\.Model):/ {
        in_class = 1
        print
        next
    }
    in_class == 1 && /^)/ {
        # Нашли закрывающую скобку класса — вставляем поле перед ней
        print "    order = models.PositiveIntegerField(default=1, verbose_name=\"Порядок фото\")"
        print
        in_class = 0
        next
    }
    { print }
    ' "$MODEL_FILE" > "$TMPFILE"

    mv "$TMPFILE" "$MODEL_FILE"
    echo "✅ Добавлено поле order в модель EmployeeImage."
fi

# 2. Создаём миграцию
echo ""
echo "🚀 Создаём миграцию..."
python manage.py makemigrations emp_app

# 3. Применяем миграцию
echo ""
echo "🚀 Применяем миграцию..."
python manage.py migrate

echo ""
echo "✅ Готово. Поле order добавлено, миграция применена."
echo "Теперь можно запускать тесты: python manage.py test emp_app"
