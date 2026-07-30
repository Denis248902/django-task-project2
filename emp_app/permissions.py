from rest_framework import permissions


class IsAdminOrReadOnly(permissions.BasePermission):
    """
    Разрешение только администратору на запись (POST/PUT/PATCH/DELETE).
    Остальные могут только читать (GET/HEAD/OPTIONS).
    """

    def has_permission(self, request, view):
        # Разрешаем любые запросы, если пользователь — admin
        if request.user.is_superuser:
            return True

        # Разрешаем только безопасные методы (GET, HEAD, OPTIONS) для остальных
        return request.method in permissions.SAFE_METHODS
