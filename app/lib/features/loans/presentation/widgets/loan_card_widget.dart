import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/models/loan.dart';

class LoanCardWidget extends StatelessWidget {
  final Loan loan;
  final VoidCallback onPayTap;

  const LoanCardWidget({
    super.key,
    required this.loan,
    required this.onPayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loan.name,
                    style: const TextStyle(
                      color: AppColors.textHighDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    loan.lender,
                    style: const TextStyle(
                      color: AppColors.textMediumDark,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: loan.status == 'paid_off'
                      ? AppColors.brandPrimary.withValues(alpha: 0.2)
                      : AppColors.brandPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  loan.status == 'paid_off' ? 'LIQUIDADO' : 'ACTIVO',
                  style: TextStyle(
                    color: loan.status == 'paid_off' ? AppColors.brandPrimary : AppColors.brandPurple,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Balances
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo insoluto',
                    style: TextStyle(color: AppColors.textSubtleDark, fontSize: 11),
                  ),
                  Text(
                    MoneyFormatter.formatCents(loan.outstandingBalanceCents),
                    style: const TextStyle(
                      color: AppColors.textHighDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Próxima cuota',
                    style: TextStyle(color: AppColors.textSubtleDark, fontSize: 11),
                  ),
                  Text(
                    MoneyFormatter.formatCents(loan.paymentAmountCents),
                    style: const TextStyle(
                      color: AppColors.brandGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Barra de amortización
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: loan.progressPercentage,
                    minHeight: 6,
                    backgroundColor: AppColors.darkSurfaceElevated,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(loan.progressPercentage * 100).round()}% pagado',
                style: const TextStyle(
                  color: AppColors.textMediumDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Vencimiento y acción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vence: ${DateFormatter.formatShort(loan.nextPaymentDate)}',
                style: const TextStyle(color: AppColors.textSubtleDark, fontSize: 12),
              ),
              if (loan.status != 'paid_off')
                OutlinedButton.icon(
                  onPressed: onPayTap,
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Registrar Pago'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
