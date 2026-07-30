#!/usr/bin/env bash
set -e

BASE_URL="http://127.0.0.1:8000"

get_token() {
    local username=$1
    local password=$2
    curl -s -X POST -H "Content-Type: application/json" \
      -d "{\"username\":\"$username\",\"password\":\"$password\"}" \
      "http://127.0.0.1:8000/api/token/" \
      | python -c "import sys, json; data=json.load(sys.stdin); print(data.get('access', ''))"
}

run_test() {
    local role=$1
    local username=$2
    local password=$3
    local expected_code=$4
    local description=$5

    echo "🧪 Тест: $description ($role)"

    ACCESS_TOKEN=$(get_token "$username" "$password")
    if [ -z "$ACCESS_TOKEN" ]; then
        echo "❌ Ошибка: не удалось получить токен для $username"
        exit 1
    fi

    RES=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"full_name":"TestAuto","position":"Dev","gender":"M"}' \
      "$BASE_URL/api/employees/")

    HTTP_CODE=$(echo "$RES" | tail -n1)
    BODY=$(echo "$RES" | head -n -1)

    if [ "$HTTP_CODE" = "$expected_code" ]; then
        echo "✅ ПРОЙДЁН: ожидается $expected_code, получено $HTTP_CODE"
    else
        echo "⚠️ ПРОВАЛЕН: ожидается $expected_code, но получено $HTTP_CODE"
        echo "$BODY"
        exit 1
    fi
}

echo "🚀 Запуск test_all_roles.sh..."

run_test "viewer" "viewer_user" "Viewer12345" "403" "viewer_user не может делать POST"
run_test "editor" "editor_user" "Editor12345" "201" "editor_user может делать POST"
run_test "admin" "admin_user" "Admin12345" "201" "admin_user может делать POST"

echo "🎉 Все тесты пройдены!"
