## Titulo
Busqueda de vehiculos con filtros

## Pasos
1. Busqueda basica por nombre o descripcion del vehiculo directamente desde la barra de busqueda en home_screen.dart
2. Busqueda avanzada con filtros, se puede agregar un boton en home_screen.dart que abra un modal con los siguientes filtros:
   - Rango de precio (minimo y maximo)
   - Ubicacion (ciudad o region)
   
## Requisitos Tecnicos
- Respetar la arquitectura de carpetas
- Emplear riverpod para el manejo de estado. En caso de necesitar un nuevo provider, crear uno nuevo en la carpeta providers.
- Usar Firestore para las consultas
- Implementar paginacion para resultados largos

## Detalles
- Validar entradas del usuario para evitar inyeccion de codigo
- Mostrar mensajes de error claros en caso de que la busqueda falle
- Realizar pruebas unitarias para la logica de busqueda y filtros


