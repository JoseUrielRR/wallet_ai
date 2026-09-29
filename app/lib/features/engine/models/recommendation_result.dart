import '../../cards/domain/models/user_card.dart';
import 'billing_cycle_result.dart';
import 'calculation_confidence.dart';
import '../domain/cashback_calculator.dart';

class RecommendationOption {
  final UserCard card;
  final BillingCycleResult cycleResult;
  final CashbackCalculationResult cashbackResult;
  final double score;
  final bool isWinner;
  final bool hasSufficientCredit;
  final List<String> reasons;
  final List<String> warnings;
  final CalculationConfidence confidence;

  const RecommendationOption({
    required this.card,
    required this.cycleResult,
    required this.cashbackResult,
    required this.score,
    this.isWinner = false,
    required this.hasSufficientCredit,
    required this.reasons,
    required this.warnings,
    required this.confidence,
  });
}

class RecommendationResult {
  final RecommendationOption? winner;
  final List<RecommendationOption> alternatives;
  final List<RecommendationOption> allEvaluated;
  final String category;
  final int purchaseAmountCents;
  final DateTime evaluationDate;
  final String headline;
  final String summaryExplanation;

  const RecommendationResult({
    this.winner,
    this.alternatives = const [],
    this.allEvaluated = const [],
    required this.category,
    required this.purchaseAmountCents,
    required this.evaluationDate,
    required this.headline,
    required this.summaryExplanation,
  });

  bool get hasRecommendation => winner != null;
}
