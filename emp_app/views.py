from django.db import models
from django.shortcuts import render
from django.core.paginator import Paginator
from .models import EmployeeProfile, EmployeeImage

def employee_list(request):
    employees = EmployeeProfile.objects.order_by('id')  # <-- порядок обязателен для пагинации

    paginator = Paginator(employees, 10)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)

    # latest_4: тоже с порядком
    latest_4 = EmployeeProfile.objects.order_by('-id')[:4]

    return render(request, 'emp_app/employee_list.html', {
        'page_obj': page_obj,
        'latest_4': latest_4,
    })

from django.shortcuts import render, get_object_or_404
from .models import EmployeeProfile

def employee_detail(request, pk):
    employee = get_object_or_404(EmployeeProfile, pk=pk)
    # Получаем связанные фото с порядком по полю order
    images = employee.images.order_by('order')

    return render(request, 'emp_app/employee_detail.html', {
        'employee': employee,
        'images': images,
    })

from django.shortcuts import render, get_object_or_404, redirect
from .models import EmployeeProfile, EmployeeImage
from django.forms import ModelForm

class PhotoUploadForm(ModelForm):
    class Meta:
        model = EmployeeImage
        fields = ['image', 'order']

def employee_upload_photo(request, pk):
    employee = get_object_or_404(EmployeeProfile, pk=pk)

    if request.method == 'POST':
        form = PhotoUploadForm(request.POST, request.FILES)
        if form.is_valid():
            photo = form.save(commit=False)
            photo.employee = employee
            # Если порядок не указан, ставим следующий доступный
            if not photo.order:
                next_order = employee.images.aggregate(max_order=models.Max('order'))['max_order'] or 0
                photo.order = next_order + 1
            photo.save()
            return redirect('employee_detail', pk=employee.pk)
    else:
        form = PhotoUploadForm()

    return render(request, 'emp_app/upload_photo.html', {
        'employee': employee,
        'form': form,
    })

from rest_framework import viewsets
from .models import EmployeeProfile
from .serializers import EmployeeProfileSerializer

class EmployeeProfileViewSet(viewsets.ModelViewSet):
    queryset = EmployeeProfile.objects.all()
    serializer_class = EmployeeProfileSerializer
