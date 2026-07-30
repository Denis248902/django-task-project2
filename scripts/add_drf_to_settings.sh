#!/usr/bin/env bash
set -euo pipefail

BASE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SETTINGS_FILE="${BASE}/core/settings.py"

if grep -q "'rest_framework'" "$SETTINGS_FILE"; then
  echo "✅ rest_framework уже есть в INSTALLED_APPS"
  exit 0
fi

# Вставляем 'rest_framework', перед закрывающей скобкой списка
sed -i.bak "s/],/\n    'rest_framework',\n],/" "$SETTINGS_FILE"

echo "✅ rest_framework добавлен в INSTALLED_APPS"
echo ""
echo "💡 Если хочешь, можем добавить настройки REST_FRAMEWORK в конец файла."
