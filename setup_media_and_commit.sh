#!/usr/bin/env bash
set -e

echo "📁 Создаём папку media..."
mkdir -p media

echo "⚙️ Добавляем MEDIA_URL и MEDIA_ROOT в settings.py..."
cat >> core/settings.py <<SETTINGS_EOF
import os
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
SETTINGS_EOF

echo "🌐 Добавляем media URLs в core/urls.py..."
cat >> core/urls.py <<URLS_EOF
from django.conf import settings
from django.conf.urls.static import static
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
URLS_EOF

echo "🎨 Исправляем шаблоны (order_index -> order)..."
sed -i "s/{{ *img\.order_index *}}/{{ img.order }}/g" emp_app/templates/emp_app/employee_detail.html
sed -i "s/alt=\"[^\"]*order_index[^\"]*\"/alt=\"Фото #{{ img.order }}\"/g" emp_app/templates/emp_app/employee_detail.html

echo "✅ Проверка системы..."
python manage.py check

echo "💾 Коммит изменений..."
git add core/settings.py core/urls.py emp_app/templates/emp_app/employee_detail.html
git commit -m "feat: add media settings, connect media URLs, fix gallery template"
git push origin main

echo ""
echo "🎉 Готово! Теперь можно загружать фото и они будут отображаться."
