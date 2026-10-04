from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from oidc_provider.models import Token as OidcToken

class OidcTokenAuthentication(BaseAuthentication):
    """
    Authenticate against django-oidc-provider Token using Bearer <access_token>
    """
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization') or request.META.get('HTTP_AUTHORIZATION')
        if not auth_header:
            return None

        parts = auth_header.split()
        if len(parts) != 2:
            return None

        prefix = parts[0].lower()
        if prefix not in ('bearer', 'token'):
            return None

        access_token = parts[1]
        try:
            token = OidcToken.objects.select_related('user').filter(access_token=access_token).first()
            if not token:
                return None

            if token.has_expired():
                raise AuthenticationFailed('OIDC Access Token has expired.')

            return (token.user, token)
        except AuthenticationFailed:
            raise
        except Exception:
            return None

    def authenticate_header(self, request):
        return 'Bearer'
