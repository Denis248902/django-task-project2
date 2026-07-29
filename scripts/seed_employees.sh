#!/usr/bin/env bash
set -e

echo "🔧 Запускаем seed-скрипт..."
PYTHONIOENCODING=utf-8 python scripts/seed_employees_run.py
echo "🎉 Готово!"
