#!/usr/bin/env bash
set -euo pipefail

BASE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
VIEW_FILE="${BASE}/emp_app/views.py"

# Если уже есть импорт — ничего не делаем
if grep -q "from .permissions import IsAdminOrReadOnly" "$VIEW_FILE"; then
  echo "✅ Импорт прав уже добавлен"
  exit 0
fi

TMPFILE=$(mktemp)
added_import=false

while IFS= read -r line; do
  # Вставляем импорт после всех других импортов, но до классов
  if [[ "$line" =~ ^from.*models.*$ ]] && [ "$added_import" = false ]; then
    echo "$line" >> "$TMPFILE"
    echo "from .permissions import IsAdminOrReadOnly" >> "$TMPFILE"
    added_import=true
  else
    echo "$line" >> "$TMPFILE"
  fi
done < "$VIEW_FILE"

if [ "$added_import" = false ]; then
  # Если не нашли место, просто добавляем в конец (не идеально, но сработает)
  cat "$VIEW_FILE" > "$TMPFILE"
  echo "" >> "$TMPFILE"
  echo "from .permissions import IsAdminOrReadOnly" >> "$TMPFILE"
fi

mv "$TMPFILE" "$VIEW_FILE"
echo "✅ Добавлен импорт IsAdminOrReadOnly в emp_app/views.py"
