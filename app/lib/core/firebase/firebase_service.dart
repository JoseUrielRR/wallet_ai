import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  /// Inicializa Firebase de forma segura con soporte Offline-First.
  /// Si no hay configuración nativa o falla la conexión, la app no crashea
  /// y permite continuar en modo local/resiliente.
  static Future<bool> initialize({FirebaseOptions? options}) async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
      } else {
        await Firebase.initializeApp(options: options);
        _isInitialized = true;
      }

      // Habilitar persistencia offline nativa en Firestore si es compatible
      if (_isInitialized && !kIsWeb) {
        try {
          FirebaseFirestore.instance.settings = const Settings(
            persistenceEnabled: true,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          );
        } catch (settingsError) {
          debugPrint('[FirebaseService] Firestore settings aviso: $settingsError');
        }
      }

      return _isInitialized;
    } catch (e, st) {
      debugPrint('[FirebaseService] Advertencia de inicialización: $e\n$st');
      _isInitialized = false;
      return false;
    }
  }
}
