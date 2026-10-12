import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/models/purchase.dart';

/// Tile de movimiento cronológico con diseño Soft UI y colores pastel
class PurchaseTile extends StatelessWidget {
  final Purchase purchase;
  final VoidCallback? onDelete;

  const PurchaseTile({
    super.key,
    required this.purchase,
    this.onDelete,
  });

  Color _getCategoryPastelBg(String category) {
    switch (category.toLowerCase()) {
      case 'supermarket':
      case 'groceries':
        return AppColors.pastelMintBg;
      case 'dining':
      case 'restaurants':
        return AppColors.pastelBlushBg;
      case 'travel':
      case 'flights':
        return AppColors.pastelSkyBg;
      case 'entertainment':
      case 'department':
        return AppColors.pastelLavenderBg;
      case 'gas':
      case 'services':
        return AppColors.pastelAmberBg;
      default:
        return AppColors.softSurfaceMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = AppConstants.getCategoryIcon(purchase.category);
    final formattedAmount = MoneyFormatter.formatCents(purchase.amountCents, currency: purchase.currency);
    final pastelBg = _getCategoryPastelBg(purchase.category);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.softSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isDark ? AppColors.glassWhite : AppColors.softBorder,
            width: 0.8,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : pastelBg,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(icon, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          purchase.merchant.isNotEmpty ? purchase.merchant : purchase.description,
          style: TextStyle(
            color: isDark ? AppColors.textHighDark : AppColors.slate900,
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '${purchase.cardAlias} • ${DateFormatter.formatShort(purchase.purchaseDate)}',
            style: TextStyle(
              color: isDark ? AppColors.textMediumDark : AppColors.slate500,
              fontSize: 12,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formattedAmount,
              style: TextStyle(
                color: isDark ? AppColors.textHighDark : AppColors.slate900,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: -0.2,
              ),
            ),
            if (purchase.estimatedRewardCents > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.brandPrimary.withValues(alpha: 0.15)
                        : AppColors.pastelMintBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${MoneyFormatter.formatCents(purchase.estimatedRewardCents, currency: purchase.currency)}',
                    style: const TextStyle(
                      color: AppColors.pastelMintText,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
}
