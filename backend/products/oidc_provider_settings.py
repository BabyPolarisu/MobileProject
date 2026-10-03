from oidc_provider.lib.claims import ScopeClaims

def userinfo(claims, user):
    """
    Provide userinfo claims for OpenID Connect client
    """
    claims['sub'] = str(user.id)
    claims['preferred_username'] = user.username
    claims['name'] = user.get_full_name() or user.username
    claims['email'] = user.email
    claims['is_staff'] = user.is_staff
    claims['is_admin'] = user.is_staff or user.is_superuser

    profile = getattr(user, 'profile', None)
    if profile:
        if profile.display_name:
            claims['name'] = profile.display_name
        claims['phone_number'] = profile.phone_number
        claims['address'] = profile.address
        claims['bio'] = profile.bio
        if profile.avatar:
            try:
                claims['picture'] = profile.avatar.url
            except Exception:
                claims['picture'] = ''

    return claims


class CustomScopeClaims(ScopeClaims):
    info_profile = (
        'Profile',
        'Access to basic profile information (name, avatar, username)',
    )

    def scope_profile(self):
        dic = {
            'name': self.userinfo.get('name'),
            'preferred_username': self.user.username,
            'is_staff': self.user.is_staff,
            'is_admin': self.user.is_staff or self.user.is_superuser,
        }
        return dic
