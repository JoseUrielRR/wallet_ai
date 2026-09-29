import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_ai/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('WalletAiApp smoke test - renders app shell and navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WalletAiApp(),
      ),
    );

    // Permitir inicialización de microtareas
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

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
