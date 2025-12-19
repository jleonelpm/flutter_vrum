#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")"/.. && pwd)"
DATA_SCRIPTS_DIR="${ROOT_DIR}/firebase/data"
DATA_DIR="${ROOT_DIR}/.firebase-data"
PROJECT_ID=${PROJECT_ID:-demo-vrum}
AUTH_HOST=${AUTH_HOST:-http://127.0.0.1:9099}
FIRESTORE_HOST=${FIRESTORE_HOST:-http://127.0.0.1:8084}
API_KEY=${API_KEY:-fake-api-key}

mkdir -p "${DATA_DIR}"

echo "🚀 Iniciando Firebase Emulators con persistencia en ${DATA_DIR}..."
firebase emulators:start --project "${PROJECT_ID}" \
  --import "${DATA_DIR}" \
  --export-on-exit \
  --only auth,firestore,database,storage &
EMULATOR_PID=$!

cleanup() {
  echo "\n🧹 Deteniendo emuladores (PID ${EMULATOR_PID})..."
  kill ${EMULATOR_PID} >/dev/null 2>&1 || true
}
trap cleanup EXIT

# Esperar a que Firestore esté listo
echo "⏳ Esperando a que Firestore responda..."
for i in {1..60}; do
  if curl -s "${FIRESTORE_HOST}/" >/dev/null; then
    break
  fi
  sleep 1
done

# Esperar a que Auth esté listo (usa Admin API del emulador)
echo "⏳ Esperando a que Auth responda..."
for i in {1..60}; do
  if curl -s "${AUTH_HOST}/emulator/v1/projects/${PROJECT_ID}/config" >/dev/null; then
    break
  fi
  sleep 1
done

bold() { echo -e "\033[1m$*\033[0m"; }
section() { echo; bold "$1"; }

section "🌐 Sembrando datos LOCALES en Firebase Emulator (${PROJECT_ID})"

# Cargar definiciones de usuarios y vehículos desde archivos separados
source "${DATA_SCRIPTS_DIR}/users.sh"
source "${DATA_SCRIPTS_DIR}/vehicles.sh"

# Crear usuarios
create_users "${AUTH_HOST}" "${API_KEY}"

# Crear vehículos
create_vehicles "${FIRESTORE_HOST}" "${PROJECT_ID}"

# Confirmar que los usuarios existen en el emulador
COUNT=$(count_users "${AUTH_HOST}" "${PROJECT_ID}")
echo "👀 Usuarios en Auth Emulator: ${COUNT}"
if [ "${COUNT}" -eq 0 ]; then
  echo "❗ No se encuentran usuarios en el emulador de Auth."
  echo "   Verifica que el servicio esté arriba (UI: http://localhost:4000/auth)"
  echo "   y vuelve a ejecutar este script sin interrumpirlo (no presiones Ctrl+C durante el seed)."
fi

section "🚗 Creando vehículos en Firestore Emulator..."
echo "\n✅ Seed local terminado. Verifica en Emulator UI: http://localhost:4000"

echo "✅ Emuladores corriendo. Presiona Ctrl+C para detener y exportar datos a ${DATA_DIR}"
wait ${EMULATOR_PID}

