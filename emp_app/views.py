from django.contrib import admin
from django.db.models import Max
from django.shortcuts import get_object_or_404, redirect, render
from rest_framework import viewsets
from rest_framework.authentication import BasicAuthentication
from rest_framework.permissions import IsAuthenticated

from .forms import PhotoUploadForm
from .models import EmployeeProfile, Photo
from .permissions import IsAdmin, IsEditor, IsViewer
from .serializers import EmployeeProfileSerializer


class EmployeeProfileViewSet(viewsets.ModelViewSet):
    queryset = EmployeeProfile.objects.all()
    serializer_class = EmployeeProfileSerializer

    def get_queryset(self):
        queryset = EmployeeProfile.objects.all()

        skills = self.request.query_params.get("skills")
        min_experience = self.request.query_params.get("min_experience")
        max_experience = self.request.query_params.get("max_experience")

        if skills:
            skills_list = [s.strip() for s in skills.split(",")]
            queryset = queryset.filter(skills__name__in=skills_list).distinct()

        if min_experience:
            queryset = queryset.filter(experience_years__gte=min_experience)
        if max_experience:
            queryset = queryset.filter(experience_years__lte=max_experience)

        return queryset

    def get_permissions(self):
        if self.request.user.groups.filter(name="admin").exists():
            return [IsAuthenticated()]

        permission_classes = []

        if self.action in ["list", "retrieve"]:
            permission_classes = [IsViewer]
        elif self.action in ["create", "update", "partial_update"]:
            permission_classes = [IsEditor]
        elif self.action == "destroy":
            permission_classes = [IsAdmin]

        return [permission() for permission in permission_classes]
