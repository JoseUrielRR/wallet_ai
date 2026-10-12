import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../engine/models/recommendation_result.dart';

/// Tarjeta Hero Recomendada del Día con estética Modern Minimalist & Soft UI Pastel.
class HeroRecommendationCard extends StatelessWidget {
  final RecommendationResult recommendation;
  final VoidCallback onSimulateTap;
  final VoidCallback onCompareTap;

  const HeroRecommendationCard({
    super.key,
    required this.recommendation,
    required this.onSimulateTap,
    required this.onCompareTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!recommendation.hasRecommendation) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.softSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.softBorder,
            width: 1,
          ),
          boxShadow: const [AppColors.softShadow],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.pastelAmberBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.pastelAmberBorder),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: AppColors.pastelAmberText, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  'Recomendación del día',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark ? AppColors.textHighDark : AppColors.slate900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              recommendation.summaryExplanation,
              style: TextStyle(
                color: isDark ? AppColors.textMediumDark : AppColors.slate500,
                height: 1.45,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final winner = recommendation.winner!;
    final card = winner.card;
    final cycle = winner.cycleResult;
    final cardDisplayName = card.alias.isNotEmpty ? card.alias : card.productName;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isDark
            ? AppColors.heroBackground
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F9F0),
                  Color(0xFFF3FAF6),
                  Colors.white,
                ],
                stops: [0.0, 0.45, 1.0],
              ),
        border: Border.all(
          color: isDark
              ? AppColors.brandPrimary.withValues(alpha: 0.35)
              : AppColors.pastelMintBorder,
          width: 1.2,
        ),
        boxShadow: [
          isDark
              ? BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                )
              : const BoxShadow(
                  color: Color(0x0C059669),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Superior y Fecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.brandPrimary.withValues(alpha: 0.15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.brandPrimary.withValues(alpha: 0.45)
                          : AppColors.pastelMintBorder,
                    ),
                    boxShadow: isDark
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppColors.pastelMintText,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'IA RECOMIENDA: $cardDisplayName',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.pastelMintText,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormatter.formatShort(recommendation.evaluationDate),
                style: TextStyle(
                  color: isDark ? AppColors.textSubtleDark : AppColors.slate400,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Título Principal
          Text(
            recommendation.headline,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textHighDark : AppColors.slate900,
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 3),

          // Emisor y Últimos 4
          Text(
            '${card.issuerName} ${card.last4.isNotEmpty ? "•••• ${card.last4}" : ""}',
            style: const TextStyle(
              color: AppColors.pastelMintText,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          // Justificación en lenguaje claro y empático
          Text(
            recommendation.summaryExplanation,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? AppColors.textMediumDark : AppColors.slate600,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 16),

          // Métricas Clave de la Recomendación (Pastel Pill Chips)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetricChip(
                icon: Icons.schedule_rounded,
                label: '${cycle.financingDaysAvailable} días sin intereses',
                bg: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.pastelMintBg,
                border: isDark ? AppColors.brandPrimary.withValues(alpha: 0.3) : AppColors.pastelMintBorder,
                text: AppColors.pastelMintText,
              ),
              if (winner.cashbackResult.effectiveRate > 0)
                _buildMetricChip(
                  icon: Icons.savings_outlined,
                  label: 'Cashback: ${winner.cashbackResult.effectiveRate.toStringAsFixed(1)}%',
                  bg: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.pastelLavenderBg,
                  border: isDark ? AppColors.brandSecondary.withValues(alpha: 0.3) : AppColors.pastelLavenderBorder,
                  text: AppColors.pastelLavenderText,
                ),
              _buildMetricChip(
                icon: Icons.event_available_rounded,
                label: 'Paga el ${DateFormatter.formatShort(cycle.paymentDueDate)}',
                bg: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.pastelAmberBg,
                border: isDark ? AppColors.brandGold.withValues(alpha: 0.3) : AppColors.pastelAmberBorder,
                text: AppColors.pastelAmberText,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Botones de Acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSimulateTap,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Simular Compra'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: onCompareTap,
                icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                label: const Text('Comparar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.textHighDark : AppColors.slate700,
                  backgroundColor: isDark ? Colors.transparent : Colors.white,
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : AppColors.softBorder,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color bg,
    required Color border,
    required Color text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: text, size: 13.5),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
