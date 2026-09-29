import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_ai/features/cards/presentation/providers/cards_provider.dart';
import 'package:wallet_ai/features/loans/presentation/providers/loans_provider.dart';
import 'package:wallet_ai/features/purchases/presentation/providers/purchases_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Providers Invalidation & Initialization Tests', () {
    test('CardsNotifier can be invalidated repeatedly without LateInitializationError', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Primera lectura / inicialización
      var state = container.read(cardsProvider);
      expect(state, isA<AsyncValue>());

      // Esperar a que cargue
      await container.read(cardsProvider.notifier).resetToDemo();
      state = container.read(cardsProvider);
      expect(state.hasValue, isTrue);
      expect(state.value?.isNotEmpty, isTrue);

      // Invalidación 1 (ej. pull-to-refresh en Dashboard)
      container.invalidate(cardsProvider);
      state = container.read(cardsProvider);
      expect(state, isA<AsyncValue>());

      // Invalidación 2
      container.invalidate(cardsProvider);
      state = container.read(cardsProvider);
      expect(state, isA<AsyncValue>());

      // Invalidación 3
      container.invalidate(cardsProvider);
      state = container.read(cardsProvider);
      expect(state, isA<AsyncValue>());
    });

    test('LoansNotifier and PurchasesNotifier can be invalidated without LateInitializationError', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Invalidation en préstamos
      container.read(loansProvider);
      container.invalidate(loansProvider);
      container.invalidate(loansProvider);
      expect(container.read(loansProvider), isA<AsyncValue>());

      // Invalidation en compras
      container.read(purchasesProvider);
      container.invalidate(purchasesProvider);
      container.invalidate(purchasesProvider);
      expect(container.read(purchasesProvider), isA<AsyncValue>());
    });
  });
}
