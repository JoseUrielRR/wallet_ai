import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/models/loan.dart';
import '../providers/loans_provider.dart';

class LoanFormScreen extends ConsumerStatefulWidget {
  final Loan? loanToEdit;

  const LoanFormScreen({super.key, this.loanToEdit});

  @override
  ConsumerState<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends ConsumerState<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _lenderController;
  late TextEditingController _originalAmountController;
  late TextEditingController _balanceController;
  late TextEditingController _rateController;
  late TextEditingController _paymentAmountController;
  late TextEditingController _notesController;

  String _frequency = 'monthly';
  DateTime _nextPaymentDate = DateTime.now().add(const Duration(days: 15));

  @override
  void initState() {
    super.initState();
    final edit = widget.loanToEdit;
    _nameController = TextEditingController(text: edit?.name ?? '');
    _lenderController = TextEditingController(text: edit?.lender ?? '');
    _originalAmountController = TextEditingController(
      text: edit != null ? MoneyFormatter.toDouble(edit.originalAmountCents).toStringAsFixed(2) : '30000.00',
    );
    _balanceController = TextEditingController(
      text: edit != null ? MoneyFormatter.toDouble(edit.outstandingBalanceCents).toStringAsFixed(2) : '30000.00',
    );
    _rateController = TextEditingController(
      text: edit != null ? edit.interestRateAnnual.toStringAsFixed(1) : '16.0',
    );
    _paymentAmountController = TextEditingController(
      text: edit != null ? MoneyFormatter.toDouble(edit.paymentAmountCents).toStringAsFixed(2) : '1500.00',
    );
    _notesController = TextEditingController(text: edit?.notes ?? '');

    if (edit != null) {
      _frequency = edit.paymentFrequency;
      _nextPaymentDate = edit.nextPaymentDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lenderController.dispose();
    _originalAmountController.dispose();
    _balanceController.dispose();
    _rateController.dispose();
    _paymentAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveLoan() {
    if (!_formKey.currentState!.validate()) return;

    final origDouble = double.tryParse(_originalAmountController.text) ?? 0.0;
    final balanceDouble = double.tryParse(_balanceController.text) ?? 0.0;
    final paymentDouble = double.tryParse(_paymentAmountController.text) ?? 0.0;
    final rateDouble = double.tryParse(_rateController.text) ?? 0.0;

    final loan = Loan(
      id: widget.loanToEdit?.id ?? const Uuid().v4(),
      userId: widget.loanToEdit?.userId ?? 'usr_demo',
      name: _nameController.text.trim(),
      lender: _lenderController.text.trim(),
      originalAmountCents: MoneyFormatter.toCents(origDouble),
      outstandingBalanceCents: MoneyFormatter.toCents(balanceDouble),
      interestRateAnnual: rateDouble,
      paymentAmountCents: MoneyFormatter.toCents(paymentDouble),
      paymentFrequency: _frequency,
      nextPaymentDate: _nextPaymentDate,
      status: balanceDouble <= 0 ? 'paid_off' : 'active',
      notes: _notesController.text.trim(),
      createdAt: widget.loanToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(loansProvider.notifier).saveLoan(loan);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.loanToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Préstamo' : 'Registrar Préstamo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nombre del préstamo
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Préstamo *',
                hintText: 'Ej. Crédito Automotriz, Préstamo Personal',
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el nombre' : null,
            ),
            const SizedBox(height: 14),

            // Institución prestamista
            TextFormField(
              controller: _lenderController,
              decoration: const InputDecoration(
                labelText: 'Institución o Prestamista *',
                hintText: 'Ej. Banco Aurora, Financiera',
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa la institución' : null,
            ),
            const SizedBox(height: 14),

            // Monto Original y Saldo Pendiente
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _originalAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monto Original *',
                      prefixText: '\$ ',
                    ),
                    validator: (v) {
                      final val = double.tryParse(v ?? '');
                      if (val == null || val <= 0) return 'Monto inválido';
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
                      labelText: 'Saldo Insoluto *',
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
            const SizedBox(height: 14),

            // Cuota y Tasa de Interés
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _paymentAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monto de la Cuota *',
                      prefixText: '\$ ',
                    ),
                    validator: (v) {
                      final val = double.tryParse(v ?? '');
                      if (val == null || val <= 0) return 'Cuota inválida';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Tasa Anual (%)',
                      suffixText: '%',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Frecuencia
            DropdownButtonFormField<String>(
              initialValue: _frequency,
              decoration: const InputDecoration(labelText: 'Frecuencia de Pago'),
              dropdownColor: AppColors.darkSurfaceElevated,
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('Mensual')),
                DropdownMenuItem(value: 'biweekly', child: Text('Quincenal')),
                DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _frequency = val);
              },
            ),
            const SizedBox(height: 14),

            // Próxima Fecha de Pago
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Próxima Fecha de Pago', style: TextStyle(fontSize: 14)),
              subtitle: Text(
                DateFormatter.formatFull(_nextPaymentDate),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textHighDark),
              ),
              trailing: const Icon(Icons.calendar_month, color: AppColors.brandPrimary),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _nextPaymentDate,
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  setState(() => _nextPaymentDate = picked);
                }
              },
            ),
            const SizedBox(height: 14),

            // Notas
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas Adicionales',
                hintText: 'Condiciones de pago anticipado o referencias',
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveLoan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEditing ? 'Actualizar Préstamo' : 'Guardar Préstamo'),
            ),
          ],
        ),
      ),
    );
  }
}
