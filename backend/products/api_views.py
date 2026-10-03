import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import authenticate, login as django_login
from django.contrib.auth.models import User
from django.shortcuts import get_object_or_404
from django.db.models import Q
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from .models import (
    Product, Category, UserProfile, Review, Report, ReportImage,
    VerificationRequest, ChatRoom, Message, Notification, CATEGORY_CHOICES
)

CATEGORY_CODE_MAP = {
    'หนังสือเรียน': 'books',
    'อิเล็กทรอนิกส์': 'electronics',
    'เครื่องแต่งกาย': 'clothing',
    'รองเท้า': 'shoes',
    'เครื่องประดับ': 'accessories',
    'ของใช้ในหอ': 'dorm',
    'อุปกรณ์การเรียน': 'stationary',
    'อุปกรณ์ออกกำลังกาย': 'sports',
}

def user_to_dict(user):
    if not user:
        return None
    profile = getattr(user, 'profile', None)
    avatar_url = ''
    if profile and profile.avatar:
        try:
            avatar_url = profile.avatar.url
        except Exception:
            avatar_url = ''

    is_verified = False
    if hasattr(user, 'verification'):
        is_verified = user.verification.status == 'approved'

    return {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'display_name': profile.display_name if (profile and profile.display_name) else (user.get_full_name() or user.username),
        'avatar': avatar_url,
        'phone_number': profile.phone_number if profile else '',
        'address': profile.address if profile else '',
        'bio': profile.bio if profile else '',
        'is_verified': is_verified,
        'is_staff': user.is_staff,
        'is_admin': user.is_staff or user.is_superuser,
    }

def category_to_dict(category):
    if not category:
        return None
    code = CATEGORY_CODE_MAP.get(category.name, f'cat_{category.id}')
    return {
        'id': category.id,
        'name': category.name,
        'icon': category.icon,
        'code': code,
    }

def product_to_dict(product, request=None, user=None):
    image_url = ''
    if product.image:
        try:
            image_url = product.image.url
            if request and not image_url.startswith('http'):
                image_url = request.build_absolute_uri(image_url)
        except Exception:
            image_url = ''

    is_fav = False
    if user and user.is_authenticated:
        is_fav = product.favorites.filter(id=user.id).exists()

    return {
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'price': float(product.price),
        'condition': product.condition,
        'image': image_url,
        'imageUrl': image_url,
        'category': category_to_dict(product.category),
        'seller': user_to_dict(product.seller),
        'status': product.status,
        'favorites_count': product.favorites.count(),
        'is_favorite': is_fav,
        'created_at': product.created_at.isoformat(),
        'updated_at': product.updated_at.isoformat(),
    }


# ==========================================
# 1. Health Check
# ==========================================
@api_view(['GET'])
@permission_classes([AllowAny])
def api_health(request):
    return Response({
        'status': 'ok',
        'app': 'UniMarket Mobile API',
        'target_client': 'Flutter Mobile & Web App (Port 50000)',
        'course': 'Mobile Application Development (Week 16 Course Project)',
        'branch': 'project',
        'version': '1.0.0',
        'oidc_server': {
            'status': 'active',
            'issuer': 'http://127.0.0.1:8000/openid',
            'client_id': 'unimarket-flutter',
            'redirect_uri': 'http://localhost:50000/callback',
        },
        'total_products': Product.objects.count(),
        'total_categories': Category.objects.count(),
    })


@api_view(['GET'])
@permission_classes([AllowAny])
def api_mobile_config(request):
    """
    Mobile App Initial Configuration & Feature Flags
    Consumed by Flutter app on startup
    """
    return Response({
        'app_name': 'UniMarket Mobile',
        'app_id': 'com.unimarket.mobiledev',
        'version': '1.0.0',
        'course_project': 'Mobile Dev Week 16',
        'developer': 'Kitthanakorn Chueaprathum (66114540047)',
        'min_supported_version': '1.0.0',
        'oidc': {
            'issuer': 'http://127.0.0.1:8000/openid',
            'client_id': 'unimarket-flutter',
            'redirect_uri': 'http://localhost:50000/callback',
            'scopes': ['openid', 'profile', 'email'],
        },
        'features': {
            'dark_mode': True,
            'realtime_chat': True,
            'student_verification': True,
            'my_listings': True,
            'multi_filter': True,
        },
        'campus': 'Ubon Ratchathani University (UBU)',
        'contact_support': 'somchai@ubu.ac.th',
    })


@api_view(['POST'])
@permission_classes([AllowAny])
def api_register_mobile_device(request):
    """
    Register connected mobile device / platform for push tokens & telemetry
    """
    platform = request.data.get('platform', 'flutter_web')
    device_model = request.data.get('device_model', 'Flutter Client')
    app_version = request.data.get('app_version', '1.0.0')

    return Response({
        'status': 'registered',
        'client': f'{device_model} ({platform})',
        'app_version': app_version,
        'server_timestamp': '2026-10-04T07:00:00Z',
    })



# ==========================================
# 2. Authentication
# ==========================================
@api_view(['POST'])
@permission_classes([AllowAny])
def api_login(request):
    username = request.data.get('username', '').strip()
    password = request.data.get('password', '').strip()

    user = authenticate(username=username, password=password)
    if user is None:
        # Check by email or fallback for demo
        try:
            user_obj = User.objects.filter(Q(username=username) | Q(email=username)).first()
            if user_obj and user_obj.check_password(password):
                user = user_obj
        except Exception:
            pass

    if user is None:
        return Response({'error': 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'}, status=status.HTTP_401_UNAUTHORIZED)

    return Response({
        'token': f'token_{user.id}_{user.username}',
        'user': user_to_dict(user),
    })

@api_view(['POST'])
@permission_classes([AllowAny])
def api_register(request):
    username = request.data.get('username', '').strip()
    email = request.data.get('email', '').strip()
    password = request.data.get('password', '').strip()
    display_name = request.data.get('display_name', '').strip()
    phone_number = request.data.get('phone_number', '').strip()

    if not username or not password:
        return Response({'error': 'กรุณากรอกชื่อผู้ใช้และรหัสผ่าน'}, status=status.HTTP_400_BAD_REQUEST)

    if User.objects.filter(username=username).exists():
        return Response({'error': 'ชื่อผู้ใช้นี้มีคนใช้แล้ว'}, status=status.HTTP_400_BAD_REQUEST)

    user = User.objects.create_user(username=username, email=email, password=password)
    profile, _ = UserProfile.objects.get_or_create(user=user)
    if display_name:
        profile.display_name = display_name
    if phone_number:
        profile.phone_number = phone_number
    profile.save()

    return Response({
        'token': f'token_{user.id}_{user.username}',
        'user': user_to_dict(user),
    }, status=status.HTTP_201_CREATED)

@api_view(['GET'])
@permission_classes([AllowAny])
def api_user_profile(request, user_id=None):
    if user_id:
        user = get_object_or_404(User, id=user_id)
    elif request.user.is_authenticated:
        user = request.user
    else:
        # Default fallback to first user or demo user
        user = User.objects.filter(is_superuser=False).first() or User.objects.first()
        if not user:
            return Response({'error': 'No user found'}, status=status.HTTP_404_NOT_FOUND)

    return Response(user_to_dict(user))

@api_view(['PUT', 'PATCH'])
@permission_classes([AllowAny])
def api_update_profile(request):
    user_id = request.data.get('user_id')
    user = User.objects.filter(id=user_id).first() if user_id else (request.user if request.user.is_authenticated else None)
    if not user:
        user = User.objects.first()

    profile, _ = UserProfile.objects.get_or_create(user=user)
    if 'display_name' in request.data:
        profile.display_name = request.data['display_name']
    if 'phone_number' in request.data:
        profile.phone_number = request.data['phone_number']
    if 'address' in request.data:
        profile.address = request.data['address']
    if 'bio' in request.data:
        profile.bio = request.data['bio']
    profile.save()

    return Response(user_to_dict(user))


# ==========================================
# 3. Categories
# ==========================================
@api_view(['GET'])
@permission_classes([AllowAny])
def api_categories(request):
    categories = Category.objects.all()
    data = [category_to_dict(c) for c in categories]
    return Response(data)


# ==========================================
# 4. Products
# ==========================================
@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def api_products(request):
    if request.method == 'GET':
        qs = Product.objects.all().select_related('category', 'seller', 'seller__profile')

        category_id = request.query_params.get('category')
        if category_id:
            qs = qs.filter(category_id=category_id)

        condition = request.query_params.get('condition')
        if condition in ['new', 'used']:
            qs = qs.filter(condition=condition)

        search = request.query_params.get('search')
        if search:
            qs = qs.filter(Q(name__icontains=search) | Q(description__icontains=search))

        status_param = request.query_params.get('status')
        if status_param:
            qs = qs.filter(status=status_param)
        else:
            # Default to active products unless specified
            if not request.query_params.get('all'):
                qs = qs.filter(status='active')

        seller_id = request.query_params.get('seller_id')
        if seller_id:
            qs = qs.filter(seller_id=seller_id)

        qs = qs.order_by('-created_at')
        current_user = request.user if request.user.is_authenticated else None
        data = [product_to_dict(p, request=request, user=current_user) for p in qs]
        return Response(data)

    elif request.method == 'POST':
        # Create product
        name = request.data.get('name', '').strip()
        description = request.data.get('description', '').strip()
        price = request.data.get('price', 0)
        condition = request.data.get('condition', 'used')
        category_id = request.data.get('category_id')
        seller_id = request.data.get('seller_id')

        seller = None
        if seller_id:
            seller = User.objects.filter(id=seller_id).first()
        if not seller and request.user.is_authenticated:
            seller = request.user
        if not seller:
            seller = User.objects.filter(is_superuser=False).first() or User.objects.first()

        category = None
        if category_id:
            category = Category.objects.filter(id=category_id).first()

        product = Product.objects.create(
            name=name,
            description=description,
            price=price,
            condition=condition,
            category=category,
            seller=seller,
            status='active',
        )

        if 'image' in request.FILES:
            product.image = request.FILES['image']
            product.save()

        return Response(product_to_dict(product, request=request, user=seller), status=status.HTTP_201_CREATED)

@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
@permission_classes([AllowAny])
def api_product_detail(request, pk):
    product = get_object_or_404(Product, pk=pk)

    if request.method == 'GET':
        return Response(product_to_dict(product, request=request, user=request.user))

    elif request.method in ['PUT', 'PATCH']:
        if 'name' in request.data:
            product.name = request.data['name']
        if 'description' in request.data:
            product.description = request.data['description']
        if 'price' in request.data:
            product.price = request.data['price']
        if 'condition' in request.data:
            product.condition = request.data['condition']
        if 'status' in request.data:
            product.status = request.data['status']
        if 'category_id' in request.data:
            product.category = Category.objects.filter(id=request.data['category_id']).first()
        if 'image' in request.FILES:
            product.image = request.FILES['image']

        product.save()
        return Response(product_to_dict(product, request=request, user=request.user))

    elif request.method == 'DELETE':
        product.delete()
        return Response({'message': 'ลบสินค้าสำเร็จ'}, status=status.HTTP_204_NO_CONTENT)

@api_view(['POST'])
@permission_classes([AllowAny])
def api_toggle_favorite(request, pk):
    product = get_object_or_404(Product, pk=pk)
    user_id = request.data.get('user_id')
    user = User.objects.filter(id=user_id).first() if user_id else (request.user if request.user.is_authenticated else User.objects.first())

    if not user:
        return Response({'error': 'User not found'}, status=status.HTTP_400_BAD_REQUEST)

    if product.favorites.filter(id=user.id).exists():
        product.favorites.remove(user)
        is_fav = False
    else:
        product.favorites.add(user)
        is_fav = True

    return Response({
        'is_favorite': is_fav,
        'favorites_count': product.favorites.count(),
    })


# ==========================================
# 5. Chat System
# ==========================================
@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def api_chat_rooms(request):
    user_id = request.query_params.get('user_id') or request.data.get('user_id')
    user = User.objects.filter(id=user_id).first() if user_id else (request.user if request.user.is_authenticated else User.objects.first())

    if request.method == 'GET':
        if not user:
            return Response([])
        rooms = ChatRoom.objects.filter(participants=user).order_by('-created_at')
        res = []
        for r in rooms:
            other = r.get_other_user(user)
            last_msg = r.messages.last()
            res.append({
                'id': r.id,
                'other_user': user_to_dict(other),
                'last_message': last_msg.content if last_msg else '',
                'last_message_time': last_msg.timestamp.isoformat() if last_msg else r.created_at.isoformat(),
                'unread_count': r.messages.filter(is_read=False).exclude(sender=user).count(),
            })
        return Response(res)

    elif request.method == 'POST':
        other_user_id = request.data.get('other_user_id')
        other_user = get_object_or_404(User, id=other_user_id)

        # Check existing room
        existing = ChatRoom.objects.filter(participants=user).filter(participants=other_user).first()
        if existing:
            return Response({'id': existing.id, 'other_user': user_to_dict(other_user)})

        room = ChatRoom.objects.create()
        room.participants.add(user, other_user)
        return Response({'id': room.id, 'other_user': user_to_dict(other_user)}, status=status.HTTP_201_CREATED)

@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def api_chat_messages(request, room_id):
    room = get_object_or_404(ChatRoom, id=room_id)
    user_id = request.query_params.get('user_id') or request.data.get('user_id')
    user = User.objects.filter(id=user_id).first() if user_id else (request.user if request.user.is_authenticated else User.objects.first())

    if request.method == 'GET':
        msgs = room.messages.all().order_by('timestamp')
        data = [{
            'id': m.id,
            'room_id': room.id,
            'sender_id': m.sender.id,
            'sender_name': m.sender.username,
            'content': m.content,
            'image': m.image.url if m.image else '',
            'timestamp': m.timestamp.isoformat(),
            'is_mine': m.sender_id == user.id if user else False,
        } for m in msgs]
        return Response(data)

    elif request.method == 'POST':
        content = request.data.get('content', '')
        if not content:
            return Response({'error': 'Message content cannot be empty'}, status=status.HTTP_400_BAD_REQUEST)

        msg = Message.objects.create(
            room=room,
            sender=user,
            content=content,
        )
        return Response({
            'id': msg.id,
            'room_id': room.id,
            'sender_id': msg.sender.id,
            'sender_name': msg.sender.username,
            'content': msg.content,
            'timestamp': msg.timestamp.isoformat(),
            'is_mine': True,
        }, status=status.HTTP_201_CREATED)


# ==========================================
# 6. Reviews & Reports & Verification
# ==========================================
@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def api_reviews(request):
    if request.method == 'GET':
        seller_id = request.query_params.get('seller_id')
        qs = Review.objects.all().select_related('reviewer', 'seller')
        if seller_id:
            qs = qs.filter(seller_id=seller_id)
        qs = qs.order_by('-created_at')

        data = [{
            'id': r.id,
            'reviewer': user_to_dict(r.reviewer),
            'seller_id': r.seller_id,
            'rating': r.rating,
            'comment': r.comment or '',
            'created_at': r.created_at.isoformat(),
        } for r in qs]
        return Response(data)

    elif request.method == 'POST':
        reviewer_id = request.data.get('reviewer_id')
        seller_id = request.data.get('seller_id')
        rating = int(request.data.get('rating', 5))
        comment = request.data.get('comment', '')

        reviewer = User.objects.filter(id=reviewer_id).first() or request.user
        seller = get_object_or_404(User, id=seller_id)

        review = Review.objects.create(
            reviewer=reviewer,
            seller=seller,
            rating=rating,
            comment=comment,
        )
        return Response({'id': review.id, 'message': 'รีวิวสำเร็จ'}, status=status.HTTP_201_CREATED)

@api_view(['POST'])
@permission_classes([AllowAny])
def api_reports(request):
    reporter_id = request.data.get('reporter_id')
    reporter = User.objects.filter(id=reporter_id).first() or (request.user if request.user.is_authenticated else User.objects.first())
    reason = request.data.get('reason', 'other')
    details = request.data.get('details', '')
    product_id = request.data.get('product_id')
    contact_info = request.data.get('contact_info', '')

    product = Product.objects.filter(id=product_id).first() if product_id else None

    report = Report.objects.create(
        reporter=reporter,
        product=product,
        reason=reason,
        details=details,
        contact_info=contact_info,
        status='pending',
    )
    return Response({'id': report.id, 'message': 'ส่งรายงานปัญหาเรียบร้อยแล้ว'}, status=status.HTTP_201_CREATED)

@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def api_verification(request):
    user_id = request.data.get('user_id') or request.query_params.get('user_id')
    user = User.objects.filter(id=user_id).first() if user_id else (request.user if request.user.is_authenticated else User.objects.first())

    if request.method == 'GET':
        if not user or not hasattr(user, 'verification'):
            return Response({'status': 'none'})
        v = user.verification
        return Response({
            'status': v.status,
            'admin_comment': v.admin_comment or '',
            'created_at': v.created_at.isoformat(),
        })

    elif request.method == 'POST':
        req, _ = VerificationRequest.objects.get_or_create(user=user)
        req.status = 'pending'
        if 'student_card_image' in request.FILES:
            req.student_card_image = request.FILES['student_card_image']
        req.save()
        return Response({'message': 'ส่งคำขอยืนยันตัวตนสำเร็จ', 'status': 'pending'})


# ==========================================
# 7. Admin Moderation
# ==========================================
@api_view(['GET'])
@permission_classes([AllowAny])
def api_admin_overview(request):
    pending_products = Product.objects.filter(status='pending').count()
    active_products = Product.objects.filter(status='active').count()
    pending_verifications = VerificationRequest.objects.filter(status='pending').count()
    pending_reports = Report.objects.filter(status='pending').count()
    total_users = User.objects.count()

    return Response({
        'pending_products': pending_products,
        'active_products': active_products,
        'pending_verifications': pending_verifications,
        'pending_reports': pending_reports,
        'total_users': total_users,
    })

@api_view(['POST'])
@permission_classes([AllowAny])
def api_admin_product_action(request, pk):
    product = get_object_or_404(Product, pk=pk)
    action = request.data.get('action') # 'approve', 'reject', 'suspend'

    if action == 'approve':
        product.status = 'active'
    elif action == 'reject':
        product.status = 'rejected'
    elif action == 'suspend':
        product.status = 'suspended'
    product.save()

    return Response({'id': product.id, 'status': product.status, 'message': f'สถานะสินค้าเปลี่ยนเป็น {product.get_status_display()}'})
