#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Форматируем код через black (исключая venv, migrations, tests)..."
python -m black --exclude="venv|\\.venv|migrations|tests|test_suite" .

echo "🧹 Сортируем импорты через isort (исключая те же папки)..."
python -m isort --skip=venv,.venv,migrations,tests,test_suite .

echo "🔍 Проверяем стиль через flake8 (по .flake8)..."
python -m flake8

if [ $? -eq 0 ]; then
  echo "✅ Стиль кода соответствует стандартам."
else
  echo "❌ Обнаружены проблемы со стилем в твоём коде."
  exit 1
fi
