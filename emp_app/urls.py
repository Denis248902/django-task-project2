from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import EmployeeProfileViewSet

router = DefaultRouter()
router.register(r'employees', EmployeeProfileViewSet, basename='employee')

urlpatterns = [
    path('', include(router.urls)),
]
