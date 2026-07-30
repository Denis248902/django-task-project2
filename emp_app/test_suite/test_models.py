from datetime import date

from django.core.exceptions import ValidationError
from django.test import TestCase

from emp_app.models import EmployeeProfile


class EmployeeValidationTest(TestCase):
    def test_tester_and_dev_cannot_be_neighbors(self):
        # Создаём тестировщика за столом 2
        tester = EmployeeProfile.objects.create(
            full_name="Tester A",
            gender="M",
            position="QA",
            role="tester",
            desk_number=2,
            hire_date=date.today(),
        )

        # Пытаемся создать бэкендера за столом 3 — должно упасть
        dev = EmployeeProfile(
            full_name="Dev B",
            gender="F",
            position="Backend",
            role="backend",
            desk_number=3,
            hire_date=date.today(),
        )
        with self.assertRaises(ValidationError):
            dev.full_clean()


# #     def test_same_role_can_be_neighbors(self):
# #         # Два разработчика могут сидеть рядом
# #         dev1 = EmployeeProfile.objects.create(
# #             full_name='Dev 1',
# #             gender='M',
# #             position='Backend',
# #             role='backend',
# #             desk_number=5,
# #             hire_date=date.today()
# #         )
# #         dev2 = EmployeeProfile(
# #             full_name='Dev 2',
# #             gender='F',
# #             position='Frontend',
# #             role='frontend',
# #             desk_number=6,
# #             hire_date=date.today()
# #         )
# #         # Не должно падать
# #         dev2.full_clean()
