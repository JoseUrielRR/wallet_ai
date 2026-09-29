import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_ai/features/cards/presentation/providers/cards_provider.dart';
import 'package:wallet_ai/features/engine/domain/recommendation_engine.dart';
import 'package:wallet_ai/features/engine/models/recommendation_result.dart';

/// Provider reactivo para la recomendación principal del día
final dailyRecommendationProvider = Provider<RecommendationResult>((ref) {
  final cardsAsync = ref.watch(cardsProvider);
  final cards = cardsAsync.value ?? [];

  return RecommendationEngine.evaluateRecommendation(
    cards: cards,
    purchaseAmountCents: 100000, // $1,000 MXN monto de referencia
    category: 'all',
    referenceDate: DateTime.now(),
  );
});

/// Parámetros para la simulación de compra
class SimulationParams {
  final int amountCents;
  final String category;

  const SimulationParams({
    required this.amountCents,
    required this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimulationParams &&
          runtimeType == other.runtimeType &&
          amountCents == other.amountCents &&
          category == other.category;

  @override
  int get hashCode => amountCents.hashCode ^ category.hashCode;
}

/// Provider familiar para el simulador de compra en tiempo real
final simulationRecommendationProvider =
    Provider.family<RecommendationResult, SimulationParams>((ref, params) {
  final cardsAsync = ref.watch(cardsProvider);
  final cards = cardsAsync.value ?? [];

  return RecommendationEngine.evaluateRecommendation(
    cards: cards,
    purchaseAmountCents: params.amountCents,
    category: params.category,
    referenceDate: DateTime.now(),
  );
});
