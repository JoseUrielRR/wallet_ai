import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../providers/purchases_provider.dart';
import '../widgets/purchase_tile.dart';
import 'purchase_form_screen.dart';

class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final purchasesAsync = ref.watch(purchasesProvider);
    final purchases = purchasesAsync.value ?? [];

    final filteredPurchases = _selectedCategory == 'all'
        ? purchases
        : purchases.where((p) => p.category == _selectedCategory).toList();

    final totalSpent = purchases.fold<int>(0, (sum, p) => sum + p.amountCents);
    final totalReward = purchases.fold<int>(0, (sum, p) => sum + p.estimatedRewardCents);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividad y Compras', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Resumen de Gastos y Cashback
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Registrado', style: TextStyle(color: AppColors.textMediumDark, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      MoneyFormatter.formatCents(totalSpent),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHighDark,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Cashback Acumulado', style: TextStyle(color: AppColors.textMediumDark, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '+${MoneyFormatter.formatCents(totalReward)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filtro por Categorías
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todas'),
                  selected: _selectedCategory == 'all',
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = 'all');
                  },
                ),
                const SizedBox(width: 8),
                ...AppConstants.purchaseCategories.map((c) {
                  final isSelected = _selectedCategory == c;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${AppConstants.getCategoryIcon(c)} ${AppConstants.getCategoryLabel(c)}'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = c);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Lista de Compras
          Expanded(
            child: filteredPurchases.isEmpty
                ? const Center(
                    child: Text(
                      'No hay compras registradas en esta categoría.',
                      style: TextStyle(color: AppColors.textSubtleDark),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filteredPurchases.length,
                    itemBuilder: (context, index) {
                      return PurchaseTile(purchase: filteredPurchases[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PurchaseFormScreen()),
          );
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Nueva Compra'),
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.black,
      ),
    );
  }
}
