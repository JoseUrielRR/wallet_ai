import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ai/core/widgets/async_value_widget.dart';
import 'package:wallet_ai/core/widgets/empty_state_view.dart';
import 'package:wallet_ai/core/widgets/error_state_view.dart';
import 'package:wallet_ai/core/widgets/shimmer_loading.dart';
import 'package:wallet_ai/features/auth/domain/models/app_user.dart';
import 'package:wallet_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:wallet_ai/features/cards/data/dtos/user_card_dto.dart';
import 'package:wallet_ai/features/cards/domain/models/benefit.dart';
import 'package:wallet_ai/features/cards/domain/models/user_card.dart';
import 'package:wallet_ai/features/loans/data/dtos/loan_dto.dart';
import 'package:wallet_ai/features/loans/domain/models/loan.dart';
import 'package:wallet_ai/features/purchases/data/dtos/purchase_dto.dart';

void main() {
  group('Backend Architecture & DTO Serialization Tests', () {
    test('UserCardDto correctly serializes and deserializes from/to Firestore map', () {
      final now = DateTime(2026, 10, 4, 12, 0, 0);
      final domainCard = UserCard(
        id: 'card_unit_test',
        userId: 'usr_test_123',
        issuerId: 'bank_aurora',
        issuerName: 'Banco Aurora',
        productName: 'Aurora Infinite',
        alias: 'Mi Tarjeta Principal',
        type: 'credit',
        last4: '4589',
        currency: 'MXN',
        creditLimitCents: 5000000,
        currentBalanceCents: 1200000,
        availableCreditCents: 3800000,
        statementClosingDay: 15,
        paymentDueDay: 5,
        daysBetweenCutoffAndDue: 20,
        adjustForHolidays: true,
        colorHex: '#388BFD',
        status: 'active',
        benefits: [
          Benefit(
            id: 'ben_super_3',
            category: 'supermarket',
            rewardType: 'cashback',
            rewardRate: 3.0,
            rewardCapCents: 150000,
            minimumSpendCents: 50000,
            terms: 'Aplica en tiendas de autoservicio',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );

      // Domain to DTO
      final dto = UserCardDto.fromDomain(domainCard);
      expect(dto.id, equals('card_unit_test'));
      expect(dto.benefits.length, equals(1));

      // DTO to Firestore map
      final firestoreMap = dto.toFirestore();
      expect(firestoreMap['id'], equals('card_unit_test'));
      expect(firestoreMap['userId'], equals('usr_test_123'));
      expect(firestoreMap['creditLimitCents'], equals(5000000));
      expect(firestoreMap['benefits'], isA<List>());

      // Firestore map to DTO
      final fromMapDto = UserCardDto.fromFirestore(firestoreMap, 'card_unit_test');
      expect(fromMapDto.alias, equals('Mi Tarjeta Principal'));
      expect(fromMapDto.benefits.first.rewardRate, equals(3.0));

      // DTO back to Domain
      final restoredDomain = fromMapDto.toDomain();
      expect(restoredDomain.id, equals(domainCard.id));
      expect(restoredDomain.alias, equals(domainCard.alias));
      expect(restoredDomain.calculatedAvailableCreditCents, equals(3800000));
      expect(restoredDomain.creditUtilizationRatio, closeTo(0.24, 0.001));
    });

    test('PurchaseDto handles resilient date parsing and numeric casting', () {
      final rawFirestoreDoc = {
        'userId': 'usr_test_456',
        'cardId': 'card_test',
        'cardAlias': 'Aurora Black',
        'amountCents': 249900,
        'currency': 'MXN',
        'category': 'dining',
        'description': 'Cena restaurante',
        'merchant': 'Bistro Central',
        'purchaseDate': '2026-10-04T20:30:00.000Z',
        'billingCycleId': 'cycle_2026_10',
        'estimatedRewardCents': 7497,
        'status': 'recorded',
        'createdAt': '2026-10-04T20:35:00.000Z',
      };

      final dto = PurchaseDto.fromFirestore(rawFirestoreDoc, 'pur_doc_999');
      final purchase = dto.toDomain();

      expect(purchase.id, equals('pur_doc_999'));
      expect(purchase.amountCents, equals(249900));
      expect(purchase.category, equals('dining'));
      expect(purchase.purchaseDate.year, equals(2026));
      expect(purchase.estimatedRewardCents, equals(7497));
    });

    test('LoanDto computes progress percentage and serializes correctly', () {
      final now = DateTime(2026, 10, 4);
      final loan = Loan(
        id: 'loan_auto_1',
        userId: 'usr_test',
        name: 'Crédito Automotriz',
        lender: 'Banco Horizonte',
        originalAmountCents: 20000000, // $200,000.00
        outstandingBalanceCents: 10000000, // $100,000.00 (50% pagado)
        paymentAmountCents: 650000,
        nextPaymentDate: now.add(const Duration(days: 15)),
        createdAt: now,
        updatedAt: now,
      );

      final dto = LoanDto.fromDomain(loan);
      final map = dto.toFirestore();
      final restored = LoanDto.fromFirestore(map, 'loan_auto_1').toDomain();

      expect(restored.progressPercentage, equals(0.5));
      expect(restored.outstandingBalanceCents, equals(10000000));
      expect(restored.isActive, isTrue);
    });

    test('AppUser model encapsulates anonymous onboarding and profile identity', () {
      final anonymousUser = AppUser(
        id: 'anon_123',
        isAnonymous: true,
        createdAt: DateTime.now(),
      );

      expect(anonymousUser.isAuthenticated, isTrue);
      expect(anonymousUser.isAnonymous, isTrue);
      expect(anonymousUser.email, isNull);

      final linkedUser = anonymousUser.copyWith(
        email: 'usuario@walletai.app',
        displayName: 'Carlos Vega',
        isAnonymous: false,
      );

      expect(linkedUser.isAnonymous, isFalse);
      expect(linkedUser.email, equals('usuario@walletai.app'));
      expect(linkedUser.displayName, equals('Carlos Vega'));
    });
  });

  group('UX Async States & Shimmer Widgets Tests', () {
    testWidgets('AsyncValueWidget renders shimmer in loading state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueWidget<String>(
              value: const AsyncValue.loading(),
              data: (data) => Text(data),
            ),
          ),
        ),
      );

      expect(find.byType(CardShimmerPlaceholder), findsOneWidget);
    });

    testWidgets('AsyncValueWidget renders error state and triggers retry', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueWidget<String>(
              value: AsyncValue.error('Conexión perdida', StackTrace.empty),
              data: (data) => Text(data),
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets('EmptyStateView renders icon, text and triggers action', (tester) async {
      bool actionTriggered = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.credit_card_outlined,
              title: 'Sin Tarjetas',
              message: 'Agrega una tarjeta para comenzar',
              actionLabel: 'Nueva Tarjeta',
              onAction: () {
                actionTriggered = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Sin Tarjetas'), findsOneWidget);
      expect(find.text('Agrega una tarjeta para comenzar'), findsOneWidget);
      expect(find.text('Nueva Tarjeta'), findsOneWidget);

      await tester.tap(find.text('Nueva Tarjeta'));
      await tester.pump();

      expect(actionTriggered, isTrue);
    });

    test('currentUserIdProvider defaults gracefully to demo_user when unauthenticated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final currentUserId = container.read(currentUserIdProvider);
      expect(currentUserId, equals('demo_user'));
    });
  });
}
