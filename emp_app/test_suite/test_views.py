from datetime import date

from django.core.exceptions import ValidationError
from django.test import TestCase

from emp_app.models import EmployeeProfile


class DeskValidatorTests(TestCase):
    """Тесты валидации: разработчики и тестировщики не могут сидеть на соседних столах"""

    def _create_employee(self, **kwargs):
        emp = EmployeeProfile(**kwargs)
        emp.full_clean()
        emp.save()
        return emp

    def test_developer_cannot_take_neighbor_desk(self):
        # Создаём соседа-разработчика
        self._create_employee(
            full_name="Neighbor Dev",
            gender="M",
            position="Dev",
            role="backend",
            hire_date=date(2019, 1, 1),
            desk_number=10,
        )

        # Пытаемся посадить другого разработчика на соседний стол — должна быть ошибка
        with self.assertRaises(ValidationError):
            self._create_employee(
                full_name="Bad Dev",
                gender="M",
                position="Dev",
                role="backend",
                hire_date=date(2023, 5, 5),
                desk_number=11,
            )

    def test_tester_cannot_take_neighbor_desk(self):
        # Создаём соседа-разработчика
        self._create_employee(
            full_name="Neighbor Dev",
            gender="M",
            position="Dev",
            role="backend",
            hire_date=date(2019, 1, 1),
            desk_number=10,
        )

        # Пытаемся посадить тестировщика на соседний стол — должна быть ошибка
        with self.assertRaises(ValidationError):
            self._create_employee(
                full_name="Bad Tester",
                gender="F",
                position="QA",
                role="tester",
                hire_date=date(2022, 7, 7),
                desk_number=9,
            )

    def test_manager_can_take_any_desk_next_to_dev(self):
        # Создаём разработчика
        self._create_employee(
            full_name="Good Dev",
            gender="M",
            position="Dev",
            role="backend",
            hire_date=date(2020, 5, 5),
            desk_number=10,
        )

        # Менеджер спокойно садится рядом — ошибки быть не должно
        try:
            manager = self._create_employee(
                full_name="Good Manager",
                gender="F",
                position="Manager",
                role="manager",
                hire_date=date(2020, 10, 10),
                desk_number=11,
            )
            self.assertIsNotNone(manager.pk)
        except ValidationError:
            self.fail(
                "Менеджер не должен получать ошибку валидации при соседстве с разработчиком"
            )
