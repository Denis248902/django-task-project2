
BASE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
VIEW_FILE="${BASE}/emp_app/views.py"
TMPFILE=$(mktemp)

if grep -q "order_by('id')" "$VIEW_FILE"; then
  echo "✅ Сортировка уже настроена в EmployeeProfileViewSet"
  rm "$TMPFILE" 2>/dev/null || true
  exit 0
fi

while IFS= read -r line; do
  if [[ "$line" =~ class\ EmployeeProfileViewSet\(viewsets\.ModelViewSet\): ]]; then
    echo "$line" >> "$TMPFILE"
    echo "    queryset = EmployeeProfile.objects.all().order_by('id')" >> "$TMPFILE"
  elif [[ "$line" =~ queryset\ =\ EmployeeProfile\.objects\.all() ]]; then
    # Если вдруг уже есть queryset без order_by — перезапишем
    echo "    queryset = EmployeeProfile.objects.all().order_by('id')" >> "$TMPFILE"
  else
    echo "$line" >> "$TMPFILE"
  fi
done < "$VIEW_FILE"

mv "$TMPFILE" "$VIEW_FILE"
echo "✅ Добавлена сортировка .order_by('id') — предупреждение пагинации исчезнет"
