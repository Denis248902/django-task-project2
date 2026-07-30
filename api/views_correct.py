from rest_framework import action, filters, status, viewsets
from rest_framework.response import Response

from emp_app.models import EmployeeProfile

from .serializers import EmployeeProfileSerializer


class IsAdminOrReadOnly(object):
    """Admin — полный доступ; остальные — только чтение."""

    def has_permission(self, request, view):
        if request.method in ["GET", "HEAD", "OPTIONS"]:
            return True
        return request.user.is_superuser


class IsWatcherOrAdmin(object):
    """Watcher (staff) и Admin могут перемещать сотрудников."""

    def has_permission(self, request, view):
        return request.user.is_staff or request.user.is_superuser


class EmployeeViewSet(viewsets.ModelViewSet):
    queryset = EmployeeProfile.objects.all()
    serializer_class = EmployeeProfileSerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["full_name", "position"]
    ordering_fields = ["hire_date", "years_of_experience"]

    permission_classes = [IsAdminOrReadOnly]

    def get_queryset(self):
        qs = super().get_queryset()
        min_exp = self.request.query_params.get("min_experience")
        max_exp = self.request.query_params.get("max_experience")

        if min_exp:
            qs = qs.filter(years_of_experience__gte=min_exp)
        if max_exp:
            qs = qs.filter(years_of_experience__lte=max_exp)

        return qs

    @action(methods=["post"], detail=True, permission_classes=[IsWatcherOrAdmin])
    def move_to_desk(self, request, pk=None):
        employee = self.get_object()
        desk = request.data.get("desk_number")
        if not desk:
            return Response(
                {"error": "desk_number required"}, status=status.HTTP_400_BAD_REQUEST
            )
        employee.desk_number = desk
        employee.save()
        return Response(
            {
                "id": employee.id,
                "full_name": employee.full_name,
                "desk_number": employee.desk_number,
            }
        )
