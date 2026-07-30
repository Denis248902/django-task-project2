import os
from pathlib import Path

SETTINGS_FILE = Path("core/settings.py")
content = SETTINGS_FILE.read_text(encoding="utf-8")

# Добавляем STATIC_URL и STATICFILES_DIRS, если их нет
if "STATIC_URL" not in content:
    # Ищем BASE_DIR и вставляем после него
    lines = content.splitlines()
    new_lines = []
    inserted = False
    for line in lines:
        new_lines.append(line)
        if line.strip().startswith("BASE_DIR"):
            new_lines.append('STATIC_URL = "/static/"')
            new_lines.append('STATICFILES_DIRS = [BASE_DIR / "static"]')
            inserted = True
    if not inserted:
        # Если BASE_DIR не найден, добавляем в конец
        new_lines.append('STATIC_URL = "/static/"')
        new_lines.append('STATICFILES_DIRS = [BASE_DIR / "static"]')
    content = "\n".join(new_lines)

# Исправляем DIRS в TEMPLATES: заменяем [] на [BASE_DIR / "templates"]
if "'DIRS': []" in content:
    content = content.replace("'DIRS': []", "'DIRS': [BASE_DIR / \"templates\"]")
elif "'DIRS': [ ]" in content:  # на случай пробелов
    content = content.replace("'DIRS': [ ]", "'DIRS': [BASE_DIR / \"templates\"]")

SETTINGS_FILE.write_text(content, encoding="utf-8")
print("core/settings.py обновлён.")
