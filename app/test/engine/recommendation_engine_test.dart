import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ai/features/cards/domain/models/benefit.dart';
import 'package:wallet_ai/features/cards/domain/models/user_card.dart';
import 'package:wallet_ai/features/engine/domain/recommendation_engine.dart';

void main() {
  group('RecommendationEngine - Multicriteria Decision Tests', () {
    // Tarjeta 1: Recién cortó ayer (14 sep), tiene 4% en restaurantes y amplio crédito
    final cardAurora = UserCard(
      id: 'c_aurora',
      userId: 'u1',
      issuerId: 'iss_aurora',
      issuerName: 'Banco Aurora',
      productName: 'Aurora Black',
      alias: 'Aurora Rewards',
      type: 'credit',
      creditLimitCents: 5000000,
      currentBalanceCents: 500000,
      availableCreditCents: 4500000,
      statementClosingDay: 14,
      paymentDueDay: 4,
      daysBetweenCutoffAndDue: 20,
      status: 'active',
      benefits: [
        const Benefit(
          id: 'b1',
          category: 'dining',
          rewardType: 'cashback',
          rewardRate: 4.0,
        ),
      ],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    // Tarjeta 2: Corta en 2 días, solo 1% cashback
    final cardPrisma = UserCard(
      id: 'c_prisma',
      userId: 'u1',
      issuerId: 'iss_prisma',
      issuerName: 'Banco Prisma',
      productName: 'Prisma Simple',
      alias: 'Prisma Clásica',
      type: 'credit',
      creditLimitCents: 3000000,
      currentBalanceCents: 1000000,
      availableCreditCents: 2000000,
      statementClosingDay: 17,
      paymentDueDay: 7,
      daysBetweenCutoffAndDue: 20,
      status: 'active',
      benefits: [
        const Benefit(
          id: 'b2',
          category: 'all',
          rewardType: 'cashback',
          rewardRate: 1.0,
        ),
      ],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    // Tarjeta 3: Pausada
    final cardPaused = cardAurora.copyWith(
      id: 'c_paused',
      alias: 'Aurora Pausada',
      status: 'paused',
    );

    test('TC-REC-WINNER: Selecciona la mejor opción combinando ciclo fresco y mayor recompensa', () {
      final now = DateTime.utc(2026, 9, 15); // Día posterior al corte de Aurora
      final result = RecommendationEngine.evaluateRecommendation(
        cards: [cardPrisma, cardAurora],
        purchaseAmountCents: 150000, // $1,500 MXN
        category: 'dining',
        referenceDate: now,
      );

      expect(result.hasRecommendation, isTrue);
      expect(result.winner?.card.id, 'c_aurora');
      expect(result.winner?.isWinner, isTrue);
      expect(result.winner?.reasons.isNotEmpty, isTrue);
      expect(result.alternatives.length, 1);
      expect(result.alternatives.first.card.id, 'c_prisma');
    });

    test('TC-REC-CREDIT: Penaliza tarjetas con crédito insuficiente', () {
      final now = DateTime.utc(2026, 9, 15);
      // Compra de $30,000 MXN (3000000 centavos): Aurora tiene $45,000 disponible, Prisma solo tiene $20,000 disponible
      final result = RecommendationEngine.evaluateRecommendation(
        cards: [cardPrisma, cardAurora],
        purchaseAmountCents: 3000000,
        category: 'other',
        referenceDate: now,
      );

      expect(result.winner?.card.id, 'c_aurora');
      final prismaOption = result.allEvaluated.firstWhere((o) => o.card.id == 'c_prisma');
      expect(prismaOption.hasSufficientCredit, isFalse);
      expect(prismaOption.warnings.any((w) => w.contains('insuficiente')), isTrue);
    });

    test('TC-REC-INACTIVE: Excluye tarjetas inactivas o pausadas de la evaluación', () {
      final result = RecommendationEngine.evaluateRecommendation(
        cards: [cardPaused],
        purchaseAmountCents: 100000,
        category: 'dining',
      );

      expect(result.hasRecommendation, isFalse);
      expect(result.headline, contains('No hay tarjetas activas'));
    });
  });
}
