import 'calculation_confidence.dart';

class BillingCycleResult {
  final String cardId;
  final DateTime cycleStartDate;
  final DateTime closingDate;
  final DateTime paymentDueDate;
  final int daysUntilCutoff;
  final int daysUntilPaymentDue;
  final int financingDaysAvailable;
  final bool isFreshCycle;
  final double cycleProgress; // 0.0 a 1.0
  final CalculationConfidence confidence;
  final String explanation;

  const BillingCycleResult({
    required this.cardId,
    required this.cycleStartDate,
    required this.closingDate,
    required this.paymentDueDate,
    required this.daysUntilCutoff,
    required this.daysUntilPaymentDue,
    required this.financingDaysAvailable,
    required this.isFreshCycle,
    required this.cycleProgress,
    required this.confidence,
    required this.explanation,
  });
}
