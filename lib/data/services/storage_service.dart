import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Subir una imagen a Firebase Storage con optimización.
  /// [filePath]: ruta local del archivo de imagen
  /// [storagePath]: ruta en Storage donde guardar (ej: 'vehicles/vehicleId/image.jpg')
  /// Retorna: URL descargable de la imagen
  Future<String> uploadImage(String filePath, String storagePath) async {
    try {
      final File file = File(filePath);

      // Validar que el archivo existe
      if (!await file.exists()) {
        throw Exception('El archivo no existe: $filePath');
      }

      // Validar tipo de archivo
      if (!_isValidImageType(filePath)) {
        throw Exception('Formato de imagen no válido. Use JPG, PNG o WebP');
      }

      // Optimizar imagen
      final optimizedFile = await _optimizeImage(file);

      // Subir a Storage
      final ref = _storage.ref(storagePath);
      final uploadTask = ref.putFile(optimizedFile);

      await uploadTask;

      // Obtener URL descargable
      final downloadUrl = await ref.getDownloadURL();

      // Limpiar archivo temporal si es diferente al original
      if (optimizedFile.path != file.path) {
        await optimizedFile.delete();
      }

      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  /// Subir múltiples imágenes.
  /// [filePaths]: lista de rutas locales
  /// [vehicleId]: ID del vehículo para organizar en Storage
  /// Retorna: lista de URLs descargables
  Future<List<String>> uploadMultipleImages(
    List<String> filePaths,
    String vehicleId,
  ) async {
    final uploadedUrls = <String>[];

    for (int i = 0; i < filePaths.length; i++) {
      final filePath = filePaths[i];
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'vehicles/$vehicleId/image_${timestamp}_$i.jpg';

      try {
        final url = await uploadImage(filePath, storagePath);
        uploadedUrls.add(url);
      } catch (e) {
        // Registrar error pero continuar con siguientes imágenes
        print('Error subiendo imagen $i: $e');
      }
    }

    if (uploadedUrls.isEmpty) {
      throw Exception('No se pudieron subir las imágenes');
    }

    return uploadedUrls;
  }

  /// Eliminar imagen de Storage por URL.
  Future<void> deleteImage(String downloadUrl) async {
    try {
      // Extraer ruta de Storage de la URL descargable
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Error al eliminar imagen: $e');
    }
  }

  /// Eliminar múltiples imágenes.
  Future<void> deleteMultipleImages(List<String> downloadUrls) async {
    for (final url in downloadUrls) {
      try {
        await deleteImage(url);
      } catch (e) {
        print('Error eliminando imagen $url: $e');
      }
    }
  }

  /// Optimizar imagen: reducir tamaño y compresión.
  Future<File> _optimizeImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return imageFile;
      }

      // Redimensionar si es muy grande (máximo 1200px de ancho)
      img.Image optimized = image;
      if (image.width > 1200) {
        optimized = img.copyResize(
          image,
          width: 1200,
          interpolation: img.Interpolation.linear,
        );
      }

      // Convertir a JPG con calidad 85
      final optimizedBytes = img.encodeJpg(optimized, quality: 85);

      // Guardar en archivo temporal
      final tempFile = File(
        imageFile.path.replaceAll(
          imageFile.path.split('/').last,
          'optimized_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      await tempFile.writeAsBytes(optimizedBytes);
      return tempFile;
    } catch (e) {
      print('Error optimizando imagen: $e');
      return imageFile;
    }
  }

  /// Validar que el archivo sea una imagen válida.
  bool _isValidImageType(String filePath) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
    final extension = filePath.split('.').last.toLowerCase();
    return validExtensions.contains(extension);
  }
}
