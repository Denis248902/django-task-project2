#!/usr/bin/env bash
set -euo pipefail

BASE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
URLS_FILE="${BASE}/core/urls.py"

# Проверяем, нет ли уже этой строки
if grep -q "path('api/', include('emp_app.urls'))" "$URLS_FILE"; then
  echo "✅ Путь к API уже добавлен в core/urls.py"
  exit 0
fi

# Создаём временный файл
TMPFILE=$(mktemp)

found_admin=false

while IFS= read -r line; do
  echo "$line" >> "$TMPFILE"
  if [[ "$line" == *"path('admin/',"* ]]; then
    found_admin=true
    # Сразу после admin/ добавляем путь к API
    echo "    path('api/', include('emp_app.urls'))," >> "$TMPFILE"
  fi
done < "$URLS_FILE"

if [ "$found_admin" = false ]; then
  echo "❌ Не удалось найти path('admin/', ...). Проверь core/urls.py вручную." >&2
  rm "$TMPFILE"
  exit 1
fi

mv "$TMPFILE" "$URLS_FILE"
echo "✅ Добавлен path('api/', include('emp_app.urls')) в core/urls.py"
