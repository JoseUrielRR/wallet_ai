import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ai/features/cards/domain/models/user_card.dart';
import 'package:wallet_ai/features/engine/domain/billing_cycle_engine.dart';

void main() {
  group('BillingCycleEngine - Math & Date Rules', () {
    test('TC-DATE-LEAP: Determina años bisiestos correctamente', () {
      expect(BillingCycleEngine.isLeapYear(2024), isTrue);
      expect(BillingCycleEngine.isLeapYear(2025), isFalse);
      expect(BillingCycleEngine.isLeapYear(2026), isFalse);
      expect(BillingCycleEngine.isLeapYear(2028), isTrue);
      expect(BillingCycleEngine.isLeapYear(2000), isTrue);
      expect(BillingCycleEngine.isLeapYear(1900), isFalse);
    });

    test('TC-DATE-NORM: Normaliza días mayores a la duración del mes', () {
      // 31 de abril se normaliza a 30 de abril
      final aprilDate = BillingCycleEngine.createNormalizedDate(2026, 4, 31);
      expect(aprilDate.day, 30);
      expect(aprilDate.month, 4);

      // 31 de febrero en año común (2025) se normaliza a 28 de febrero
      final febCommon = BillingCycleEngine.createNormalizedDate(2025, 2, 31);
      expect(febCommon.day, 28);
      expect(febCommon.month, 2);

      // 31 de febrero en año bisiesto (2028) se normaliza a 29 de febrero
      final febLeap = BillingCycleEngine.createNormalizedDate(2028, 2, 31);
      expect(febLeap.day, 29);
      expect(febLeap.month, 2);
    });

    test('TC-DATE-HOLIDAY: Corrimiento de fin de semana al lunes hábil', () {
      // 10 de octubre de 2026 es sábado -> lunes 12
      final saturday = DateTime.utc(2026, 10, 10);
      final adjustedSat = BillingCycleEngine.adjustDateForHolidays(saturday, true);
      expect(adjustedSat.weekday, DateTime.monday);
      expect(adjustedSat.day, 12);

      // 11 de octubre de 2026 es domingo -> lunes 12
      final sunday = DateTime.utc(2026, 10, 11);
      final adjustedSun = BillingCycleEngine.adjustDateForHolidays(sunday, true);
      expect(adjustedSun.weekday, DateTime.monday);
      expect(adjustedSun.day, 12);

      // Si adjustForHolidays es false, se mantiene sin cambio
      final unadjusted = BillingCycleEngine.adjustDateForHolidays(saturday, false);
      expect(unadjusted.day, 10);
    });

    test('TC-DATE-CYCLE: Asignación de ciclo y cálculo de días de financiamiento', () {
      final card = UserCard(
        id: 'c1',
        userId: 'u1',
        issuerId: 'iss_nu',
        issuerName: 'Nu',
        productName: 'Nu Card',
        alias: 'Moradita',
        type: 'credit',
        creditLimitCents: 5000000,
        currentBalanceCents: 1000000,
        availableCreditCents: 4000000,
        statementClosingDay: 14,
        paymentDueDay: 4,
        daysBetweenCutoffAndDue: 20,
        adjustForHolidays: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      // Escenario A: Compra el mismo día del corte (14 de septiembre)
      final onCutoffDate = DateTime.utc(2026, 9, 14);
      final resultA = BillingCycleEngine.calculateCycle(
        card: card,
        referenceDate: onCutoffDate,
      );
      expect(resultA.closingDate.day, 14);
      expect(resultA.closingDate.month, 9);
      // Pago es 14 sep + 20 días = 4 de octubre
      expect(resultA.paymentDueDate.day, 4);
      expect(resultA.paymentDueDate.month, 10);
      expect(resultA.financingDaysAvailable, 20);

      // Escenario B: Compra el día posterior al corte (15 de septiembre) - Ciclo fresco
      final afterCutoffDate = DateTime.utc(2026, 9, 15);
      final resultB = BillingCycleEngine.calculateCycle(
        card: card,
        referenceDate: afterCutoffDate,
      );
      // El corte asignado es el de octubre (14 de octubre)
      expect(resultB.closingDate.day, 14);
      expect(resultB.closingDate.month, 10);
      // Pago es 14 oct + 20 días = 3 de noviembre
      expect(resultB.paymentDueDate.day, 3);
      expect(resultB.paymentDueDate.month, 11);
      // Días libres de financiamiento: del 15 sep al 3 nov = 49 días
      expect(resultB.financingDaysAvailable, 49);
      expect(resultB.isFreshCycle, isTrue);
    });

    test('TC-DATE-DEBIT: Tarjetas de débito tienen 0 días de financiamiento', () {
      final debitCard = UserCard(
        id: 'd1',
        userId: 'u1',
        issuerId: 'iss_bbva',
        issuerName: 'BBVA',
        productName: 'Débito BBVA',
        alias: 'Nómina',
        type: 'debit',
        creditLimitCents: 0,
        currentBalanceCents: 0,
        availableCreditCents: 1500000,
        statementClosingDay: 1,
        paymentDueDay: 1,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final result = BillingCycleEngine.calculateCycle(card: debitCard);
      expect(result.financingDaysAvailable, 0);
      expect(result.isFreshCycle, isFalse);
    });
  });
}
