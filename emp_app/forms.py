from django import forms

from .models import EmployeeProfile, Photo


class PhotoUploadForm(forms.ModelForm):
    class Meta:
        model = Photo
        fields = ["image", "order"]
