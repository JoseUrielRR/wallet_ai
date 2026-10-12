import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/models/user_card.dart';
import '../../../engine/domain/billing_cycle_engine.dart';

/// Componente de tarjeta digital interactiva con estética Modern Minimalist & Soft UI
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
      return AppColors.brandSecondary;
    }
  }

  LinearGradient _getCardGradient(UserCard card, Color baseColor) {
    final lowerName = '${card.issuerName} ${card.productName} ${card.alias}'.toLowerCase();

    if (lowerName.contains('nu') || card.colorHex.toUpperCase() == '#8A05BE') {
      return AppColors.nuGradient;
    }
    if (lowerName.contains('bbva') || card.colorHex.toUpperCase() == '#004481') {
      return AppColors.bbvaGradient;
    }
    if (lowerName.contains('rappi') || lowerName.contains('black') || card.colorHex.toUpperCase() == '#1A1A1A') {
      return AppColors.rappiGradient;
    }

    final hsl = HSLColor.fromColor(baseColor);
    final lighterColor = hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0)).toColor();
    final darkerColor = hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        lighterColor,
        baseColor,
        darkerColor,
      ],
      stops: const [0.0, 0.45, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _parseCardColor(card.colorHex);
    final gradient = _getCardGradient(card, baseColor);
    final cycle = card.isCredit ? BillingCycleEngine.calculateCycle(card: card) : null;
    final isRappi = card.issuerName.toLowerCase().contains('rappi') ||
        card.productName.toLowerCase().contains('rappi');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            const BoxShadow(
              color: Color(0x080F172A),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. Capa de brillo translúcido suave (Gloss Sheen)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.cardGloss,
                  ),
                ),
              ),

              // 2. Acento decorativo sutil estilo RappiCard
              if (isRappi) ...[
                Positioned(
                  top: 0,
                  left: 0,
                  bottom: 0,
                  width: 5,
                  child: Container(color: AppColors.rappiOrange),
                ),
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.rappiOrange.withValues(alpha: 0.18),
                    ),
                  ),
                ),
              ],

              // 3. Contenido Principal de la Tarjeta
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fila Superior: Emisor, Chip EMV y Contactless
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.28),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                card.issuerName.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (card.status == 'paused')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Pausada',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Chip EMV metálico y Símbolo Contactless
                        Row(
                          children: [
                            Icon(
                              Icons.contactless_rounded,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            _buildEmvChip(),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Nombre / Alias del Producto
                    Text(
                      card.alias.isNotEmpty ? card.alias : card.productName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Saldo / Límite de Crédito
                    if (card.isCredit) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Crédito disponible',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                MoneyFormatter.formatCents(
                                  card.calculatedAvailableCreditCents,
                                  currency: card.currency,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
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
                                MoneyFormatter.formatCents(
                                  card.currentBalanceCents,
                                  currency: card.currency,
                                ),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Pie de Tarjeta: Estado del Ciclo de Facturación y Últimos 4 Dígitos
                    if (showCycleDetails && cycle != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cycle.isFreshCycle
                                      ? AppColors.brandPrimaryLight
                                      : (cycle.daysUntilPaymentDue <= 5
                                          ? AppColors.warningLight
                                          : Colors.white70),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cycle.isFreshCycle
                                    ? 'Corte reciente (${cycle.financingDaysAvailable}d libres)'
                                    : 'Vence en ${cycle.daysUntilPaymentDue} días (corte día ${card.statementClosingDay})',
                                style: TextStyle(
                                  color: cycle.isFreshCycle
                                      ? AppColors.brandPrimaryLight
                                      : (cycle.daysUntilPaymentDue <= 5
                                          ? AppColors.warningLight
                                          : Colors.white.withValues(alpha: 0.9)),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (card.last4.isNotEmpty)
                            Text(
                              '•••• ${card.last4}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontFamily: 'monospace',
                                fontSize: 12,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 5,
                          color: Colors.black.withValues(alpha: 0.35),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _calculateCycleProgress(cycle).clamp(0.05, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  gradient: LinearGradient(
                                    colors: cycle.isFreshCycle
                                        ? [
                                            AppColors.brandPrimary,
                                            AppColors.brandPrimaryLight,
                                          ]
                                        : [
                                            AppColors.warningLight,
                                            AppColors.warning,
                                          ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            card.isCredit ? 'Línea de crédito' : 'Cuenta de débito',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                          if (card.last4.isNotEmpty)
                            Text(
                              '•••• ${card.last4}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontFamily: 'monospace',
                                fontSize: 12,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateCycleProgress(dynamic cycle) {
    try {
      final totalDays = (cycle.financingDaysAvailable as int?) ?? 30;
      final daysUntilDue = (cycle.daysUntilPaymentDue as int?) ?? 15;
      final elapsed = totalDays - daysUntilDue;
      return (elapsed / totalDays).clamp(0.1, 1.0);
    } catch (_) {
      return 0.35;
    }
  }

  Widget _buildEmvChip() {
    return Container(
      width: 28,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFE082),
            Color(0xFFFFD54F),
            Color(0xFFFFCA28),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFB300).withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Center(
        child: Container(
          width: 18,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: const Color(0xFF8D6E63).withValues(alpha: 0.35),
              width: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}
