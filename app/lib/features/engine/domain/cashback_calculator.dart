import '../../cards/domain/models/benefit.dart';
import '../../cards/domain/models/user_card.dart';

class CashbackCalculationResult {
  final int rewardCents;
  final double effectiveRate;
  final String rewardType;
  final Benefit? appliedBenefit;
  final bool capReached;
  final String explanation;

  const CashbackCalculationResult({
    required this.rewardCents,
    required this.effectiveRate,
    required this.rewardType,
    this.appliedBenefit,
    this.capReached = false,
    required this.explanation,
  });
}

/// Calculadora de cashback y recompensas con topes y exclusiones
class CashbackCalculator {
  CashbackCalculator._();

  static CashbackCalculationResult calculateReward({
    required UserCard card,
    required int amountCents,
    required String category,
    DateTime? purchaseDate,
    int priorAccumulatedRewardCents = 0,
  }) {
    if (amountCents <= 0 || card.benefits.isEmpty) {
      return const CashbackCalculationResult(
        rewardCents: 0,
        effectiveRate: 0.0,
        rewardType: 'none',
        explanation: 'Esta tarjeta no tiene beneficios registrados o el monto es cero.',
      );
    }

    final targetDate = purchaseDate ?? DateTime.now();

    // Filtrar beneficios vigentes
    final activeBenefits = card.benefits.where((b) => b.isCurrentlyActive(targetDate)).toList();
    if (activeBenefits.isEmpty) {
      return const CashbackCalculationResult(
        rewardCents: 0,
        effectiveRate: 0.0,
        rewardType: 'none',
        explanation: 'No hay promociones vigentes para esta fecha.',
      );
    }

    // Buscar beneficios específicos de la categoría o comodín 'all'
    final candidateBenefits = activeBenefits.where((b) {
      return b.category == category || b.category == 'all';
    }).toList();

    if (candidateBenefits.isEmpty) {
      return const CashbackCalculationResult(
        rewardCents: 0,
        effectiveRate: 0.0,
        rewardType: 'none',
        explanation: 'Sin beneficio específico ni general para esta categoría.',
      );
    }

    // Ordenar de mayor a menor tasa para maximizar el beneficio del usuario
    candidateBenefits.sort((a, b) => b.rewardRate.compareTo(a.rewardRate));

    Benefit? selectedBenefit;
    int calculatedReward = 0;
    bool isCapped = false;
    String reason = '';

    for (final benefit in candidateBenefits) {
      // Validar gasto mínimo
      if (benefit.minimumSpendCents > 0 && amountCents < benefit.minimumSpendCents) {
        continue;
      }

      final grossReward = (amountCents * (benefit.rewardRate / 100.0)).round();

      if (benefit.rewardCapCents > 0) {
        final remainingCap = benefit.rewardCapCents - priorAccumulatedRewardCents;
        if (remainingCap <= 0) {
          isCapped = true;
          continue; // Tope agotado, probar siguiente beneficio elegible
        }
        calculatedReward = grossReward > remainingCap ? remainingCap : grossReward;
        if (grossReward > remainingCap) {
          isCapped = true;
        }
      } else {
        calculatedReward = grossReward;
      }

      selectedBenefit = benefit;
      break;
    }

    if (selectedBenefit == null) {
      return CashbackCalculationResult(
        rewardCents: 0,
        effectiveRate: 0.0,
        rewardType: 'none',
        capReached: isCapped,
        explanation: isCapped
            ? 'Has alcanzado el tope mensual de recompensa para esta categoría.'
            : 'La compra no cumple con el monto mínimo de gasto requerido para activar el beneficio.',
      );
    }

    final double effectiveRate = selectedBenefit.rewardRate;
    final String categoryDesc = selectedBenefit.category == 'all'
        ? 'en todas las compras'
        : 'en la categoría seleccionada';

    reason = 'Bonificación del ${effectiveRate.toStringAsFixed(1)}% $categoryDesc.';
    if (isCapped) {
      reason += ' Recompensa acotada al tope restante disponible.';
    }

    return CashbackCalculationResult(
      rewardCents: calculatedReward,
      effectiveRate: effectiveRate,
      rewardType: selectedBenefit.rewardType,
      appliedBenefit: selectedBenefit,
      capReached: isCapped,
      explanation: reason,
    );
  }
}
