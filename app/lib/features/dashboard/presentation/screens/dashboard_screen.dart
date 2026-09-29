import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../cards/presentation/screens/card_detail_screen.dart';
import '../../../cards/presentation/screens/card_form_screen.dart';
import '../../../cards/presentation/widgets/digital_card_widget.dart';
import '../../../purchases/presentation/providers/purchases_provider.dart';
import '../../../purchases/presentation/screens/purchase_form_screen.dart';
import '../../../purchases/presentation/widgets/purchase_tile.dart';
import '../../../recommendations/presentation/providers/recommendation_provider.dart';
import '../../../recommendations/presentation/screens/card_comparison_screen.dart';
import '../../../recommendations/presentation/screens/purchase_simulator_screen.dart';
import '../../../recommendations/presentation/widgets/hero_recommendation_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsProvider);
    final purchasesAsync = ref.watch(purchasesProvider);
    final dailyRecommendation = ref.watch(dailyRecommendationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wallet AI',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              DateFormatter.formatFull(DateTime.now()),
              style: const TextStyle(
                color: AppColors.textMediumDark,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.offline_pin_outlined, color: AppColors.brandPrimary, size: 14),
                SizedBox(width: 4),
                Text(
                  'Modo Demo Local',
                  style: TextStyle(color: AppColors.brandPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(cardsProvider);
          ref.invalidate(purchasesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Hero Card: Recomendación del Día
            HeroRecommendationCard(
              recommendation: dailyRecommendation,
              onSimulateTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PurchaseSimulatorScreen()),
                );
              },
              onCompareTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CardComparisonScreen()),
                );
              },
            ),

            const SizedBox(height: 24),

            // 2. Métricas Consolidadas de Liquidez
            cardsAsync.when(
              data: (cards) {
                final creditCards = cards.where((c) => c.isCredit && c.isActive).toList();
                final totalLimit = creditCards.fold<int>(0, (sum, c) => sum + c.creditLimitCents);
                final totalBalance = creditCards.fold<int>(0, (sum, c) => sum + c.currentBalanceCents);
                final totalAvailable = creditCards.fold<int>(0, (sum, c) => sum + c.calculatedAvailableCreditCents);
                final globalRatio = totalLimit > 0 ? (totalBalance / totalLimit) : 0.0;

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LÍNEA DE CRÉDITO GLOBAL',
                        style: TextStyle(
                          color: AppColors.textSubtleDark,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Disponible Total', style: TextStyle(color: AppColors.textMediumDark, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                MoneyFormatter.formatCents(totalAvailable),
                                style: const TextStyle(
                                  color: AppColors.brandPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Saldo Utilizado', style: TextStyle(color: AppColors.textMediumDark, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                MoneyFormatter.formatCents(totalBalance),
                                style: const TextStyle(
                                  color: AppColors.textHighDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: globalRatio.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: AppColors.darkSurfaceElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            globalRatio > 0.70 ? AppColors.warning : AppColors.brandPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Utilización: ${(globalRatio * 100).round()}%',
                            style: TextStyle(
                              color: globalRatio > 0.70 ? AppColors.warning : AppColors.textMediumDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Límite global: ${MoneyFormatter.formatCents(totalLimit)}',
                            style: const TextStyle(color: AppColors.textSubtleDark, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error al cargar métricas: $e'),
            ),

            const SizedBox(height: 24),

            // 3. Carrusel / Lista de Tarjetas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis Tarjetas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHighDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CardFormScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            cardsAsync.when(
              data: (cards) {
                if (cards.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.credit_card_off_outlined, color: AppColors.textSubtleDark, size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          'No tienes tarjetas registradas',
                          style: TextStyle(color: AppColors.textHighDark, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Agrega tu primera tarjeta o activa el set de demostración.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMediumDark, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(cardsProvider.notifier).resetToDemo();
                          },
                          child: const Text('Cargar Tarjetas Demo'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: cards.map((card) {
                    return DigitalCardWidget(
                      card: card,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CardDetailScreen(cardId: card.id),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error al cargar tarjetas: $e'),
            ),

            const SizedBox(height: 24),

            // 4. Actividad Reciente
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Actividad Reciente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHighDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PurchaseFormScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Registrar Compra'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            purchasesAsync.when(
              data: (purchases) {
                if (purchases.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No hay compras registradas aún.',
                        style: TextStyle(color: AppColors.textSubtleDark),
                      ),
                    ),
                  );
                }

                final recent = purchases.take(4).toList();
                return Column(
                  children: recent.map((p) => PurchaseTile(purchase: p)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error al cargar actividad: $e'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
