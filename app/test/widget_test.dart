import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_ai/app.dart';
import 'package:wallet_ai/features/auth/domain/models/app_user.dart';
import 'package:wallet_ai/features/auth/presentation/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('WalletAiApp renders AuthScreen when user is unauthenticated', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WalletAiApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Debe mostrar la pantalla de autenticación con sus opciones
    expect(find.text('Iniciar Sesión'), findsNWidgets(2));
    expect(find.text('Crear Cuenta'), findsOneWidget);
    expect(find.text('Continuar como Invitado'), findsOneWidget);
  });

  testWidgets('WalletAiApp renders app shell and navigation when user is authenticated', (WidgetTester tester) async {
    final testUser = AppUser(
      id: 'usr_test_auth',
      email: 'alex@walletai.app',
      displayName: 'Alex Rivera',
      isAnonymous: false,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith((ref) => Stream.value(testUser)),
          currentUserProvider.overrideWithValue(testUser),
          currentUserIdProvider.overrideWithValue(testUser.id),
        ],
        child: const WalletAiApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verificar que los tabs de navegación están presentes
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Billetera'), findsOneWidget);
    expect(find.text('Calendario'), findsOneWidget);
    expect(find.text('Actividad'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    // Verificar que el título de la app o dashboard se muestra
    expect(find.text('Wallet AI'), findsOneWidget);
  });
}
