from rest_framework import permissions

class IsViewer(permissions.BasePermission):
    """Только просмотр (GET, HEAD, OPTIONS)"""
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return False

class IsEditor(permissions.BasePermission):
    """Просмотр + создание/редактирование (но не удаление)"""
    def has_permission(self, request, view):
        allowed_methods = ['GET', 'POST', 'PUT', 'PATCH', 'HEAD', 'OPTIONS']
        if request.method in allowed_methods:
            return True
        if request.method == 'DELETE':
            return False
        return False

class IsAdmin(permissions.BasePermission):
    """Всё разрешено (включая DELETE)"""
    def has_permission(self, request, view):
        return True
