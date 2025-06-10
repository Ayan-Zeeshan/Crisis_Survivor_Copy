from django.urls import path
from .views import*

urlpatterns = [
    path('send-code/', send_reset_code),
    path('verify-code/', verify_code),
    path('check-email/', check_email_exists),
    path('delete-user/', delete_user),
]
