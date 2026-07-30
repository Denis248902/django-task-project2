from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets
from rest_framework.authentication import BasicAuthentication
from rest_framework.permissions import AllowAny, IsAuthenticated

from .filters import EmployeeFilter
from .models import EmployeeProfile
from .serializers import EmployeeProfileSerializer


class EmployeeProfileViewSet(viewsets.ModelViewSet):
    queryset = EmployeeProfile.objects.all()
    serializer_class = EmployeeProfileSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_class = EmployeeFilter

    def get_permissions(self):
        """
        Разрешаем GET (list/retrieve) всем, остальные методы — только авторизованным.
        """
        if self.action in ["list", "retrieve"]:
            return [AllowAny()]
        return [IsAuthenticated()]

    def get_authentication_classes(self):
        """
        Для GET не требуем Basic Auth, для остальных — требуем.
        Это важно, чтобы DRF не пытался сразу отвергнуть запрос до проверки permissions.
        """
        if self.action in ["list", "retrieve"]:
            return []
        return [BasicAuthentication]
