import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ai/features/auth/domain/models/app_user.dart';
import 'package:wallet_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:wallet_ai/features/auth/presentation/screens/auth_screen.dart';
import 'package:wallet_ai/features/profile/presentation/screens/profile_screen.dart';

void main() {
  group('AuthScreen & Onboarding Tests', () {
    testWidgets('Toggles between Login and Register tabs smoothly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Inicia por defecto en "Iniciar Sesión"
      expect(find.text('Nombre completo'), findsNothing);
      expect(find.text('Confirmar contraseña'), findsNothing);

      // Cambiar a "Crear Cuenta"
      await tester.tap(find.text('Crear Cuenta'));
      await tester.pumpAndSettle();

      expect(find.text('Nombre completo'), findsOneWidget);
      expect(find.text('Confirmar contraseña'), findsOneWidget);

      // Regresar a "Iniciar Sesión"
      await tester.tap(find.text('Iniciar Sesión').first);
      await tester.pumpAndSettle();

      expect(find.text('Nombre completo'), findsNothing);
      expect(find.text('Confirmar contraseña'), findsNothing);
    });

    testWidgets('Validates email and password fields on submit', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Presionar botón Iniciar Sesión con campos vacíos
      await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar Sesión'));
      await tester.pumpAndSettle();

      expect(find.text('Ingresa tu correo'), findsOneWidget);
      expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    });

    testWidgets('Validates short passwords', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'usuario@test.com');
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar Sesión'));
      await tester.pumpAndSettle();

      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });
  });

  group('ProfileScreen Auth Integration Tests', () {
    testWidgets('Displays authenticated user name, email and logout action', (tester) async {
      final testUser = AppUser(
        id: 'usr_auth_999',
        email: 'jose.uriel@test.com',
        displayName: 'Jose Uriel',
        isAnonymous: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(testUser),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Debe mostrar el nombre y correo del usuario autenticado
      expect(find.text('Jose Uriel'), findsOneWidget);
      expect(find.text('jose.uriel@test.com'), findsOneWidget);
      expect(find.text('JU'), findsOneWidget); // Iniciales

      // Desplazarse en el ListView hasta encontrar la opción de Cerrar Sesión
      await tester.scrollUntilVisible(find.text('Cerrar Sesión'), 400);
      expect(find.text('Cerrar Sesión'), findsOneWidget);
    });
  });
}
