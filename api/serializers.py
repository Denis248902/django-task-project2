from rest_framework import serializers

from emp_app.models import EmployeeProfile


class EmployeeProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmployeeProfile
        fields = [
            "id",
            "full_name",
            "gender",
            "position",
            "desk_number",
            "hire_date",
            "years_of_experience",
        ]
