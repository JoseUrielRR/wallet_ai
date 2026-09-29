import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../loans/presentation/providers/loans_provider.dart';
import '../../../loans/presentation/screens/loan_form_screen.dart';
import '../../../loans/presentation/widgets/loan_card_widget.dart';
import '../providers/cards_provider.dart';
import '../widgets/digital_card_widget.dart';
import 'card_detail_screen.dart';
import 'card_form_screen.dart';

class CardsScreen extends ConsumerStatefulWidget {
  const CardsScreen({super.key});

  @override
  ConsumerState<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends ConsumerState<CardsScreen> {
  int _selectedSegment = 0; // 0 = Tarjetas, 1 = Préstamos
  String _cardTypeFilter = 'all'; // 'all', 'credit', 'debit'

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(cardsProvider);
    final loansAsync = ref.watch(loansProvider);

    final cards = cardsAsync.value ?? [];
    final loans = loansAsync.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billetera', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restablecer datos demo',
            onPressed: () {
              ref.read(cardsProvider.notifier).resetToDemo();
              ref.read(loansProvider.notifier).resetToDemo();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Billetera restaurada con datos demo.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector Segmentado: Tarjetas vs Préstamos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 0,
                  label: Text('Tarjetas (${cards.length})'),
                  icon: const Icon(Icons.credit_card),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Préstamos (${loans.length})'),
                  icon: const Icon(Icons.account_balance),
                ),
              ],
              selected: {_selectedSegment},
              onSelectionChanged: (set) {
                setState(() {
                  _selectedSegment = set.first;
                });
              },
            ),
          ),

          Expanded(
            child: _selectedSegment == 0
                ? _buildCardsView(cards)
                : _buildLoansView(loans),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_selectedSegment == 0) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CardFormScreen()),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoanFormScreen()),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_selectedSegment == 0 ? 'Nueva Tarjeta' : 'Nuevo Préstamo'),
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildCardsView(List cards) {
    var filteredCards = cards;
    if (_cardTypeFilter == 'credit') {
      filteredCards = cards.where((c) => c.isCredit).toList();
    } else if (_cardTypeFilter == 'debit') {
      filteredCards = cards.where((c) => c.isDebit).toList();
    }

    return Column(
      children: [
        // Filtro rápido tipo de tarjeta
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _buildFilterChip('Todas', 'all'),
              const SizedBox(width: 8),
              _buildFilterChip('Crédito', 'credit'),
              const SizedBox(width: 8),
              _buildFilterChip('Débito', 'debit'),
            ],
          ),
        ),
        const SizedBox(height: 4),

        Expanded(
          child: filteredCards.isEmpty
              ? const Center(
                  child: Text(
                    'No hay tarjetas en esta categoría.',
                    style: TextStyle(color: AppColors.textSubtleDark),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: filteredCards.length,
                  itemBuilder: (context, index) {
                    final card = filteredCards[index];
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
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _cardTypeFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _cardTypeFilter = value;
          });
        }
      },
      selectedColor: AppColors.brandPrimary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.brandPrimary : AppColors.textMediumDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildLoansView(List loans) {
    if (loans.isEmpty) {
      return const Center(
        child: Text(
          'No tienes préstamos registrados.',
          style: TextStyle(color: AppColors.textSubtleDark),
        ),
      );
    }

    final totalOutstanding = loans.fold<int>(
      0,
      (sum, l) => sum + (l.status == 'active' ? (l.outstandingBalanceCents as int) : 0),
    );

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Resumen de Deuda Total
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deuda Total Pendiente', style: TextStyle(color: AppColors.textMediumDark, fontSize: 12)),
                  Text('Obligaciones activas', style: TextStyle(color: AppColors.textSubtleDark, fontSize: 11)),
                ],
              ),
              Text(
                MoneyFormatter.formatCents(totalOutstanding),
                style: const TextStyle(
                  color: AppColors.brandGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        ...loans.map((loan) {
          return LoanCardWidget(
            loan: loan,
            onPayTap: () {
              ref.read(loansProvider.notifier).recordPayment(loan.id, loan.paymentAmountCents);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Se registró el pago de ${MoneyFormatter.formatCents(loan.paymentAmountCents)} para ${loan.name}.'),
                ),
              );
            },
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }
}
