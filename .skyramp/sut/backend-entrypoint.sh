#!/bin/sh
# Bootstraps a fresh wger backend for Testbot: migrate, seed fixtures/admin,
# then serve. The sqlite DB lives only inside this container, so every
# `docker compose up --build` starts from a clean slate.
set -eu

python manage.py migrate --noinput

# Official wger bootstrap fixtures (languages, exercises, gyms, ...) and the
# default admin user (username "admin", password "adminadmin").
wger load-fixtures
wger create-or-reset-admin

# Stable DRF token for the seeded admin user, consumed by the wger-react
# frontend via VITE_API_KEY (must match the compose environment value).
python manage.py shell -c "
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token
user = User.objects.get(username='admin')
Token.objects.update_or_create(user=user, defaults={'key': 'apikey-admin'})
"

exec python manage.py runserver 0.0.0.0:8000 --insecure
