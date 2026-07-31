from django.contrib.auth.models import Group, User
from django.db import transaction


@transaction.atomic
def create_roles():
    # Создаём группы, если их нет
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
        {"username": "admin_user", "password": "Admin12345", "groups": [admin_group]},
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
            print(f"✅ Создан пользователь: {u['username']}")
        else:
            print(f"ℹ️ Пользователь {u['username']} уже существует — пропускаем.")


if __name__ == "__main__":
    create_roles()
