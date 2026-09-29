import 'package:wallet_ai/core/utils/money_formatter.dart';
import '../../cards/domain/models/user_card.dart';
import '../models/recommendation_result.dart';
import 'billing_cycle_engine.dart';
import 'cashback_calculator.dart';

class RecommendationEngine {
  RecommendationEngine._();

  /// Evalúa todas las tarjetas para un escenario de compra o para la recomendación diaria
  static RecommendationResult evaluateRecommendation({
    required List<UserCard> cards,
    required int purchaseAmountCents,
    required String category,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();

    final activeCards = cards.where((c) => c.isActive).toList();
    if (activeCards.isEmpty) {
      return RecommendationResult(
        category: category,
        purchaseAmountCents: purchaseAmountCents,
        evaluationDate: now,
        headline: 'No hay tarjetas activas',
        summaryExplanation: 'Registra o activa al menos una tarjeta en tu billetera para recibir recomendaciones inteligentes.',
      );
    }

    final List<RecommendationOption> evaluatedOptions = [];

    for (final card in activeCards) {
      final cycle = BillingCycleEngine.calculateCycle(
        card: card,
        referenceDate: now,
      );

      final cashback = CashbackCalculator.calculateReward(
        card: card,
        amountCents: purchaseAmountCents > 0 ? purchaseAmountCents : 100000, // $1,000 referencia si no hay monto
        category: category,
        purchaseDate: now,
      );

      final bool hasSufficientCredit = !card.isCredit ||
          purchaseAmountCents <= 0 ||
          card.calculatedAvailableCreditCents >= purchaseAmountCents;

      final List<String> reasons = [];
      final List<String> warnings = [];

      // Evaluación de días de gracia y ciclo
      if (card.isCredit) {
        if (cycle.isFreshCycle) {
          reasons.add('Nuevo ciclo de facturación recién iniciado (${cycle.financingDaysAvailable} días de financiamiento libre de intereses).');
        } else {
          reasons.add('${cycle.financingDaysAvailable} días disponibles antes de la fecha límite de pago.');
        }

        if (cycle.daysUntilCutoff <= 2) {
          warnings.add('Fecha de corte muy próxima (${cycle.daysUntilCutoff} días). Una compra ahora se facturará de inmediato.');
        }
      }

      // Evaluación de Recompensa
      if (cashback.rewardCents > 0) {
        final amountFormatted = MoneyFormatter.formatCents(cashback.rewardCents, currency: card.currency);
        reasons.add('Cashback estimado de $amountFormatted (${cashback.effectiveRate.toStringAsFixed(1)}%).');
      }

      // Evaluación de Línea de Crédito
      if (card.isCredit) {
        if (!hasSufficientCredit) {
          warnings.add('Crédito disponible insuficiente para este importe (${MoneyFormatter.formatCents(card.calculatedAvailableCreditCents, currency: card.currency)} disponibles).');
        }
        if (card.creditUtilizationRatio > 0.70) {
          warnings.add('Uso de línea alto (${(card.creditUtilizationRatio * 100).round()}%). Considera usar otra opción para cuidar tu score.');
        }
      }

      // Función de Puntuación Compuesta
      double score = 0.0;

      // 1. Ponderación Recompensa (0 a 50 puntos)
      score += (cashback.effectiveRate * 10.0).clamp(0.0, 50.0);

      // 2. Ponderación Días de Financiamiento (0 a 40 puntos)
      if (card.isCredit) {
        final daysNormalized = (cycle.financingDaysAvailable / 50.0).clamp(0.0, 1.0);
        score += daysNormalized * 40.0;
        if (cycle.isFreshCycle) score += 10.0; // Bonus por frescura
      } else {
        score += 5.0; // Débito tiene base neutra
      }

      // 3. Penalizaciones
      if (card.isCredit && card.creditUtilizationRatio > 0.70) {
        score -= 15.0;
      }
      if (!hasSufficientCredit) {
        score -= 100.0; // Descarte de prioridad
      }

      final confidence = cycle.confidence;

      evaluatedOptions.add(
        RecommendationOption(
          card: card,
          cycleResult: cycle,
          cashbackResult: cashback,
          score: score,
          hasSufficientCredit: hasSufficientCredit,
          reasons: reasons,
          warnings: warnings,
          confidence: confidence,
        ),
      );
    }

    // Ordenar de mayor a menor puntuación
    evaluatedOptions.sort((a, b) => b.score.compareTo(a.score));

    final winnerOption = evaluatedOptions.first;
    final winner = RecommendationOption(
      card: winnerOption.card,
      cycleResult: winnerOption.cycleResult,
      cashbackResult: winnerOption.cashbackResult,
      score: winnerOption.score,
      isWinner: true,
      hasSufficientCredit: winnerOption.hasSufficientCredit,
      reasons: winnerOption.reasons,
      warnings: winnerOption.warnings,
      confidence: winnerOption.confidence,
    );

    final alternatives = evaluatedOptions.skip(1).toList();

    // Redacción de resumen amigable y transparente
    String headline = 'Usa tu ${winner.card.alias.isNotEmpty ? winner.card.alias : winner.card.productName}';
    String summary = '';

    if (winner.cycleResult.isFreshCycle) {
      summary = 'Tu tarjeta acaba de iniciar ciclo. Una compra hoy te da ${winner.cycleResult.financingDaysAvailable} días antes de pagar.';
    } else if (winner.cashbackResult.rewardCents > 0) {
      summary = 'Ofrece la mejor recompensa con un cashback de ${MoneyFormatter.formatCents(winner.cashbackResult.rewardCents, currency: winner.card.currency)}.';
    } else {
      summary = 'Opción con mayor saldo disponible y holgura de pago (${winner.cycleResult.financingDaysAvailable} días).';
    }

    return RecommendationResult(
      winner: winner,
      alternatives: alternatives,
      allEvaluated: evaluatedOptions,
      category: category,
      purchaseAmountCents: purchaseAmountCents,
      evaluationDate: now,
      headline: headline,
      summaryExplanation: summary,
    );
  }
}
