import '../../cards/domain/models/user_card.dart';
import '../models/billing_cycle_result.dart';
import '../models/calculation_confidence.dart';

/// Motor financiero de alta precisión para fechas de corte y periodos de facturación
class BillingCycleEngine {
  BillingCycleEngine._();

  /// Determina si un año es bisiesto
  static bool isLeapYear(int year) {
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    return year % 4 == 0;
  }

  /// Retorna la cantidad máxima de días de un mes y año dados
  static int daysInMonth(int year, int month) {
    switch (month) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        return 31;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      case 2:
        return isLeapYear(year) ? 29 : 28;
      default:
        throw ArgumentError('Mes inválido: $month');
    }
  }

  /// Normaliza un día de corte o pago al último día válido del mes
  static DateTime createNormalizedDate(int year, int month, int targetDay) {
    final maxDays = daysInMonth(year, month);
    final effectiveDay = targetDay > maxDays ? maxDays : targetDay;
    return DateTime.utc(year, month, effectiveDay);
  }

  /// Aplica el corrimiento de día bancario inhábil (sábado o domingo al lunes siguiente)
  static DateTime adjustDateForHolidays(DateTime date, bool applyAdjustment) {
    if (!applyAdjustment) return date;
    // DateTime.weekday: Monday is 1 and Sunday is 7
    if (date.weekday == DateTime.saturday) {
      return date.add(const Duration(days: 2));
    } else if (date.weekday == DateTime.sunday) {
      return date.add(const Duration(days: 1));
    }
    return date;
  }

  /// Calcula el ciclo de facturación y días de financiamiento para una tarjeta en una fecha de referencia
  static BillingCycleResult calculateCycle({
    required UserCard card,
    DateTime? referenceDate,
  }) {
    final now = referenceDate != null
        ? DateTime.utc(referenceDate.year, referenceDate.month, referenceDate.day)
        : DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    if (card.isDebit) {
      return BillingCycleResult(
        cardId: card.id,
        cycleStartDate: now,
        closingDate: now,
        paymentDueDate: now,
        daysUntilCutoff: 0,
        daysUntilPaymentDue: 0,
        financingDaysAvailable: 0,
        isFreshCycle: false,
        cycleProgress: 1.0,
        confidence: CalculationConfidence.confirmed,
        explanation: 'Tarjeta de débito: cargos debitados de forma inmediata.',
      );
    }

    final closingDay = card.statementClosingDay;
    final paymentDay = card.paymentDueDay;

    // Corte del mes actual
    final currentMonthCutoff = createNormalizedDate(now.year, now.month, closingDay);

    DateTime effectiveClosingDate;
    DateTime effectiveStartDate;
    DateTime effectivePaymentDueDate;

    if (now.isAfter(currentMonthCutoff)) {
      // La fecha ya pasó el corte de este mes; la compra pertenece al ciclo del próximo mes
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;

      effectiveStartDate = currentMonthCutoff.add(const Duration(days: 1));
      effectiveClosingDate = createNormalizedDate(nextYear, nextMonth, closingDay);

      // Calcular fecha límite de pago para este nuevo ciclo
      if (card.daysBetweenCutoffAndDue > 0) {
        effectivePaymentDueDate = effectiveClosingDate.add(
          Duration(days: card.daysBetweenCutoffAndDue),
        );
      } else {
        // Derivar mes de pago
        final dueMonth = paymentDay < closingDay
            ? (nextMonth == 12 ? 1 : nextMonth + 1)
            : nextMonth;
        final dueYear = (paymentDay < closingDay && nextMonth == 12)
            ? nextYear + 1
            : nextYear;
        effectivePaymentDueDate = createNormalizedDate(dueYear, dueMonth, paymentDay);
      }
    } else {
      // La fecha está antes o en el mismo día del corte de este mes
      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final prevYear = now.month == 1 ? now.year - 1 : now.year;
      final prevCutoff = createNormalizedDate(prevYear, prevMonth, closingDay);

      effectiveStartDate = prevCutoff.add(const Duration(days: 1));
      effectiveClosingDate = currentMonthCutoff;

      if (card.daysBetweenCutoffAndDue > 0) {
        effectivePaymentDueDate = effectiveClosingDate.add(
          Duration(days: card.daysBetweenCutoffAndDue),
        );
      } else {
        final dueMonth = paymentDay < closingDay
            ? (now.month == 12 ? 1 : now.month + 1)
            : now.month;
        final dueYear = (paymentDay < closingDay && now.month == 12)
            ? now.year + 1
            : now.year;
        effectivePaymentDueDate = createNormalizedDate(dueYear, dueMonth, paymentDay);
      }
    }

    // Ajustar por día inhábil bancario si está configurado
    effectivePaymentDueDate = adjustDateForHolidays(
      effectivePaymentDueDate,
      card.adjustForHolidays,
    );

    // Días de financiamiento disponible
    final financingDays = effectivePaymentDueDate.difference(now).inDays;
    final daysUntilCutoff = effectiveClosingDate.difference(now).inDays;
    final daysUntilPaymentDue = effectivePaymentDueDate.difference(now).inDays;

    // Progreso del ciclo (entre inicio de ciclo y corte)
    final totalCycleDays = effectiveClosingDate.difference(effectiveStartDate).inDays;
    final daysElapsed = now.difference(effectiveStartDate).inDays;
    final progress = totalCycleDays > 0
        ? (daysElapsed / totalCycleDays).clamp(0.0, 1.0)
        : 0.0;

    // Es ciclo fresco si hoy está dentro de los 5 días posteriores al corte previo
    final daysSinceStart = now.difference(effectiveStartDate).inDays;
    final isFresh = daysSinceStart >= 0 && daysSinceStart <= 4;

    String explanation;
    if (isFresh) {
      explanation = '¡Ciclo recién iniciado! Una compra hoy maximiza tu financiamiento con $financingDays días antes de pagar.';
    } else if (daysUntilCutoff <= 2) {
      explanation = 'Corte inminente en $daysUntilCutoff días. Si puedes postergar una compra grande 2 días, obtendrás el ciclo completo.';
    } else {
      explanation = 'Faltan $daysUntilCutoff días para tu próximo corte y dispones de $financingDays días de financiamiento libre.';
    }

    final confidence = (card.confirmedClosingDate != null && card.confirmedPaymentDueDate != null)
        ? CalculationConfidence.confirmed
        : CalculationConfidence.estimated;

    return BillingCycleResult(
      cardId: card.id,
      cycleStartDate: effectiveStartDate,
      closingDate: effectiveClosingDate,
      paymentDueDate: effectivePaymentDueDate,
      daysUntilCutoff: daysUntilCutoff < 0 ? 0 : daysUntilCutoff,
      daysUntilPaymentDue: daysUntilPaymentDue < 0 ? 0 : daysUntilPaymentDue,
      financingDaysAvailable: financingDays < 0 ? 0 : financingDays,
      isFreshCycle: isFresh,
      cycleProgress: progress,
      confidence: confidence,
      explanation: explanation,
    );
  }
}
