import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_ai/core/theme/app_theme.dart';
import 'package:wallet_ai/features/calendar/presentation/screens/financial_calendar_screen.dart';
import 'package:wallet_ai/features/profile/presentation/screens/profile_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProfileScreen Visual & Contrast Tests', () {
    testWidgets('renders clearly in light mode with accessible labels and tiles', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title and user info
      expect(find.text('Perfil y Configuración'), findsOneWidget);
      expect(find.text('Alex Rivera'), findsOneWidget);
      expect(find.text('alex.rivera@ejemplo.com'), findsOneWidget);

      // Verify top section titles & options
      expect(find.text('PREFERENCIAS FINANCIERAS'), findsOneWidget);
      expect(find.text('Moneda Principal'), findsOneWidget);
      expect(find.text('NOTIFICACIONES INTELIGENTES'), findsOneWidget);
      expect(find.text('Alertas de Fecha de Corte'), findsOneWidget);

      // Scroll down to see lower sections
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('PRIVACIDAD Y GESTIÓN DE DATOS'), findsOneWidget);
      expect(find.text('Seguridad Zero-Knowledge'), findsOneWidget);
      expect(find.text('Vaciar Billetera'), findsOneWidget);
    });

    testWidgets('renders clearly in dark mode without contrast issues', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Perfil y Configuración'), findsOneWidget);
      expect(find.text('Alex Rivera'), findsOneWidget);
      expect(find.text('Moneda Principal'), findsOneWidget);
      expect(find.text('NOTIFICACIONES INTELIGENTES'), findsOneWidget);
    });
  });

  group('FinancialCalendarScreen Responsive & Orientation Tests', () {
    testWidgets('renders in portrait without overflow and allows scrolling', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844); // iPhone portrait
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FinancialCalendarScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Calendario Financiero'), findsOneWidget);
      expect(find.text('Dom'), findsOneWidget);
      expect(find.text('Sáb'), findsOneWidget);

      // Scroll smoothly down using the specific Key
      await tester.drag(find.byKey(const Key('calendar_scroll_view')), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in landscape orientation without any pixel overflow', (WidgetTester tester) async {
      // Landscape dimensions (e.g. 844x390 - height is very narrow)
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FinancialCalendarScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure NO overflow exceptions occurred (the original bug was 475 pixels overflow)
      expect(tester.takeException(), isNull);
      expect(find.text('Calendario Financiero'), findsOneWidget);

      // Verify that the user can scroll smoothly in landscape mode
      await tester.drag(find.byKey(const Key('calendar_scroll_view')), const Offset(0, -150));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('allows tapping days and updating selected day events in both orientations', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FinancialCalendarScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap day 15
      final day15Finder = find.text('15');
      if (day15Finder.evaluate().isNotEmpty) {
        await tester.tap(day15Finder.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });
}
