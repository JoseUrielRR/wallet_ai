import 'package:flutter/material.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/models/user_card.dart';
import '../../../engine/domain/billing_cycle_engine.dart';

class DigitalCardWidget extends StatelessWidget {
  final UserCard card;
  final VoidCallback? onTap;
  final bool showCycleDetails;

  const DigitalCardWidget({
    super.key,
    required this.card,
    this.onTap,
    this.showCycleDetails = true,
  });

  Color _parseCardColor(String hex) {
    try {
      final cleanHex = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16));
    } catch (_) {
      return const Color(0xFF388BFD);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _parseCardColor(card.colorHex);
    final cycle = card.isCredit ? BillingCycleEngine.calculateCycle(card: card) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              baseColor.withValues(alpha: 0.95),
              baseColor.withValues(alpha: 0.75),
              const Color(0xFF161B22),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Emisor y Chip / Tipo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        card.issuerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (card.status == 'paused')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Pausada',
                          style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                Text(
                  card.isCredit ? 'CRÉDITO' : 'DÉBITO',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Alias y últimos 4
            Text(
              card.alias.isNotEmpty ? card.alias : card.productName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (card.last4.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '•••• •••• •••• ${card.last4}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontFamily: 'monospace',
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Balance y Disponible
            if (card.isCredit) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disponible',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        MoneyFormatter.formatCents(card.calculatedAvailableCreditCents, currency: card.currency),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Saldo utilizado',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        MoneyFormatter.formatCents(card.currentBalanceCents, currency: card.currency),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Barra de utilización de crédito
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: card.creditUtilizationRatio.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    card.creditUtilizationRatio > 0.70 ? Colors.amberAccent : const Color(0xFF00D26A),
                  ),
                ),
              ),
            ] else ...[
              Text(
                'Saldo en cuenta',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                MoneyFormatter.formatCents(card.availableCreditCents, currency: card.currency),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            // Indicador de Ciclo de Facturación (si aplica)
            if (showCycleDetails && cycle != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          cycle.isFreshCycle ? Icons.bolt : Icons.calendar_today_outlined,
                          color: cycle.isFreshCycle ? Colors.amberAccent : Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cycle.isFreshCycle
                              ? '¡Ciclo fresco! (${cycle.financingDaysAvailable}d libres)'
                              : 'Vence en ${cycle.daysUntilPaymentDue} días',
                          style: TextStyle(
                            color: cycle.isFreshCycle ? Colors.amberAccent : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Corte: día ${card.statementClosingDay}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
