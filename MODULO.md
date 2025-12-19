## Titulo
Detalle Vehiculo Publicado

## Pasos
- Intenta modificar la estructura de vehiculos que se  encuentra en firebase->data->vehicles, para que tenga  titulo, descripcion del vehiculo y lugar donde se encuentra el vehiculo.
- En home_screen.dart, se muestran los vehiculos publicados por los usuarios. 
- Al seleccionar un vehiculo, se navega a vehicle_detail.dart, donde se muestran los detalles del vehiculo seleccionado.
- Diseña adecuadamente la interfaz para mostrar la infomracion del vehiculo publicado, incluyendo la nueva informacion de titulo, descripcion y lugar.

## Requisitos Tecnicos
- Firebase Firestore ya esta instalado y configurado en el proyecto.

- La coleccion 'vehicles' en Firestore contiene los documentos de los vehiculos publicados, con la siguiente estructura:
  - `ownerEmail`: string (referencia por email)
  - `ownerName`: string
  - `name`: string
  - `description`: string
  - `emoji`: string
  - `price`: number (entero)
  - `lugar`: string 
  - `createdAt`: timestamp (fecha de publicación)