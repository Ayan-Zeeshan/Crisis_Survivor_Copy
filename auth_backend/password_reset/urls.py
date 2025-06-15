from django.urls import path
from .views import*
from password_reset.views import rotate_keys_view

urlpatterns = [
    path('send-code/', send_reset_code),
    path('verify-code/', verify_code),
    path('check-email/', check_email_exists),
    path('delete-user/', delete_user),
    path("rotate-keys/", rotate_keys_view),
]
