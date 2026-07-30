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
echo "📝 Шаг 2: обновляем .flake8 (исключаем venv, migrations, tests)..."
cat > .flake8 << 'FLAKE8_EOF'
[flake8]
max-line-length = 88
exclude =
    .git,
    __pycache__,
    venv,
    .venv,
    migrations,
    tests,
    test_suite
FLAKE8_EOF
echo "✅ .flake8 создан/обновлён."

echo ""
echo "📝 Шаг 3: обновляем scripts/check_style.sh..."
cat > scripts/check_style.sh << 'CHECK_STYLE_EOF'
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
CHECK_STYLE_EOF
chmod +x scripts/check_style.sh
echo "✅ scripts/check_style.sh создан/обновлён и сделан исполняемым."

echo ""
echo "⚡ Шаг 4: запускаем проверку и форматирование..."
./scripts/check_style.sh
