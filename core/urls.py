from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.contrib.auth import views as auth_views
from django.urls import include, path

urlpatterns = [
    path("admin/", admin.site.urls),
    path(
        "login/",
        auth_views.LoginView.as_view(template_name="registration/login.html"),
        name="login",
    ),
    path("logout/", auth_views.LogoutView.as_view(), name="logout"),
    # API: только сюда подключаем emp_app для REST
    path("api/employees/", include("emp_app.urls")),
    # Обычные страницы (если нужны) — подключай отдельно, если есть отдельный urls для них
    # path('employees/', include('emp_app.browser_urls')),  # <-- пока не добавляй, если нет такого файла
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
