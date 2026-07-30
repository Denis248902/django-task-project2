import django_filters

from .models import EmployeeProfile


class EmployeeFilter(django_filters.FilterSet):
    # Фильтр по навыкам: ищем совпадение хотя бы с одним навыком в списке
    skills = django_filters.CharFilter(method="filter_skills")

    # Фильтр по стажу (обрати внимание: используем years_of_experience, как в твоей модели)
    years_of_experience = django_filters.NumberFilter(field_name="years_of_experience")

    def filter_skills(self, queryset, name, value):
        # Ищем сотрудников, у которых в skills есть указанное значение (регистронезависимо)
        return queryset.filter(skills__icontains=value)

    class Meta:
        model = EmployeeProfile
        fields = ["years_of_experience"]
