from django.urls import path
from . import api_views

urlpatterns = [
    # Health check & Mobile App Config
    path('health/', api_views.api_health, name='api_health'),
    path('mobile/config/', api_views.api_mobile_config, name='api_mobile_config'),
    path('mobile/devices/register/', api_views.api_register_mobile_device, name='api_register_mobile_device'),

    # Auth
    path('auth/login/', api_views.api_login, name='api_login'),
    path('auth/register/', api_views.api_register, name='api_register'),
    path('auth/me/', api_views.api_user_profile, name='api_user_profile'),
    path('auth/user/<int:user_id>/', api_views.api_user_profile, name='api_user_detail'),
    path('auth/profile/update/', api_views.api_update_profile, name='api_update_profile'),

    # Categories
    path('categories/', api_views.api_categories, name='api_categories'),

    # Products
    path('products/', api_views.api_products, name='api_products'),
    path('products/<int:pk>/', api_views.api_product_detail, name='api_product_detail'),
    path('products/<int:pk>/favorite/', api_views.api_toggle_favorite, name='api_toggle_favorite'),

    # Chat
    path('chat/rooms/', api_views.api_chat_rooms, name='api_chat_rooms'),
    path('chat/rooms/<int:room_id>/messages/', api_views.api_chat_messages, name='api_chat_messages'),

    # Reviews, Reports, Verification
    path('reviews/', api_views.api_reviews, name='api_reviews'),
    path('reports/', api_views.api_reports, name='api_reports'),
    path('verification/', api_views.api_verification, name='api_verification'),

    # Admin
    path('admin/overview/', api_views.api_admin_overview, name='api_admin_overview'),
    path('admin/products/<int:pk>/action/', api_views.api_admin_product_action, name='api_admin_product_action'),
]
