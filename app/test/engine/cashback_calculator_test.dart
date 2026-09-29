import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ai/features/cards/domain/models/benefit.dart';
import 'package:wallet_ai/features/cards/domain/models/user_card.dart';
import 'package:wallet_ai/features/engine/domain/cashback_calculator.dart';

void main() {
  group('CashbackCalculator - Financial Precision & Rules', () {
    final cardWithBenefits = UserCard(
      id: 'c1',
      userId: 'u1',
      issuerId: 'iss_aurora',
      issuerName: 'Banco Aurora',
      productName: 'Aurora Black',
      alias: 'Black',
      type: 'credit',
      creditLimitCents: 10000000,
      currentBalanceCents: 2000000,
      availableCreditCents: 8000000,
      statementClosingDay: 15,
      paymentDueDay: 5,
      benefits: [
        const Benefit(
          id: 'b1',
          category: 'supermarket',
          rewardType: 'cashback',
          rewardRate: 3.0,
          rewardCapCents: 50000, // Tope $500 MXN
          minimumSpendCents: 50000, // Mínimo $500 MXN
        ),
        const Benefit(
          id: 'b2',
          category: 'fuel',
          rewardType: 'cashback',
          rewardRate: 5.0,
          rewardCapCents: 30000, // Tope $300 MXN
        ),
        const Benefit(
          id: 'b3',
          category: 'all',
          rewardType: 'cashback',
          rewardRate: 1.0,
        ),
      ],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('TC-CASH-CAT: Calcula cashback porcentual exacto para categoría específica', () {
      // Compra de $1,500 MXN (150000 centavos) en supermercado con 3%
      final result = CashbackCalculator.calculateReward(
        card: cardWithBenefits,
        amountCents: 150000,
        category: 'supermarket',
      );

      // 150000 * 0.03 = 4500 centavos ($45.00 MXN)
      expect(result.rewardCents, 4500);
      expect(result.effectiveRate, 3.0);
      expect(result.capReached, isFalse);
    });

    test('TC-CASH-MIN: Respeta condición de gasto mínimo', () {
      // Compra de $300 MXN (30000 centavos) en supermercado (mínimo requerido: $500 MXN)
      // Como no califica para el beneficio de 3%, debe usar el beneficio comodín 'all' de 1%
      final result = CashbackCalculator.calculateReward(
        card: cardWithBenefits,
        amountCents: 30000,
        category: 'supermarket',
      );

      // 30000 * 0.01 = 300 centavos ($3.00 MXN)
      expect(result.rewardCents, 300);
      expect(result.effectiveRate, 1.0);
    });

    test('TC-CASH-CAP: Acota recompensa si se alcanza el tope máximo del periodo', () {
      // Compra de $8,000 MXN (800000 centavos) en gasolina con 5%
      // 5% de 800000 es 40000 centavos ($400 MXN), pero el tope es $300 MXN (30000 centavos)
      final result = CashbackCalculator.calculateReward(
        card: cardWithBenefits,
        amountCents: 800000,
        category: 'fuel',
        priorAccumulatedRewardCents: 0,
      );

      expect(result.rewardCents, 30000);
      expect(result.capReached, isTrue);

      // Si ya tenía acumulados $250 MXN (25000 centavos), el restante es solo $50 MXN (5000 centavos)
      final resultRemaining = CashbackCalculator.calculateReward(
        card: cardWithBenefits,
        amountCents: 800000,
        category: 'fuel',
        priorAccumulatedRewardCents: 25000,
      );

      expect(resultRemaining.rewardCents, 5000);
      expect(resultRemaining.capReached, isTrue);
    });

    test('TC-CASH-EXPIRED: No aplica beneficios con fecha de vigencia vencida', () {
      final cardWithExpiredBenefit = UserCard(
        id: 'c2',
        userId: 'u1',
        issuerId: 'iss_promo',
        issuerName: 'Promo Bank',
        productName: 'Promo',
        alias: 'Promo Card',
        type: 'credit',
        creditLimitCents: 1000000,
        currentBalanceCents: 0,
        availableCreditCents: 1000000,
        statementClosingDay: 10,
        paymentDueDay: 30,
        benefits: [
          Benefit(
            id: 'promo_vencida',
            category: 'supermarket',
            rewardType: 'cashback',
            rewardRate: 10.0,
            endDate: DateTime.utc(2026, 8, 31), // Venció el 31 de agosto
          ),
          const Benefit(
            id: 'base',
            category: 'all',
            rewardType: 'cashback',
            rewardRate: 1.0,
          ),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      // Compra realizada el 15 de septiembre de 2026
      final result = CashbackCalculator.calculateReward(
        card: cardWithExpiredBenefit,
        amountCents: 100000,
        category: 'supermarket',
        purchaseDate: DateTime.utc(2026, 9, 15),
      );

      // No debe obtener 10%, sino la tasa base de 1%
      expect(result.effectiveRate, 1.0);
      expect(result.rewardCents, 1000);
    });
  });
}
