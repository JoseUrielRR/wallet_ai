import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/models/purchase.dart';

class PurchaseTile extends StatelessWidget {
  final Purchase purchase;
  final VoidCallback? onDelete;

  const PurchaseTile({
    super.key,
    required this.purchase,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final icon = AppConstants.getCategoryIcon(purchase.category);
    final formattedAmount = MoneyFormatter.formatCents(purchase.amountCents, currency: purchase.currency);

    return Card(
      color: AppColors.darkSurface,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(icon, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          purchase.merchant.isNotEmpty ? purchase.merchant : purchase.description,
          style: const TextStyle(
            color: AppColors.textHighDark,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '${purchase.cardAlias} • ${DateFormatter.formatShort(purchase.purchaseDate)}',
          style: const TextStyle(
            color: AppColors.textMediumDark,
            fontSize: 12,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formattedAmount,
              style: const TextStyle(
                color: AppColors.textHighDark,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (purchase.estimatedRewardCents > 0)
              Text(
                '+${MoneyFormatter.formatCents(purchase.estimatedRewardCents, currency: purchase.currency)} cashback',
                style: const TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
