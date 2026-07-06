from django.urls import path
from . import views

urlpatterns = [
    path("", views.dashboard, name="dashboard"),
    path("execute/", views.execute_query, name="execute_query"),
]
