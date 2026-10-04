#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys


def main():
    """Run administrative tasks."""
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'unimarket.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc


    if sys.platform == 'win32':
        try:
            sys.stdout.reconfigure(encoding='utf-8')
            sys.stderr.reconfigure(encoding='utf-8')
        except Exception:
            pass

    if len(sys.argv) > 1 and sys.argv[1] == 'runserver' and os.environ.get('RUN_MAIN') != 'true':
        print("\n" + "=" * 62)
        print("  [UniMarket] UNIMARKET MOBILE BACKEND API & OIDC SERVER (WEEK 16)")
        print("  Course: Mobile Application Development | Branch: project")
        print("  Client Target: Flutter Mobile & Web App (Port 50000)")
        print("  OIDC Issuer:   http://127.0.0.1:8000/openid/")
        print("  Mobile API:    http://127.0.0.1:8000/api/mobile/config/")
        print("=" * 62 + "\n")
    execute_from_command_line(sys.argv)



if __name__ == '__main__':
    main()
