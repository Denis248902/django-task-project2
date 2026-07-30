#!/usr/bin/env bash
set -euo pipefail

BASE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$BASE"

export PYTHONPATH="${PYTHONPATH:-}"
export DJANGO_SETTINGS_MODULE="core.settings"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_ok() { echo -e "${GREEN}✅ OK${NC} — $1"; }
log_fail() { echo -e "${RED}❌ FAIL${NC} — $1"; exit 1; }

echo "🌱 Запуск seed-скрипта: пользователи и сотрудники..."

# Проверяем, что пароли переданы
if [ "$#" -lt 3 ]; then
  log_fail "Нужно передать 3 пароля: admin, watcher, visitor"
  echo "Пример: ./scripts/seed_users_and_employees.sh SuperSecretPass123! watcher123 visitor123"
fi

ADMIN_PASS="$1"
WATCHER_PASS="$2"
VISITOR_PASS="$3"

# Запускаем Python‑скрипт с передачей паролей
python scripts/seed_db.py "$ADMIN_PASS" "$WATCHER_PASS" "$VISITOR_PASS"

log_ok "Seed-данные загружены"
echo ""
echo "📋 Готово! Теперь можно запускать тесты:"
echo "   ./scripts/test_api.sh"
