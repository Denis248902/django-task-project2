#!/usr/bin/env bash
set -e

BASE="http://127.0.0.1:8000"
USER="admin"
PASS="SuperSecretPass123!"

echo "🔐 Тест JWT авторизации"

# 1. Получаем токены
echo "👉 1. POST /api/token/ — получение токенов..."
RESPONSE=$(curl -s -w "%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" \
  "$BASE/api/token/")

if [[ "$RESPONSE" != *"200"* ]]; then
  echo "❌ Не удалось получить токен (HTTP $RESPONSE)"
  exit 1
fi

ACCESS_TOKEN=$(echo "$RESPONSE" | grep -o '"access":"[^"]*"' | cut -d'"' -f4)
if [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Не удалось извлечь access_token из ответа"
  exit 1
fi
echo "✅ Токен получен"

# 2. Запрос к API с Bearer‑токеном
echo "👉 2. GET /api/employees/ — запрос с JWT..."
CODE=$(curl -s -w "%{http_code}" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  "$BASE/api/employees/?page=1")

if [[ "$CODE" == *"200"* ]]; then
  echo "✅ Запрос с JWT прошёл (HTTP 200)"
else
  echo "❌ Запрос с JWT не прошёл (HTTP $CODE)"
  exit 1
fi

echo "🎉 JWT авторизация проверена. К5 закрыт!"
