import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../engine/domain/billing_cycle_engine.dart';
import '../../../engine/domain/cashback_calculator.dart';
import '../../domain/models/purchase.dart';
import '../providers/purchases_provider.dart';

class PurchaseFormScreen extends ConsumerStatefulWidget {
  final String? preselectedCardId;
  final double? prefilledAmount;
  final String? preselectedCategory;

  const PurchaseFormScreen({
    super.key,
    this.preselectedCardId,
    this.prefilledAmount,
    this.preselectedCategory,
  });

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  late TextEditingController _descriptionController;

  String? _selectedCardId;
  late String _selectedCategory;
  DateTime _purchaseDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.prefilledAmount != null ? widget.prefilledAmount!.toStringAsFixed(2) : '500.00',
    );
    _merchantController = TextEditingController();
    _descriptionController = TextEditingController();
    _selectedCardId = widget.preselectedCardId;
    _selectedCategory = widget.preselectedCategory ?? 'supermarket';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _savePurchase() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una tarjeta para registrar la compra.')),
      );
      return;
    }

    final cards = ref.read(cardsProvider).value ?? [];
    final card = cards.firstWhere((c) => c.id == _selectedCardId);

    final amountDouble = double.tryParse(_amountController.text) ?? 0.0;
    final amountCents = MoneyFormatter.toCents(amountDouble);

    // Calcular cashback exacto
    final cashbackResult = CashbackCalculator.calculateReward(
      card: card,
      amountCents: amountCents,
      category: _selectedCategory,
      purchaseDate: _purchaseDate,
    );

    // Determinar ciclo de facturación
    final cycleResult = BillingCycleEngine.calculateCycle(
      card: card,
      referenceDate: _purchaseDate,
    );
    final cycleId = 'cycle_${DateFormatter.formatIso(cycleResult.closingDate)}_${card.id}';

    final purchase = Purchase(
      id: const Uuid().v4(),
      userId: card.userId,
      cardId: card.id,
      cardAlias: card.alias.isNotEmpty ? card.alias : card.productName,
      amountCents: amountCents,
      currency: card.currency,
      category: _selectedCategory,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : AppConstants.getCategoryLabel(_selectedCategory),
      merchant: _merchantController.text.trim(),
      purchaseDate: _purchaseDate,
      billingCycleId: cycleId,
      estimatedRewardCents: cashbackResult.rewardCents,
      status: 'recorded',
      createdAt: DateTime.now(),
    );

    ref.read(purchasesProvider.notifier).savePurchase(purchase);

    // Actualizar saldo de la tarjeta si es crédito
    if (card.isCredit) {
      final newBalance = card.currentBalanceCents + amountCents;
      final newAvailable = card.creditLimitCents - newBalance;
      ref.read(cardsProvider.notifier).saveCard(
            card.copyWith(
              currentBalanceCents: newBalance,
              availableCreditCents: newAvailable < 0 ? 0 : newAvailable,
            ),
          );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardsProvider).value ?? [];
    if (_selectedCardId == null && cards.isNotEmpty) {
      _selectedCardId = cards.first.id;
    }

    final selectedCard = cards.where((c) => c.id == _selectedCardId).firstOrNull;
    final amountDouble = double.tryParse(_amountController.text) ?? 0.0;
    final amountCents = MoneyFormatter.toCents(amountDouble);

    CashbackCalculationResult? previewCashback;
    if (selectedCard != null && amountCents > 0) {
      previewCashback = CashbackCalculator.calculateReward(
        card: selectedCard,
        amountCents: amountCents,
        category: _selectedCategory,
        purchaseDate: _purchaseDate,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Compra'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Selector de Tarjeta
            DropdownButtonFormField<String>(
              initialValue: _selectedCardId,
              decoration: const InputDecoration(labelText: 'Tarjeta Utilizada *'),
              dropdownColor: AppColors.darkSurfaceElevated,
              items: cards.map((c) {
                return DropdownMenuItem(
                  value: c.id,
                  child: Text('${c.alias.isNotEmpty ? c.alias : c.productName} (${c.issuerName})'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCardId = val),
            ),
            const SizedBox(height: 16),

            // Importe de Compra
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.brandPrimary),
              decoration: const InputDecoration(
                labelText: 'Monto de la Compra *',
                prefixText: '\$ ',
                suffixText: 'MXN',
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final val = double.tryParse(v ?? '');
                if (val == null || val <= 0) return 'Ingresa un monto válido mayor a 0';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Categoría
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Categoría de Compra *'),
              dropdownColor: AppColors.darkSurfaceElevated,
              items: AppConstants.purchaseCategories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text('${AppConstants.getCategoryIcon(cat)} ${AppConstants.getCategoryLabel(cat)}'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),

            // Comercio
            TextFormField(
              controller: _merchantController,
              decoration: const InputDecoration(
                labelText: 'Comercio o Establecimiento',
                hintText: 'Ej. Walmart, Gasolinera Shell, Amazon',
              ),
            ),
            const SizedBox(height: 16),

            // Notas
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Notas o Descripción',
                hintText: 'Ej. Despensa semanal',
              ),
            ),
            const SizedBox(height: 16),

            // Fecha de Compra
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha de la Compra', style: TextStyle(fontSize: 14)),
              subtitle: Text(
                DateFormatter.formatFull(_purchaseDate),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textHighDark),
              ),
              trailing: const Icon(Icons.calendar_month, color: AppColors.brandPrimary),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _purchaseDate,
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2028),
                );
                if (picked != null) {
                  setState(() => _purchaseDate = picked);
                }
              },
            ),
            const SizedBox(height: 16),

            // Previsualización de Recompensa
            if (previewCashback != null && previewCashback.rewardCents > 0)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.savings_outlined, color: AppColors.brandPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Generas ${MoneyFormatter.formatCents(previewCashback.rewardCents)} de cashback (${previewCashback.effectiveRate}%)',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandPrimary),
                          ),
                          Text(
                            previewCashback.explanation,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMediumDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _savePurchase,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Guardar Compra'),
            ),
          ],
        ),
      ),
    );
  }
}
