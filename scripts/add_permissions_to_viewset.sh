#!/usr/bin/env bash
set -euo pipefail

BASE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
VIEW_FILE="${BASE}/emp_app/views.py"
TMPFILE=$(mktemp)

# Проверяем, нет ли уже permission_classes
if grep -q "permission_classes" "$VIEW_FILE"; then
  echo "✅ Права уже настроены в emp_app/views.py"
  exit 0
fi

while IFS= read -r line; do
  if [[ "$line" == *"class EmployeeProfileViewSet(viewsets.ModelViewSet):"* ]]; then
    echo "$line" >> "$TMPFILE"
    echo "    permission_classes = [IsAdminOrReadOnly]" >> "$TMPFILE"
  else
    echo "$line" >> "$TMPFILE"
  fi
done < "$VIEW_FILE"

mv "$TMPFILE" "$VIEW_FILE"
echo "✅ Добавлены permission_classes в EmployeeProfileViewSet"
