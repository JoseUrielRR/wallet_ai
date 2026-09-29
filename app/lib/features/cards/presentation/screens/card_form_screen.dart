import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/models/benefit.dart';
import '../../domain/models/user_card.dart';
import '../providers/cards_provider.dart';

class CardFormScreen extends ConsumerStatefulWidget {
  final UserCard? cardToEdit;

  const CardFormScreen({super.key, this.cardToEdit});

  @override
  ConsumerState<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends ConsumerState<CardFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _issuerController;
  late TextEditingController _productController;
  late TextEditingController _aliasController;
  late TextEditingController _last4Controller;
  late TextEditingController _limitController;
  late TextEditingController _balanceController;
  late TextEditingController _notesController;

  String _type = 'credit';
  int _closingDay = 15;
  int _paymentDay = 5;
  String _selectedColor = '#388BFD';
  List<Benefit> _benefits = [];

  final List<String> _colorOptions = [
    '#8A05BE', // Morado
    '#388BFD', // Azul
    '#00D26A', // Verde
    '#D29922', // Oro
    '#F85149', // Coral
    '#484F58', // Grafito
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.cardToEdit;
    _issuerController = TextEditingController(text: edit?.issuerName ?? '');
    _productController = TextEditingController(text: edit?.productName ?? '');
    _aliasController = TextEditingController(text: edit?.alias ?? '');
    _last4Controller = TextEditingController(text: edit?.last4 ?? '');
    _limitController = TextEditingController(
      text: edit != null ? MoneyFormatter.toDouble(edit.creditLimitCents).toStringAsFixed(2) : '20000.00',
    );
    _balanceController = TextEditingController(
      text: edit != null ? MoneyFormatter.toDouble(edit.currentBalanceCents).toStringAsFixed(2) : '0.00',
    );
    _notesController = TextEditingController(text: edit?.notes ?? '');

    if (edit != null) {
      _type = edit.type;
      _closingDay = edit.statementClosingDay;
      _paymentDay = edit.paymentDueDay;
      _selectedColor = edit.colorHex;
      _benefits = List.from(edit.benefits);
    } else {
      _benefits = [
        const Benefit(
          id: 'ben_default_all',
          category: 'all',
          rewardType: 'cashback',
          rewardRate: 1.0,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _issuerController.dispose();
    _productController.dispose();
    _aliasController.dispose();
    _last4Controller.dispose();
    _limitController.dispose();
    _balanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveCard() {
    if (!_formKey.currentState!.validate()) return;

    final limitDouble = double.tryParse(_limitController.text) ?? 0.0;
    final balanceDouble = double.tryParse(_balanceController.text) ?? 0.0;

    final limitCents = MoneyFormatter.toCents(limitDouble);
    final balanceCents = MoneyFormatter.toCents(balanceDouble);
    final availableCents = limitCents - balanceCents;

    final newCard = UserCard(
      id: widget.cardToEdit?.id ?? const Uuid().v4(),
      userId: widget.cardToEdit?.userId ?? 'usr_demo',
      issuerId: widget.cardToEdit?.issuerId ?? 'iss_custom',
      issuerName: _issuerController.text.trim(),
      productName: _productController.text.trim(),
      alias: _aliasController.text.trim(),
      type: _type,
      last4: _last4Controller.text.trim(),
      currency: 'MXN',
      creditLimitCents: _type == 'credit' ? limitCents : 0,
      currentBalanceCents: _type == 'credit' ? balanceCents : 0,
      availableCreditCents: _type == 'credit' ? (availableCents < 0 ? 0 : availableCents) : limitCents,
      statementClosingDay: _closingDay,
      paymentDueDay: _paymentDay,
      colorHex: _selectedColor,
      benefits: _benefits,
      notes: _notesController.text.trim(),
      createdAt: widget.cardToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(cardsProvider.notifier).saveCard(newCard);
    Navigator.of(context).pop();
  }

  void _showAddBenefitDialog() {
    String category = 'supermarket';
    final rateController = TextEditingController(text: '3.0');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: const Text('Agregar Beneficio de Cashback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Categoría'),
                dropdownColor: AppColors.darkSurfaceElevated,
                items: AppConstants.purchaseCategories.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text('${AppConstants.getCategoryIcon(c)} ${AppConstants.getCategoryLabel(c)}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => category = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: rateController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Porcentaje de Recompensa (%)',
                  hintText: '3.0',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final rate = double.tryParse(rateController.text) ?? 0.0;
                if (rate > 0) {
                  setState(() {
                    _benefits.add(
                      Benefit(
                        id: const Uuid().v4(),
                        category: category,
                        rewardType: 'cashback',
                        rewardRate: rate,
                      ),
                    );
                  });
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cardToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarjeta' : 'Registrar Tarjeta'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipo de Tarjeta
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'credit', label: Text('Crédito')),
                ButtonSegment(value: 'debit', label: Text('Débito')),
              ],
              selected: {_type},
              onSelectionChanged: (set) {
                setState(() {
                  _type = set.first;
                });
              },
            ),
            const SizedBox(height: 16),

            // Banco o Institución
            TextFormField(
              controller: _issuerController,
              decoration: const InputDecoration(
                labelText: 'Banco o Institución Emisora *',
                hintText: 'Ej. Nu, BBVA, Santander',
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el banco emisor' : null,
            ),
            const SizedBox(height: 12),

            // Nombre del Producto y Alias
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _productController,
                    decoration: const InputDecoration(
                      labelText: 'Producto *',
                      hintText: 'Ej. Oro, Clásica',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el producto' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _aliasController,
                    decoration: const InputDecoration(
                      labelText: 'Alias Personal',
                      hintText: 'Ej. Mi Moradita',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Últimos 4 dígitos
            TextFormField(
              controller: _last4Controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Últimos 4 dígitos (Opcional)',
                hintText: '1234',
                helperText: 'Solo para identificar físicamente tu tarjeta. Nunca solicitamos PAN completo ni CVV.',
              ),
            ),
            const SizedBox(height: 12),

            // Límite de Crédito y Saldo (si es crédito)
            if (_type == 'credit') ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _limitController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Límite de Crédito *',
                        prefixText: '\$ ',
                      ),
                      validator: (v) {
                        final val = double.tryParse(v ?? '');
                        if (val == null || val < 0) return 'Monto inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _balanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Saldo Utilizado *',
                        prefixText: '\$ ',
                      ),
                      validator: (v) {
                        final val = double.tryParse(v ?? '');
                        if (val == null || val < 0) return 'Monto inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Días de Corte y Pago
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fechas del Ciclo Financiero',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Día de Corte: $_closingDay', style: const TextStyle(fontWeight: FontWeight.w600)),
                              Slider(
                                value: _closingDay.toDouble(),
                                min: 1,
                                max: 31,
                                divisions: 30,
                                onChanged: (v) => setState(() => _closingDay = v.round()),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Día de Pago: $_paymentDay', style: const TextStyle(fontWeight: FontWeight.w600)),
                              Slider(
                                value: _paymentDay.toDouble(),
                                min: 1,
                                max: 31,
                                divisions: 30,
                                onChanged: (v) => setState(() => _paymentDay = v.round()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Selector de Color
            const Text('Color de la Tarjeta:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: _colorOptions.map((hex) {
                final isSelected = _selectedColor == hex;
                final color = Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Beneficios
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Beneficios y Recompensas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                TextButton.icon(
                  onPressed: _showAddBenefitDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Agregar Beneficio'),
                ),
              ],
            ),
            ..._benefits.map((b) {
              return Card(
                color: AppColors.darkSurfaceElevated,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  dense: true,
                  leading: Text(AppConstants.getCategoryIcon(b.category), style: const TextStyle(fontSize: 18)),
                  title: Text('${AppConstants.getCategoryLabel(b.category)} • ${b.rewardRate}% cashback'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                    onPressed: () {
                      setState(() {
                        _benefits.removeWhere((item) => item.id == b.id);
                      });
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveCard,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEditing ? 'Actualizar Tarjeta' : 'Guardar Tarjeta'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
