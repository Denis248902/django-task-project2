#!/usr/bin/env bash
set -e

BASE="http://127.0.0.1:8000"

get_token() {
    local user=$1
    local pass=$2
    local resp=$(curl -s -w "%{http_code}" -X POST \
      -H "Content-Type: application/json" \
      -d "{\"username\":\"$user\",\"password\":\"$pass\"}" \
      "$BASE/api/token/")

    if [[ "$resp" != *"200"* ]]; then
        echo "❌ Не удалось получить токен для $user"
        exit 1
    fi

    echo "$resp" | grep -o '"access":"[^"]*"' | cut -d'"' -f4
}

echo "🔐 Тест ролей (К6)"

# Viewer
echo "👉 1. viewer_user (только GET)"
TOKEN_VIEWER=$(get_token "viewer_user" "Pass123456!")
CODE_GET=$(curl -s -w "%{http_code}" \
  -H "Authorization: Bearer $TOKEN_VIEWER" \
  "$BASE/api/employees/?page=1")
[[ "$CODE_GET" == *"200"* ]] && echo "✅ GET OK" || { echo "❌ GET не прошёл"; exit 1; }

CODE_POST=$(curl -s -w "%{http_code}" -X POST \
  -H "Authorization: Bearer $TOKEN_VIEWER" \
  -H "Content-Type: application/json" \
  -d '{"full_name":"Forbidden","position":"Test"}' \
  "$BASE/api/employees/")
[[ "$CODE_POST" == *"403"* ]] && echo "✅ POST правильно запрещён (403)" || { echo "❌ POST не заблокирован"; exit 1; }

# Editor
echo "👉 2. editor_user (GET/POST/PUT/PATCH, без DELETE)"
TOKEN_EDITOR=$(get_token "editor_user" "Pass123456!")
RESP_CREATE=$(curl -s -w "%{http_code}" -X POST \
  -H "Authorization: Bearer $TOKEN_EDITOR" \
  -H "Content-Type: application/json" \
  -d '{"full_name":"Editor Test","position":"Editor Role"}' \
  "$BASE/api/employees/")
[[ "$RESP_CREATE" == *"201"* ]] && echo "✅ POST OK (201)" || { echo "❌ Editor не может создавать"; exit 1; }

NEW_ID=$(echo "$RESP_CREATE" | grep -o '"id":[0-9]*' | cut -d':' -f2)
if [ -z "$NEW_ID" ]; then
  echo "❌ Не удалось извлечь ID нового сотрудника"
  exit 1
fi

CODE_DEL=$(curl -s -w "%{http_code}" -X DELETE \
  -H "Authorization: Bearer $TOKEN_EDITOR" \
  "$BASE/api/employees/$NEW_ID/")
[[ "$CODE_DEL" == *"403"* ]] && echo "✅ DELETE правильно запрещён для редактора (403)" || { echo "❌ DELETE не заблокирован для редактора"; exit 1; }

# Admin
echo "👉 3. admin (все права)"
TOKEN_ADMIN=$(get_token "admin" "SuperSecretPass123!")
CODE_DEL_ADMIN=$(curl -s -w "%{http_code}" -X DELETE \
  -H "Authorization: Bearer $TOKEN_ADMIN" \
  "$BASE/api/employees/$NEW_ID/")
[[ "$CODE_DEL_ADMIN" == *"204"* ]] && echo "✅ DELETE разрешён для админа (204)" || { echo "❌ Admin не может удалять"; exit 1; }

echo "🎉 Все проверки ролей пройдены. К6 закрыт!"
