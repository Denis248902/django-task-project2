#!/usr/bin/env bash
set -euo pipefail

BASE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$BASE"

# Гарантируем переменные окружения
export PYTHONPATH="${PYTHONPATH:-}"
export DJANGO_SETTINGS_MODULE="core.settings"

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_ok() { echo -e "${GREEN}✅ OK${NC} — $1"; }
log_fail() { echo -e "${RED}❌ FAIL${NC} — $1"; exit 1; }
log_warn() { echo -e "${YELLOW}⚠️ WARN${NC} — $1"; }

echo "🚀 Запуск Django сервера на 127.0.0.1:8000..."
python manage.py runserver 127.0.0.1:8000 > /dev/null 2>&1 &
SERVER_PID=$!

# Даём серверу время запуститься (в MINGW64 иногда нужно чуть больше)
sleep 5

cleanup() {
  echo "🧹 Остановка сервера..."
  kill "$SERVER_PID" 2>/dev/null || true
  wait "$SERVER_PID" 2>/dev/null || true
}
trap cleanup EXIT

# Функция получения токена
get_token() {
  local USER=$1
  local PASS=$2
  curl -s -X POST http://127.0.0.1:8000/api/token/ \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" \
    | python -c "import sys, json; data=json.load(sys.stdin); print(data.get('access', ''))" 2>/dev/null
}

echo "🔑 Получение токенов..."
ADMIN_TOKEN=$(get_token "admin" "ТВОЙ_ПАРОЛЬ_ADMIN")
WATCHER_TOKEN=$(get_token "watcher" "watcher123")
VISITOR_TOKEN=$(get_token "visitor" "visitor123")

if [[ -z "$ADMIN_TOKEN" ]]; then
  log_fail "Не удалось получить токен для admin. Проверь логин/пароль и наличие пользователя."
fi
if [[ -z "$WATCHER_TOKEN" ]]; then
  log_fail "Не удалось получить токен для watcher. Проверь, что пользователь создан и is_staff=True."
fi
if [[ -z "$VISITOR_TOKEN" ]]; then
  log_fail "Не удалось получить токен для visitor."
fi
log_ok "Токены получены"

echo ""
echo "🧪 Запуск тестов API..."

# Тест 1: Список сотрудников
RESPONSE=$(curl -s http://127.0.0.1:8000/api/employees/ \
  -H "Authorization: Bearer $ADMIN_TOKEN")
if echo "$RESPONSE" | grep -q '"id"' && echo "$RESPONSE" | grep -q '"full_name"'; then
  log_ok "Список сотрудников — работает"
else
  log_fail "Список сотрудников — не возвращает корректные данные. Ответ: $RESPONSE"
fi

# Получаем ID первого сотрудника динамически (чтобы не зависеть от ID=1)
EMPLOYEE_ID=$(echo "$RESPONSE" | python -c "import sys,json; d=json.load(sys.stdin); print(d[0]['id'] if d else '')" 2>/dev/null)
if [[ -z "$EMPLOYEE_ID" ]]; then
  log_fail "Нет сотрудников в БД. Сначала запусти seed‑скрипт или создай хотя бы одного сотрудника."
fi
echo "👤 Используем сотрудника с ID: $EMPLOYEE_ID для тестов действий"

# Тест 2: Фильтрация по опыту (min_experience)
RESPONSE=$(curl -s "http://127.0.0.1:8000/api/employees/?min_experience=0" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
if echo "$RESPONSE" | grep -q '"years_of_experience"' || echo "$RESPONSE" | grep -q '\[\]'; then
  log_ok "Фильтрация min_experience — работает"
else
  log_warn "Фильтрация min_experience — странный ответ. Ответ: $RESPONSE"
fi

# Тест 3: move_to_desk от watcher
RESPONSE=$(curl -s -X POST "http://127.0.0.1:8000/api/employees/${EMPLOYEE_ID}/move_to_desk/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $WATCHER_TOKEN" \
  -d '{"desk_number": 999}')

if echo "$RESPONSE" | grep -q '"desk_number"' && echo "$RESPONSE" | grep -q '"999"'; then
  log_ok "move_to_desk (watcher) — работает"
else
  log_fail "move_to_desk — не сработал. Ответ: $RESPONSE"
fi

# Тест 4: Защита прав — visitor НЕ может двигать сотрудника (должен быть 403)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "http://127.0.0.1:8000/api/employees/${EMPLOYEE_ID}/move_to_desk/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $VISITOR_TOKEN" \
  -d '{"desk_number": 888}')

if [[ "$HTTP_CODE" == "403" ]]; then
  log_ok "Защита прав (visitor → 403) — работает"
else
  log_fail "Защита прав — не сработала. visitor получил код: $HTTP_CODE"
fi

echo ""
log_ok "🎉 Все тесты пройдены!"
