import random, string
from django.core.mail import send_mail
from django.http import JsonResponse
from .firebase import*
from .firebase import auth as firebase_auth  # ✅ Use initialized firebase from firebase.py
print("Firebase initialized:", firebase_admin._apps)
from .redis_client import redis  # ✅ Use shared redis instance
from django.views.decorators.csrf import csrf_exempt
import os
import json

@csrf_exempt
def check_email_exists(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'Invalid method'}, status=405)

    try:
        data = json.loads(request.body)
        email = data.get('email')

        if not email:
            return JsonResponse({'error': 'Email required'}, status=400)

        try:
            firebase_auth.get_user_by_email(email)
            exists = True
        except firebase_auth.UserNotFoundError:
            exists = False

        return JsonResponse({'exists': exists})

    except Exception as e:
        return JsonResponse({'error': 'Server error'}, status=500)

def generate_code(length=8):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

@csrf_exempt
def send_reset_code(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'Invalid method'}, status=405)

    try:
        data = json.loads(request.body)
        email = data.get('email')

        if not email:
            return JsonResponse({'error': 'Email required'}, status=400)

        try:
            user = firebase_auth.get_user_by_email(email)
        except firebase_auth.UserNotFoundError:
            return JsonResponse({'error': 'User not found'}, status=404)

        reset_code = str(random.randint(100000, 999999))
        redis.setex(f"reset:{email}", 300, reset_code)

        send_mail(
            subject="Your Password Reset Code",
            message=f"Your code is: {reset_code}",
            from_email="crisissurvivor3@gmail.com",
            recipient_list=[email],
            fail_silently=False,
        )

        return JsonResponse({'success': True})

    except Exception as e:
        return JsonResponse({'error': 'Server error', 'details': str(e)}, status=500)

# @csrf_exempt
# def verify_code(request):
#     if request.method != 'POST':
#         return JsonResponse({'error': 'Invalid method'}, status=405)

#     data = json.loads(request.body)
#     email = data.get('email')
#     code = data.get('code')

#     stored_code = redis.get(f'reset:{email}')
#     if stored_code is None:
#         return JsonResponse({'error': 'Code expired or not found'}, status=400)

#     if stored_code.decode('utf-8') != code:
#         return JsonResponse({'error': 'Invalid code'}, status=401)

#     user = firebase_auth.get_user_by_email(email)
#     custom_token = firebase_auth.create_custom_token(user.uid)

#     redis.delete(f'reset:{email}')

#     return JsonResponse({'token': custom_token.decode('utf-8')})
@csrf_exempt
def verify_code(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'Invalid method'}, status=405)

    data = json.loads(request.body)
    email = data.get('email')
    code = data.get('code')

    stored_code = redis.get(f'reset:{email}')
    if stored_code is None:
        return JsonResponse({'error': 'Code expired or not found'}, status=400)

    if stored_code != code:
    #.decode('utf-8')
        return JsonResponse({'error': 'Invalid code'}, status=401)

    user = firebase_auth.get_user_by_email(email)
    custom_token = firebase_auth.create_custom_token(user.uid)

    redis.delete(f'reset:{email}')

    return JsonResponse({
        'success': True,
        'message': 'Verification successful.',
        'token': custom_token.decode('utf-8')
    })
