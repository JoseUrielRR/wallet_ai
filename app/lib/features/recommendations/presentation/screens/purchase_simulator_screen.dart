import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../purchases/presentation/screens/purchase_form_screen.dart';
import '../providers/recommendation_provider.dart';

class PurchaseSimulatorScreen extends ConsumerStatefulWidget {
  const PurchaseSimulatorScreen({super.key});

  @override
  ConsumerState<PurchaseSimulatorScreen> createState() => _PurchaseSimulatorScreenState();
}

class _PurchaseSimulatorScreenState extends ConsumerState<PurchaseSimulatorScreen> {
  final TextEditingController _amountController = TextEditingController(text: '1500.00');
  String _selectedCategory = 'supermarket';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amountDouble = double.tryParse(_amountController.text) ?? 1500.0;
    final amountCents = MoneyFormatter.toCents(amountDouble);

    final recommendation = ref.watch(
      simulationRecommendationProvider(
        SimulationParams(
          amountCents: amountCents,
          category: _selectedCategory,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador de Compra Inteligente'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Input de Monto de la compra
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿CUÁNTO VAS A PAGAR?',
                  style: TextStyle(
                    color: AppColors.textSubtleDark,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.brandPrimary),
                  decoration: const InputDecoration(
                    prefixText: '\$ ',
                    suffixText: 'MXN',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Selector de Categoría
          const Text(
            'Categoría del Gasto:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppConstants.purchaseCategories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('${AppConstants.getCategoryIcon(cat)} ${AppConstants.getCategoryLabel(cat)}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                    selectedColor: AppColors.brandPrimary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.brandPrimary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.brandPrimary : AppColors.textMediumDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Resultados de la Simulación
          if (!recommendation.hasRecommendation)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No hay tarjetas activas registradas para comparar.'),
              ),
            )
          else ...[
            // Ganador Destacado
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF143022), Color(0xFF161B22)],
                ),
                border: Border.all(color: AppColors.brandPrimary, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.brandPrimary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '🥇 MEJOR TARJETA',
                          style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '+${MoneyFormatter.formatCents(recommendation.winner!.cashbackResult.rewardCents)} cashback',
                        style: const TextStyle(
                          color: AppColors.brandPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    recommendation.winner!.card.alias.isNotEmpty
                        ? recommendation.winner!.card.alias
                        : recommendation.winner!.card.productName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textHighDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recommendation.winner!.cashbackResult.explanation,
                    style: const TextStyle(color: AppColors.textMediumDark, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Chip(
                        label: Text('${recommendation.winner!.cycleResult.financingDaysAvailable} días para pagar'),
                        backgroundColor: AppColors.darkSurfaceElevated,
                        labelStyle: const TextStyle(fontSize: 11, color: AppColors.textHighDark),
                      ),
                      Chip(
                        label: Text('Pagas el ${DateFormatter.formatShort(recommendation.winner!.cycleResult.paymentDueDate)}'),
                        backgroundColor: AppColors.darkSurfaceElevated,
                        labelStyle: const TextStyle(fontSize: 11, color: AppColors.textHighDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PurchaseFormScreen(
                            preselectedCardId: recommendation.winner!.card.id,
                            prefilledAmount: amountDouble,
                            preselectedCategory: _selectedCategory,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Registrar esta Compra'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Ranking de Alternativas
            if (recommendation.alternatives.isNotEmpty) ...[
              const Text(
                'Otras opciones disponibles:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              ...recommendation.alternatives.map((alt) {
                final card = alt.card;
                final cashback = alt.cashbackResult;
                final cycle = alt.cycleResult;

                return Card(
                  color: AppColors.darkSurface,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              card.alias.isNotEmpty ? card.alias : card.productName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              cashback.rewardCents > 0
                                  ? '+${MoneyFormatter.formatCents(cashback.rewardCents)}'
                                  : '0% cashback',
                              style: TextStyle(
                                color: cashback.rewardCents > 0 ? AppColors.brandPrimary : AppColors.textSubtleDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${cycle.financingDaysAvailable} días de financiamiento libre (Vence: ${DateFormatter.formatShort(cycle.paymentDueDate)})',
                          style: const TextStyle(color: AppColors.textMediumDark, fontSize: 12),
                        ),
                        if (alt.warnings.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber, size: 14, color: AppColors.warning),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    alt.warnings.first,
                                    style: const TextStyle(color: AppColors.warning, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
