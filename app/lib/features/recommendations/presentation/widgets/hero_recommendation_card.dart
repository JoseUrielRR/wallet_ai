import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../engine/models/recommendation_result.dart';

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
    if (!recommendation.hasRecommendation) {
      return Card(
        color: AppColors.darkSurface,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Recomendación del día',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                recommendation.summaryExplanation,
                style: const TextStyle(color: AppColors.textMediumDark),
              ),
            ],
          ),
        ),
      );
    }

    final winner = recommendation.winner!;
    final card = winner.card;
    final cycle = winner.cycleResult;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1C2D27),
            Color(0xFF161B22),
          ],
        ),
        border: Border.all(
          color: AppColors.brandPrimary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPrimary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.brandPrimary.withValues(alpha: 0.6),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: AppColors.brandPrimary, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'MEJOR OPCIÓN HOY',
                      style: TextStyle(
                        color: AppColors.brandPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormatter.formatShort(recommendation.evaluationDate),
                style: const TextStyle(
                  color: AppColors.textSubtleDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Título y Nombre de la Tarjeta Recomendada
          Text(
            recommendation.headline,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textHighDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${card.issuerName} • ${card.last4.isNotEmpty ? "•••• ${card.last4}" : card.productName}',
            style: const TextStyle(
              color: AppColors.brandPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          // Justificación en lenguaje claro y empático
          Text(
            recommendation.summaryExplanation,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMediumDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Métricas Clave de la Recomendación
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetricChip(
                icon: Icons.timer_outlined,
                label: '${cycle.financingDaysAvailable} días de pago',
                color: AppColors.brandPrimary,
              ),
              _buildMetricChip(
                icon: Icons.savings_outlined,
                label: 'Hasta ${winner.cashbackResult.effectiveRate.toStringAsFixed(1)}% cashback',
                color: AppColors.brandSecondary,
              ),
              _buildMetricChip(
                icon: Icons.event_available,
                label: 'Paga el ${DateFormatter.formatShort(cycle.paymentDueDate)}',
                color: AppColors.brandGold,
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
                  icon: const Icon(Icons.calculate_outlined, size: 18),
                  label: const Text('Simular Compra'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onCompareTap,
                icon: const Icon(Icons.compare_arrows, size: 18),
                label: const Text('Comparar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textHighDark,
                  side: const BorderSide(color: AppColors.darkBorder),
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
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
