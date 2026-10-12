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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final purchasesAsync = ref.watch(purchasesProvider);
    final purchases = purchasesAsync.value ?? [];

    final filteredPurchases = _selectedCategory == 'all'
        ? purchases
        : purchases.where((p) => p.category == _selectedCategory).toList();

    // Ordenar cronológicamente (más recientes primero)
    final sortedPurchases = List.of(filteredPurchases)
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

    final totalSpent = purchases.fold<int>(0, (sum, p) => sum + p.amountCents);
    final totalReward = purchases.fold<int>(0, (sum, p) => sum + p.estimatedRewardCents);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.softBackground,
      appBar: AppBar(
        title: const Text('Actividad y Movimientos', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Resumen de Gastos y Cashback Soft UI
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.softSurface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? AppColors.glassWhite : AppColors.softBorder,
                width: 1,
              ),
              boxShadow: isDark
                  ? null
                  : const [
                      AppColors.softShadow,
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Registrado',
                      style: TextStyle(
                        color: isDark ? AppColors.textMediumDark : AppColors.slate500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      MoneyFormatter.formatCents(totalSpent),
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textHighDark : AppColors.slate900,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Cashback Acumulado',
                      style: TextStyle(
                        color: isDark ? AppColors.textMediumDark : AppColors.slate500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.brandPrimary.withValues(alpha: 0.15)
                            : AppColors.pastelMintBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${MoneyFormatter.formatCents(totalReward)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pastelMintText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filtro por Categorías Soft Pastel
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

          // Lista de Compras Cronológica
          Expanded(
            child: sortedPurchases.isEmpty
                ? Center(
                    child: Text(
                      'No hay compras registradas en esta categoría.',
                      style: TextStyle(
                        color: isDark ? AppColors.textSubtleDark : AppColors.slate400,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: sortedPurchases.length,
                    itemBuilder: (context, index) {
                      return PurchaseTile(purchase: sortedPurchases[index]);
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
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Nueva Compra'),
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }
}
