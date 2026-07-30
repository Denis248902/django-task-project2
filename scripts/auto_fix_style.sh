#!/usr/bin/env bash
set -euo pipefail

echo "🧹 Шаг 1: убираем из Git случайные изменения в venv..."
if git status --porcelain | grep -q "^[A-M][A-M] *venv/"; then
  git reset HEAD venv
  git checkout -- venv
  echo "✅ Папка venv убрана из индекса и сброшена."
else
  echo "ℹ️ В venv нет изменений в индексе — пропускаем."
fi

echo ""
echo "🧠 Шаг 2: чистим неиспользуемые импорты (F401) через autoflake..."
python -m autoflake --in-place --remove-all-unused-imports \
  --exclude="venv,.venv,__pycache__,migrations,tests,test_suite" \
  .
echo "✅ Неиспользуемые импорты удалены."

echo ""
echo "🚀 Шаг 3: форматируем код через black (по pyproject.toml)..."
python -m black .
echo "✅ Код отформатирован."

echo ""
echo "🧹 Шаг 4: сортируем импорты через isort (по pyproject.toml)..."
python -m isort .
echo "✅ Импорты отсортированы."

echo ""
echo "🔍 Шаг 5: финальная проверка flake8 (по pyproject.toml)..."
python -m flake8

if [ $? -eq 0 ]; then
  echo "✅ Стиль кода соответствует стандартам. К7 закрыт!"
else
  echo "❌ Остались проблемы. Посмотри на вывод flake8 и исправь вручную (особенно E402)."
  exit 1
fi
