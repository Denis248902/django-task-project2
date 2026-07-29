#!/usr/bin/env bash
set -e

FILE="emp_app/views.py"

cat > "$FILE.tmp" << 'PYEOF'
import csv
from io import StringIO
from django.http import HttpResponse, JsonResponse
from django.shortcuts import render, get_object_or_404, redirect
from django.contrib import messages
from django.core.paginator import Paginator
from django.db.models import Q, Count, Avg
from django.views.decorators.cache import cache_page
from django.core.exceptions import ValidationError
from datetime import date
from .models import EmployeeProfile, EmployeeImage

@cache_page(60)
def employee_list(request):
    query = request.GET.get('q', '')
    employees = EmployeeProfile.objects.all()

    if query:
        employees = employees.filter(
            Q(full_name__icontains=query) |
            Q(position__icontains=query)
        )

    total_employees = employees.count()
    latest_4 = employees.order_by('-hire_date')[:4]

    paginator = Paginator(employees, 10)  # 10 на страницу
    page_number = request.GET.get('page', 1)
    page_obj = paginator.get_page(page_number)

    return render(request, 'emp_app/employee_list.html', {
        'page_obj': page_obj,
        'query': query,
        'total_employees': total_employees,
        'latest_4': latest_4,
    })

def employee_detail(request, pk):
    employee = get_object_or_404(EmployeeProfile, pk=pk)
    images = employee.images.order_by('order')
    return render(request, 'emp_app/employee_detail.html', {
        'employee': employee,
        'images': images,
    })

def employee_upload_photo(request, pk):
    if request.method != 'POST':
        return redirect('employee_detail', pk=pk)

    employee = get_object_or_404(EmployeeProfile, pk=pk)
    image_file = request.FILES.get('image')

    if not image_file:
        messages.error(request, "Файл не выбран.")
        return redirect('employee_detail', pk=pk)

    allowed_types = ['image/jpeg', 'image/png', 'image/gif']
    if image_file.content_type not in allowed_types:
        messages.error(request, "Ошибка: разрешены только JPG, PNG, GIF.")
        return redirect('employee_detail', pk=pk)

    max_size_bytes = 5 * 1024 * 1024
    if image_file.size > max_size_bytes:
        messages.error(request, f"Ошибка: файл слишком большой. Максимум 5 МБ.")
        return redirect('employee_detail', pk=pk)

    order = request.POST.get('order', 0)
    try:
        order = int(order) if str(order).isdigit() else 0
    except ValueError:
        order = 0

    EmployeeImage.objects.create(
        employee=employee,
        image=image_file,
        order=order
    )
    messages.success(request, "Фото успешно загружено!")
    return redirect('employee_detail', pk=pk)

def export_employees_csv(request):
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="employees.csv"'

    writer = csv.writer(response)
    writer.writerow(['ID', 'Full Name', 'Gender', 'Position', 'Photo URLs (comma-separated)'])

    for emp in EmployeeProfile.objects.all():
        photos = ", ".join([img.image.url for img in emp.images.order_by('order')])
        gender_text = 'Мужской' if emp.gender == 'M' else 'Женский'
        writer.writerow([emp.id, emp.full_name, gender_text, emp.position, photos])

    return response

def employee_stats(request):
    total_employees = EmployeeProfile.objects.count()
    total_images = EmployeeImage.objects.count()
    agg = EmployeeProfile.objects.annotate(img_count=Count('images')).aggregate(avg=Avg('img_count'))
    avg_gallery_len = agg['avg'] or 0
    top_employees = (
        EmployeeProfile.objects.annotate(img_count=Count('images'))
        .order_by('-img_count')[:3]
    )

    data = {
        "total_employees": total_employees,
        "total_images": total_images,
        "average_gallery_length": round(float(avg_gallery_len), 2),
        "top_employees": [
            {"full_name": e.full_name, "image_count": e.img_count}
            for e in top_employees
        ],
    }
    return JsonResponse(data)

def employee_report(request):
    stats_response = employee_stats(request)
    import json
    data = json.loads(stats_response.content.decode('utf-8'))
    return render(request, 'emp_app/report.html', data)
PYEOF

mv "$FILE.tmp" "$FILE"
echo "✅ employee_list view обновлён с total_employees и latest_4"
