#!/usr/bin/env bash
set -euo pipefail

SETTINGS_FILE="core/settings.py"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo "❌ Файл $SETTINGS_FILE не найден. Проверь, что ты в корне проекта."
  exit 1
fi

# Резервная копия
cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak"
echo "✅ Создана резервная копия: ${SETTINGS_FILE}.bak"

# Выводим правильный блок REST_FRAMEWORK, чтобы ты мог его вставить вручную
echo ""
echo "📋 Скопируй этот блок и замени им старый REST_FRAMEWORK в $SETTINGS_FILE:"
echo ""
cat << 'REST_BLOCK'
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.BasicAuthentication',
        # 'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 10,
}
REST_BLOCK
echo ""
echo "⚠️ Важно: удали старый блок REST_FRAMEWORK из файла, чтобы не было двух одинаковых определений."
echo "После вставки перезапусти сервер: python manage.py runserver"
