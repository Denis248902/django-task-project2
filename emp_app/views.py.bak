from django.contrib import admin
from django.shortcuts import render, redirect, get_object_or_404
from django.db.models import Max
from .models import EmployeeProfile, Photo
from .forms import PhotoUploadForm
from rest_framework import viewsets
from rest_framework.authentication import BasicAuthentication
from rest_framework.permissions import IsAuthenticated
from .serializers import EmployeeProfileSerializer
from .permissions import IsViewer, IsEditor, IsAdmin


class EmployeeProfileViewSet(viewsets.ModelViewSet):
    queryset = EmployeeProfile.objects.all()
    serializer_class = EmployeeProfileSerializer

    def get_permissions(self):
        # Сначала проверяем, является ли пользователь админом — тогда разрешаем всё
        if self.request.user.groups.filter(name='admin').exists():
            return [IsAuthenticated()]

        permission_classes = []

        # Обычная логика для не-админов
        if self.action in ['list', 'retrieve']:
            permission_classes = [IsViewer]
        elif self.action in ['create', 'update', 'partial_update']:
            permission_classes = [IsEditor]
        elif self.action == 'destroy':
            permission_classes = [IsAdmin]

        return [permission() for permission in permission_classes]
