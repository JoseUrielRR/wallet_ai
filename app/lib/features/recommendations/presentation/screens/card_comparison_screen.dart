import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../engine/domain/billing_cycle_engine.dart';

class CardComparisonScreen extends ConsumerWidget {
  const CardComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsProvider).value ?? [];
    final activeCreditCards = cards.where((c) => c.isCredit && c.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparador de Tarjetas'),
      ),
      body: activeCreditCards.isEmpty
          ? const Center(
              child: Text(
                'No hay tarjetas de crédito activas registradas para comparar.',
                style: TextStyle(color: AppColors.textSubtleDark),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Matriz Comparativa Financiera',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Compara los ciclos de facturación, días de crédito y beneficios de tus plásticos activos.',
                  style: TextStyle(color: AppColors.textMediumDark, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ...activeCreditCards.map((card) {
                  final cycle = BillingCycleEngine.calculateCycle(card: card);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              card.alias.isNotEmpty ? card.alias : card.productName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textHighDark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.brandPrimary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${cycle.financingDaysAvailable}d libres',
                                style: const TextStyle(
                                  color: AppColors.brandPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildComparisonCell(
                                label: 'Corte',
                                value: 'Día ${card.statementClosingDay}',
                              ),
                            ),
                            Expanded(
                              child: _buildComparisonCell(
                                label: 'Pago',
                                value: 'Día ${card.paymentDueDay}',
                              ),
                            ),
                            Expanded(
                              child: _buildComparisonCell(
                                label: 'Disponible',
                                value: MoneyFormatter.formatCents(card.calculatedAvailableCreditCents),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.darkBorder),
                        const SizedBox(height: 6),
                        const Text(
                          'Beneficios clave:',
                          style: TextStyle(color: AppColors.textSubtleDark, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        if (card.benefits.isEmpty)
                          const Text('Sin beneficios registrados', style: TextStyle(color: AppColors.textSubtleDark, fontSize: 12))
                        else
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: card.benefits.map((b) {
                              return Chip(
                                label: Text('${b.category}: ${b.rewardRate}%'),
                                backgroundColor: AppColors.darkSurfaceElevated,
                                labelStyle: const TextStyle(fontSize: 11),
                                padding: EdgeInsets.zero,
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildComparisonCell({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSubtleDark, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textHighDark,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
