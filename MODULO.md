## Titulo
Integracion Firebase Local con Flutter

## Pasos
- Realiza las configuraciones para trabajar con Firebase Local en el proyecto de Flutter
- Asegurate de tener las dependencias necesarias en el archivo pubspec.yaml
- Configura el emulador de Firebase para Firestore, Authentication, etc.
- Crea la base de datos local en Firestore 
- Popula la base de datos con algunos usuarios y datos de ejemplo
- Modifica la pantalla de inicio (initial_screen) para que el usuario pueda iniciar sesión utilizando Firebase Authentication
- Popula la base de datos vehiculos para mostrar en la pantalla principal
- Modifica la pantalla principal (home_screen) para que muestre datos obtenidos de Firestore

## Requisitos Tecnicos
- Firebase Local Emulator Suite esta configurado y funcionando correctamente
- Flutter SDK instalado y configurado
- Crea un script para iniciar el emulador de Firebase Local y cargar los datos de ejemplo en Firestore

## Estructura de la Base de Datos
- Usuarios 
- Vehiculos
- Los usuarios pueden publicar uno o mas vehiculos
- Comentarios
- Los usuarios pueden comentar en los vehiculos publicados
- Favoritos
- Los usuarios pueden marcar vehiculos como favoritos
- Calificaciones
- Los usuarios pueden calificar los vehiculos publicados
- Mensajes
- Los usuarios pueden enviar mensajes entre ellos

## Consideraciones Adicionales
- Por ahora solo se requiere la integracion con Firestore y Authentication
- Por ahora solo se requiere la funcionalidad basica de inicio de sesion y mostrar datos en la pantalla principal
- Genera un documento de la estructura de la base de datos y las colecciones utilizadas, para que se pueda replicar en un entorno de produccion posteriormente
- Asegurate de manejar los errores y casos de uso comunes, como usuario no encontrado
- Los datos deben ser persistentes en el emulador de Firebase Local
- iniciar los servicios con importacion de datos

## Servicios de Firebase a Utilizar

Authentication │ 127.0.0.1:9099 │ http://127.0.0.1:4000/auth
Firestore      │ 127.0.0.1:8084 │ http://127.0.0.1:4000/firestore 
Database       │ 127.0.0.1:9004 │ http://127.0.0.1:4000/database
Storage        │ 127.0.0.1:9199 │ http://127.0.0.1:4000/storage 


## Comandos

Para levantar emuladores y poblar datos locales:

```bash
cd /home/personal/Documents/DeveloperProjects/apps/flutter_vrum
chmod +x firebase/start-local.sh
./firebase/start-local.sh
```

Luego abre `http://localhost:4000` para inspeccionar Authentication y Firestore.

### Usuarios de ejemplo (para login)

- `usuario.demo1@test.com` / `123456`
- `usuario.demo2@test.com` / `123456`
- `carlos.rodriguez@test.com` / `123456`
- `ana.martinez@test.com` / `123456`
- `luis.gonzalez@test.com` / `123456`

