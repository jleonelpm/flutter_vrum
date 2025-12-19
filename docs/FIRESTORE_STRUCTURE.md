# Firestore Structure (Local Emulator)

Este documento describe las colecciones y campos usados por la app en entorno local. Para producción se pueden ampliar índices y validaciones.

## Colecciones

- `users`
  - `email`: string (único)
  - `fullName`: string
  - Futuro: `photoUrl`, `createdAt`

- `vehicles`
  - `ownerEmail`: string (referencia por email)
  - `ownerName`: string
  - `name`: string
  - `description`: string
  - `emoji`: string
  - `price`: number (entero)
  - `lugar`: string (ubicación física del vehículo)
  - `createdAt`: timestamp (fecha de publicación)
  - Futuro: `images[]`

- `comments` (futuro)
  - `vehicleId`: string (document id de `vehicles`)
  - `authorEmail`: string
  - `text`: string
  - `createdAt`: timestamp

- `favorites` (futuro)
  - `userEmail`: string
  - `vehicleId`: string
  - `createdAt`: timestamp

- `ratings` (futuro)
  - `vehicleId`: string
  - `userEmail`: string
  - `score`: number (1-5)
  - `createdAt`: timestamp

- `messages` (futuro)
  - `threadId`: string
  - `fromEmail`: string
  - `toEmail`: string
  - `text`: string
  - `createdAt`: timestamp

## Emulators

- Authentication: `127.0.0.1:9099` → UI: `http://127.0.0.1:4000/auth`
- Firestore: `127.0.0.1:8084` → UI: `http://127.0.0.1:4000/firestore`
- RTDB: `127.0.0.1:9004` → UI: `http://127.0.0.1:4000/database`
- Storage: `127.0.0.1:9199` → UI: `http://127.0.0.1:4000/storage`

## Reglas (sugerencia para local)

Durante desarrollo se puede permitir escritura desde el emulador con el header `Authorization: Bearer owner`. En producción usar reglas estrictas con autenticación.

## Semillas (seed)

El script `firebase/start-local.sh` crea:
- 5 usuarios (`usuario.demo1@test.com`, `usuario.demo2@test.com`, `carlos.rodriguez@test.com`, `ana.martinez@test.com`, `luis.gonzalez@test.com`).
- 15 vehículos distribuidos entre esos usuarios.

Datos persisten en `.firebase-data` por `--export-on-exit`.
