import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../engine/domain/billing_cycle_engine.dart';
import '../../../purchases/presentation/screens/purchase_form_screen.dart';
import '../providers/cards_provider.dart';
import '../widgets/digital_card_widget.dart';
import 'card_form_screen.dart';

class CardDetailScreen extends ConsumerWidget {
  final String cardId;

  const CardDetailScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsProvider).value ?? [];
    final cardIndex = cards.indexWhere((c) => c.id == cardId);

    if (cardIndex < 0) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Tarjeta no encontrada')),
      );
    }

    final card = cards[cardIndex];
    final cycle = card.isCredit ? BillingCycleEngine.calculateCycle(card: card) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(card.alias.isNotEmpty ? card.alias : card.productName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CardFormScreen(cardToEdit: card)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.darkSurface,
                  title: const Text('¿Eliminar tarjeta?'),
                  content: Text('Se eliminará ${card.alias} de tu billetera.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(cardsProvider.notifier).deleteCard(card.id);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Tarjeta Digital
          DigitalCardWidget(card: card, showCycleDetails: false),
          const SizedBox(height: 16),

          // Desglose de Fechas Financieras (si es crédito)
          if (cycle != null) ...[
            Container(
              padding: const EdgeInsets.all(18),
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
                      const Text(
                        'CICLO DE FACTURACIÓN',
                        style: TextStyle(
                          color: AppColors.brandPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          cycle.confidence.label,
                          style: const TextStyle(color: AppColors.textMediumDark, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Fechas de Corte y Pago
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateBox(
                          title: 'Próximo Corte',
                          date: cycle.closingDate,
                          subtitle: 'Faltan ${cycle.daysUntilCutoff} días',
                          color: AppColors.brandSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateBox(
                          title: 'Límite de Pago',
                          date: cycle.paymentDueDate,
                          subtitle: 'Faltan ${cycle.daysUntilPaymentDue} días',
                          color: AppColors.brandGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Explicación financiera del motor
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.brandPrimary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            cycle.explanation,
                            style: const TextStyle(color: AppColors.textMediumDark, fontSize: 13, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Beneficios Registrados
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BENEFICIOS Y CASHBACK',
                  style: TextStyle(
                    color: AppColors.textSubtleDark,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                if (card.benefits.isEmpty)
                  const Text(
                    'No hay beneficios ni cashback configurados.',
                    style: TextStyle(color: AppColors.textMediumDark, fontSize: 13),
                  )
                else
                  ...card.benefits.map((b) {
                    final icon = AppConstants.getCategoryIcon(b.category);
                    final catLabel = AppConstants.getCategoryLabel(b.category);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.darkSurfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(icon, style: const TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$catLabel (${b.rewardRate.toStringAsFixed(1)}%)',
                                  style: const TextStyle(
                                    color: AppColors.textHighDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (b.terms.isNotEmpty)
                                  Text(
                                    b.terms,
                                    style: const TextStyle(color: AppColors.textSubtleDark, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          if (b.rewardCapCents > 0)
                            Text(
                              'Tope: ${MoneyFormatter.formatCents(b.rewardCapCents)}',
                              style: const TextStyle(color: AppColors.brandGold, fontSize: 11),
                            ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Botón para registrar compra directa
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PurchaseFormScreen(preselectedCardId: card.id),
                ),
              );
            },
            icon: const Icon(Icons.add_shopping_cart, size: 18),
            label: const Text('Registrar Compra con esta Tarjeta'),
          ),
          const SizedBox(height: 10),

          // Alternar Pausar / Activar
          OutlinedButton.icon(
            onPressed: () {
              ref.read(cardsProvider.notifier).toggleCardStatus(card.id);
            },
            icon: Icon(card.status == 'active' ? Icons.pause_circle_outline : Icons.play_circle_outline, size: 18),
            label: Text(card.status == 'active' ? 'Pausar Tarjeta' : 'Reactivar Tarjeta'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDateBox({
    required String title,
    required DateTime date,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            DateFormatter.formatShort(date),
            style: const TextStyle(
              color: AppColors.textHighDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: AppColors.textSubtleDark, fontSize: 11)),
        ],
      ),
    );
  }
}
