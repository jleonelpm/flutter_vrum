## Titulo
Modulo para subir imagenes en las publicaciones de vehiculos

## Pasos
1. Modificar la estructura de Firestore para incluir un campo `images[]` en la colección `vehicles` que almacene las URLs de las imágenes subidas.
2. Configurar Firebase Storage para almacenar las imágenes subidas por los usuarios.
3. Crear un formulario en la interfaz de usuario que permita a los usuarios seleccionar y subir múltiples imágenes al crear o editar una publicación de vehículo.
4. Implementar la lógica en el backend para manejar la subida de imágenes a Firebase Storage y guardar las URLs en el campo `images[]` del documento correspondiente en Firestore.
5. Actualizar la vista de detalles del vehículo para mostrar las imágenes subidas en un carrusel o galería.
6. Actualizar la pagina home para mostrar una miniatura de la primera imagen de cada vehiculo en la lista de publicaciones.
7. Asegurarse de que las imágenes se carguen de manera eficiente y que se manejen los errores de subida adecuadamente.


## Requisitos Tecnicos
- Respetar la arquitectura de carpetas
- Se está usando Firestore Local como base de datos

## Detalles
- Validar los formularios para la subida de imagenes
- Manejar errores en la subida de imagenes
- Optimizar las imagenes para web antes de subirlas a Firebase Storage
- Asegurarse de que las imagenes sean accesibles solo para usuarios autenticados

