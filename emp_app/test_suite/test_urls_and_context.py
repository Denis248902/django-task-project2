from datetime import date

from django.test import Client, TestCase
from django.urls import reverse

from emp_app.models import EmployeeProfile


class UrlAndContextTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        # Создаём сотрудников БЕЗ картинок — чтобы шаблон не падал в тестах
        cls.dev = EmployeeProfile.objects.create(
            full_name="Dev One",
            gender="M",
            position="Dev",
            role="backend",
            hire_date=date(2020, 1, 1),
            desk_number=10,
        )
        cls.manager = EmployeeProfile.objects.create(
            full_name="Manager One",
            gender="F",
            position="Manager",
            role="manager",
            hire_date=date(2019, 5, 5),
            desk_number=20,
        )

    def setUp(self):
        self.client = Client()

    def test_employee_list_url_exists(self):
        """URL /employees/ должен возвращать 200"""
        response = self.client.get("/employees/")
        self.assertEqual(response.status_code, 200)

    def test_employee_list_context_contains_employees(self):
        """В контексте страницы должен быть список сотрудников"""
        response = self.client.get("/employees/")
        self.assertIn("employees", response.context)
        self.assertIsInstance(response.context["employees"], list)
        self.assertEqual(
            len(response.context["employees"]), EmployeeProfile.objects.count()
        )

    def test_nonexistent_page_returns_404(self):
        """Несуществующая страница должна возвращать 404"""
        response = self.client.get("/nonexistent-page/")
        self.assertEqual(response.status_code, 404)
