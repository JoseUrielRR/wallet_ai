import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'core/firebase/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización no bloqueante y resiliente de Firebase
  try {
    await FirebaseService.initialize(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Modo local / offline fallback
  }

  runApp(
    const ProviderScope(
      child: WalletAiApp(),
    ),
  );
}
