#!/usr/bin/env bash
set -e

echo "🚀 Запуск seed_roles.sh..."
python manage.py seed_roles
echo "🎉 seed_roles.sh завершён!"
