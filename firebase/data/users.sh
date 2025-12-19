#!/usr/bin/env bash
# Define usuarios de ejemplo para sembrar en el emulador

declare -a USERS=(
  "usuario.demo1@test.com|123456|Juan Perez"
  "usuario.demo2@test.com|123456|Maria Garcia"
  "carlos.rodriguez@test.com|123456|Carlos Rodriguez"
  "ana.martinez@test.com|123456|Ana Martinez"
  "luis.gonzalez@test.com|123456|Luis Gonzalez"
)

# Función para crear usuarios en Auth Emulator
create_users() {
  local auth_host=$1
  local api_key=$2
  
  echo "👤 Creando usuarios en Auth Emulator..."
  for u in "${USERS[@]}"; do
    IFS='|' read -r EMAIL PASSWORD NAME <<<"$u"
    RESP=$(curl -s -X POST "${auth_host}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=${api_key}" \
      -H 'Content-Type: application/json' \
      -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\",\"returnSecureToken\":true}") || true
    if echo "$RESP" | grep -q 'localId'; then
      echo "✅ Usuario creado: ${EMAIL}"
    elif echo "$RESP" | grep -q 'EMAIL_EXISTS'; then
      echo "⚠️  Usuario ya existe: ${EMAIL}"
    else
      echo "⚠️  No se pudo crear ${EMAIL}: $RESP"
    fi
    # Crear doc de usuario en Firestore
    curl -s -X POST "${FIRESTORE_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/users" \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer owner' \
      -d "{\"fields\":{\"email\":{\"stringValue\":\"${EMAIL}\"},\"fullName\":{\"stringValue\":\"${NAME}\"}}}" > /dev/null || true
  done
}

# Función para contar usuarios en el emulador
count_users() {
  local auth_host=$1
  local project_id=$2
  curl -s "${auth_host}/emulator/v1/projects/${project_id}/accounts" | grep -o '"localId"' | wc -l || echo 0
}
