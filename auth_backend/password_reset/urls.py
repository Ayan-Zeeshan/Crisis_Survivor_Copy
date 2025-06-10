from django.urls import path
from .views import check_email_exists, send_reset_code, verify_code

urlpatterns = [
    path('send-code/', send_reset_code),
    path('verify-code/', verify_code),
    path('check-email/', check_email_exists),
]
