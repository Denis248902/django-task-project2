#!/usr/bin/env bash
set -e

FILE="emp_app/views.py"
TMPFILE=$(mktemp)

# Заменяем форму так, чтобы она использовала только 'image' (без order)
awk '
{
    if ($0 ~ /class PhotoUploadForm(ModelForm):/) {
        in_form = 1
        print $0
        next
    }
    if (in_form && $0 ~ /^    class Meta:/) {
        print $0
        next
    }
    if (in_form && $0 ~ /^        model = EmployeeImage/) {
        print $0
        print "        fields = [\"image\"]"
        in_form = 0
        # Пропускаем старые строки с fields и т.д.
        skip_next = 2
        next
    }
    if (skip_next > 0) {
        skip_next--
        next
    }
    print $0
}
' "$FILE" > "$TMPFILE"

mv "$TMPFILE" "$FILE"
echo "✅ Форма временно исправлена: fields = ['image'] (без order)"
