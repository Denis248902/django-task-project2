from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import EmployeeProfileViewSet  # <-- исправлено: теперь берём из views.py

router = DefaultRouter()
# Лучше явно указать путь, чтобы не было путаницы
router.register(r"employees", EmployeeProfileViewSet, basename="employee")

urlpatterns = [
    path("", include(router.urls)),
]
