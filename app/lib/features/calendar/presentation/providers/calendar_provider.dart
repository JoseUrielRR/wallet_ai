import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_ai/features/cards/presentation/providers/cards_provider.dart';
import 'package:wallet_ai/features/loans/presentation/providers/loans_provider.dart';
import 'package:wallet_ai/features/purchases/presentation/providers/purchases_provider.dart';
import 'package:wallet_ai/features/engine/domain/billing_cycle_engine.dart';

class FinancialEvent {
  final String id;
  final String title;
  final DateTime date;
  final String type; // 'cutoff', 'payment_due', 'loan_payment', 'purchase'
  final String? cardId;
  final String? loanId;
  final int? amountCents;
  final String subtitle;
  final String colorHex;

  const FinancialEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.cardId,
    this.loanId,
    this.amountCents,
    required this.subtitle,
    required this.colorHex,
  });
}

/// Provider reactivo que compila todos los eventos financieros para el calendario
final calendarEventsProvider = Provider<List<FinancialEvent>>((ref) {
  final cards = ref.watch(cardsProvider).value ?? [];
  final loans = ref.watch(loansProvider).value ?? [];
  final purchases = ref.watch(purchasesProvider).value ?? [];

  final List<FinancialEvent> events = [];
  final now = DateTime.now();

  // 1. Fechas de corte y pago de tarjetas
  for (final card in cards.where((c) => c.isActive && c.isCredit)) {
    final cycle = BillingCycleEngine.calculateCycle(card: card, referenceDate: now);

    // Evento de Corte
    events.add(
      FinancialEvent(
        id: 'cutoff_${card.id}',
        title: 'Corte ${card.alias.isNotEmpty ? card.alias : card.productName}',
        date: cycle.closingDate,
        type: 'cutoff',
        cardId: card.id,
        subtitle: 'Cierre del ciclo de facturación',
        colorHex: '#388BFD', // Azul
      ),
    );

    // Evento de Fecha Límite de Pago
    events.add(
      FinancialEvent(
        id: 'due_${card.id}',
        title: 'Pago ${card.alias.isNotEmpty ? card.alias : card.productName}',
        date: cycle.paymentDueDate,
        type: 'payment_due',
        cardId: card.id,
        amountCents: card.currentBalanceCents,
        subtitle: 'Fecha límite para liquidar saldo',
        colorHex: '#D29922', // Ámbar
      ),
    );
  }

  // 2. Próximos pagos de préstamos
  for (final loan in loans.where((l) => l.isActive)) {
    events.add(
      FinancialEvent(
        id: 'loan_${loan.id}',
        title: 'Cuota ${loan.name}',
        date: loan.nextPaymentDate,
        type: 'loan_payment',
        loanId: loan.id,
        amountCents: loan.paymentAmountCents,
        subtitle: 'Pago mensual de préstamo (${loan.lender})',
        colorHex: '#8A05BE', // Púrpura
      ),
    );
  }

  // 3. Compras registradas
  for (final purchase in purchases) {
    events.add(
      FinancialEvent(
        id: 'purchase_${purchase.id}',
        title: purchase.merchant.isNotEmpty ? purchase.merchant : purchase.description,
        date: purchase.purchaseDate,
        type: 'purchase',
        cardId: purchase.cardId,
        amountCents: purchase.amountCents,
        subtitle: purchase.cardAlias,
        colorHex: '#238636', // Verde
      ),
    );
  }

  // Ordenar cronológicamente
  events.sort((a, b) => a.date.compareTo(b.date));
  return events;
});
