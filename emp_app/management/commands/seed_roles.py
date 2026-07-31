from django.contrib.auth.models import Group, User
from django.core.management.base import BaseCommand
from django.db import transaction


class Command(BaseCommand):
    help = "Создаёт группы viewer/editor/admin и тестовых пользователей"

    @transaction.atomic
    def handle(self, *args, **options):
        # Группы
        viewer_group, _ = Group.objects.get_or_create(name="viewer")
        editor_group, _ = Group.objects.get_or_create(name="editor")
        admin_group, _ = Group.objects.get_or_create(name="admin")

        users = [
            {
                "username": "viewer_user",
                "password": "Viewer12345",
                "groups": [viewer_group],
            },
            {
                "username": "editor_user",
                "password": "Editor12345",
                "groups": [editor_group],
            },
            {
                "username": "admin_user",
                "password": "Admin12345",
                "groups": [admin_group],
            },
        ]

        for u in users:
            user, created = User.objects.get_or_create(username=u["username"])
            if created:
                user.set_password(u["password"])
                user.is_staff = True
                if u["username"] == "admin_user":
                    user.is_superuser = True
                user.save()
                user.groups.set(u["groups"])
                self.stdout.write(
                    self.style.SUCCESS(f'✅ Создан пользователь: {u["username"]}')
                )
            else:
                self.stdout.write(
                    self.style.WARNING(
                        f'ℹ️ Пользователь {u["username"]} уже существует — пропускаем.'
                    )
                )
