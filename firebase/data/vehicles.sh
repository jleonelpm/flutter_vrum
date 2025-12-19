#!/usr/bin/env bash
# Define vehículos de ejemplo para sembrar en el emulador

# Función para publicar un vehículo
post_vehicle() {
  local firestore_host=$1
  local project_id=$2
  local owner_email=$3
  local owner_name=$4
  local name=$5
  local desc=$6
  local emoji=$7
  local price=$8
  local lugar=$9
  
  local now
  now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  curl -s -X POST "${firestore_host}/v1/projects/${project_id}/databases/(default)/documents/vehicles" \
    -H 'Content-Type: application/json' \
    -H 'Authorization: Bearer owner' \
    -d "{\"fields\":{\"ownerEmail\":{\"stringValue\":\"${owner_email}\"},\"ownerName\":{\"stringValue\":\"${owner_name}\"},\"name\":{\"stringValue\":\"${name}\"},\"description\":{\"stringValue\":\"${desc}\"},\"emoji\":{\"stringValue\":\"${emoji}\"},\"price\":{\"integerValue\":\"${price}\"},\"lugar\":{\"stringValue\":\"${lugar}\"},\"createdAt\":{\"timestampValue\":\"${now}\"}}}" > /dev/null || true
}

# Función para crear todos los vehículos
create_vehicles() {
  local firestore_host=$1
  local project_id=$2
  
  echo "🚗 Creando vehículos en Firestore Emulator..."
  
  # Juan Perez - 3 vehículos
  post_vehicle "$firestore_host" "$project_id" "usuario.demo1@test.com" "Juan Perez" "Toyota Corolla 2022" "Sedán compacto" "🚗" 18500 "Ciudad de México"
  post_vehicle "$firestore_host" "$project_id" "usuario.demo1@test.com" "Juan Perez" "Mazda CX-5 2021" "SUV versátil" "🚙" 28500 "Guadalajara, Jalisco"
  post_vehicle "$firestore_host" "$project_id" "usuario.demo1@test.com" "Juan Perez" "Nissan Sentra 2020" "Económico" "🚗" 16500 "Monterrey, Nuevo León"

  # Maria Garcia - 3 vehículos
  post_vehicle "$firestore_host" "$project_id" "usuario.demo2@test.com" "Maria Garcia" "Honda Civic 2020" "Sedán deportivo" "🏎️" 16800 "Puebla, Puebla"
  post_vehicle "$firestore_host" "$project_id" "usuario.demo2@test.com" "Maria Garcia" "Ford Escape 2021" "SUV moderna" "🚙" 10500 "Querétaro, Querétaro"
  post_vehicle "$firestore_host" "$project_id" "usuario.demo2@test.com" "Maria Garcia" "Hyundai Elantra 2022" "Eficiente" "🚗" 18000 "León, Guanajuato"

  # Carlos Rodriguez - 3 vehículos
  post_vehicle "$firestore_host" "$project_id" "carlos.rodriguez@test.com" "Carlos Rodriguez" "BMW X5 2023" "SUV de lujo" "👑" 45000 "Ciudad de México"
  post_vehicle "$firestore_host" "$project_id" "carlos.rodriguez@test.com" "Carlos Rodriguez" "Audi A4 2022" "Sedán ejecutivo" "🏎️" 39000 "San Pedro Garza García, NL"
  post_vehicle "$firestore_host" "$project_id" "carlos.rodriguez@test.com" "Carlos Rodriguez" "Mercedes-Benz C-Class 2021" "Lujo compacto" "💎" 42000 "Polanco, CDMX"

  # Ana Martinez - 3 vehículos
  post_vehicle "$firestore_host" "$project_id" "ana.martinez@test.com" "Ana Martinez" "Volkswagen Jetta 2021" "Sedán confiable" "🚗" 14500 "Toluca, Estado de México"
  post_vehicle "$firestore_host" "$project_id" "ana.martinez@test.com" "Ana Martinez" "Kia Sportage 2022" "SUV familiar" "🚙" 28500 "Aguascalientes, Ags"
  post_vehicle "$firestore_host" "$project_id" "ana.martinez@test.com" "Ana Martinez" "Chevrolet Malibu 2020" "Sedán cómodo" "🚗" 19200 "Mérida, Yucatán"

  # Luis Gonzalez - 3 vehículos
  post_vehicle "$firestore_host" "$project_id" "luis.gonzalez@test.com" "Luis Gonzalez" "Tesla Model 3 2023" "Eléctrico" "⚡" 45000 "Santa Fe, CDMX"
  post_vehicle "$firestore_host" "$project_id" "luis.gonzalez@test.com" "Luis Gonzalez" "Chevrolet Bolt EV 2022" "Compacto eléctrico" "🔋" 30000 "Zapopan, Jalisco"
  post_vehicle "$firestore_host" "$project_id" "luis.gonzalez@test.com" "Luis Gonzalez" "Nissan Leaf 2021" "EV accesible" "🍃" 25000 "Tijuana, Baja California"
}
