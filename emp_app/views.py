from django.db.models import Max
from django.shortcuts import get_object_or_404, redirect, render
from rest_framework import viewsets
from rest_framework.authentication import BasicAuthentication
from rest_framework.permissions import IsAuthenticated

from .forms import PhotoUploadForm
from .models import EmployeeProfile, Photo
from .permissions import IsAdminOrReadOnly
from .serializers import EmployeeProfileSerializer


# --- Обычное Django вью (для браузера: загрузка фото) ---
def upload_photo(request, pk):
    employee = get_object_or_404(EmployeeProfile, pk=pk)

    if request.method == "POST":
        form = PhotoUploadForm(request.POST, request.FILES)
        if form.is_valid():
            photo = form.save(commit=False)
            photo.employee = employee

            # Если порядок не указан, ставим следующий доступный
            if not photo.order:
                next_order = (
                    employee.images.aggregate(max_order=Max("order"))["max_order"] or 0
                )
                photo.order = next_order + 1

            photo.save()
            return redirect("employee_detail", pk=employee.pk)
    else:
        form = PhotoUploadForm()

    return render(
        request,
        "emp_app/upload_photo.html",
        {
            "employee": employee,
            "form": form,
        },
    )


# --- DRF ViewSet (для API: CRUD сотрудников) ---
class EmployeeProfileViewSet(viewsets.ModelViewSet):
    queryset = EmployeeProfile.objects.all().order_by("id")
    serializer_class = EmployeeProfileSerializer
    authentication_classes = [BasicAuthentication]
    permission_classes = [IsAuthenticated]
