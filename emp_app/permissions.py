from rest_framework import permissions


class IsViewer(permissions.BasePermission):
    """Только просмотр (GET, HEAD, OPTIONS) + только для группы viewer"""

    def has_permission(self, request, view):
        # Сначала проверяем метод
        if request.method not in permissions.SAFE_METHODS:
            return False

        # Потом проверяем группу
        if not request.user.is_authenticated:
            return False

        return request.user.groups.filter(name="viewer").exists()


class IsEditor(permissions.BasePermission):
    """Создание/редактирование + только для группы editor"""

    def has_permission(self, request, view):
        # Запрещаем DELETE
        if request.method == "DELETE":
            return False

        if not request.user.is_authenticated:
            return False

        # Разрешаем всё остальное, только если пользователь в группе editor
        return request.user.groups.filter(name="editor").exists()


class IsAdmin(permissions.BasePermission):
    """Полный доступ + только для группы admin"""

    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False

        return request.user.groups.filter(name="admin").exists()
