import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../cards/presentation/screens/card_detail_screen.dart';
import '../../../cards/presentation/screens/card_form_screen.dart';
import '../../../cards/presentation/widgets/digital_card_widget.dart';
import '../../../purchases/presentation/providers/purchases_provider.dart';
import '../../../purchases/presentation/screens/purchase_form_screen.dart';
import '../../../purchases/presentation/widgets/purchase_tile.dart';
import '../../../recommendations/presentation/providers/recommendation_provider.dart';
import '../../../recommendations/presentation/screens/card_comparison_screen.dart';
import '../../../recommendations/presentation/screens/purchase_simulator_screen.dart';
import '../../../recommendations/presentation/widgets/hero_recommendation_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/shimmer_loading.dart';

/// Dashboard principal de Wallet AI con estética Modern Minimalist Finance & Soft UI Pastel.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showAdviceBanner = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);
    final userFirstName = currentUser?.displayName?.isNotEmpty == true
        ? currentUser!.displayName!.split(' ').first
        : (currentUser?.email != null
            ? currentUser!.email!.split('@').first
            : (currentUser?.isAnonymous == true ? 'Invitado' : 'Carlos'));
    final initials = userFirstName.length >= 2 ? userFirstName.substring(0, 2).toUpperCase() : 'AI';

    final cardsAsync = ref.watch(cardsProvider);
    final purchasesAsync = ref.watch(purchasesProvider);
    final dailyRecommendation = ref.watch(dailyRecommendationProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.softBackground,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            // Avatar Soft UI con indicador de estado pastel
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.darkSurface : AppColors.pastelMintBg,
                    border: Border.all(
                      color: isDark
                          ? AppColors.brandPrimary.withValues(alpha: 0.5)
                          : AppColors.pastelMintBorder,
                      width: 1.5,
                    ),
                    boxShadow: isDark
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0x0A059669),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.pastelMintText,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.brandPrimary,
                      border: Border.all(
                        color: isDark ? AppColors.darkBackground : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hola, $userFirstName • ${DateFormatter.formatShort(DateTime.now())}',
                  style: TextStyle(
                    color: isDark ? AppColors.textMediumDark : AppColors.slate400,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Wallet AI',
                  style: TextStyle(
                    color: isDark ? AppColors.textHighDark : AppColors.slate900,
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.brandPrimary.withValues(alpha: 0.12)
                  : AppColors.pastelMintBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.brandPrimary.withValues(alpha: 0.35)
                    : AppColors.pastelMintBorder,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.offline_bolt_rounded, color: AppColors.pastelMintText, size: 13),
                SizedBox(width: 4),
                Text(
                  'Modo Demo Local',
                  style: TextStyle(
                    color: AppColors.pastelMintText,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.brandPrimary,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.softSurface,
        onRefresh: () async {
          ref.invalidate(cardsProvider);
          ref.invalidate(purchasesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // ==========================================================
            // 1. SALDO PRINCIPAL DESTACADO EN LA PARTE SUPERIOR (HERO)
            // ==========================================================
            cardsAsync.when(
              data: (cards) => _buildHeroBalanceCard(context, cards, isDark),
              loading: () => Container(
                height: 180,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.softSurface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.brandPrimary),
                ),
              ),
              error: (e, _) => Text('Error al cargar balance: $e'),
            ),

            const SizedBox(height: 20),

            // ==========================================================
            // 2. TARJETAS DE RESUMEN FINANCIERO (BENTO CARDS & HERO IA)
            // ==========================================================
            Row(
              children: [
                Text(
                  'Resumen Financiero',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textHighDark : AppColors.slate900,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tarjetas de Resumen en 2 columnas (Crédito Disponible vs Gastos)
            cardsAsync.maybeWhen(
              data: (cards) => _buildFinancialSummaryBento(cards, isDark),
              orElse: () => const SizedBox.shrink(),
            ),

            const SizedBox(height: 14),

            // Tarjeta Hero: Recomendación Inteligente del Día
            HeroRecommendationCard(
              recommendation: dailyRecommendation,
              onSimulateTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PurchaseSimulatorScreen()),
                );
              },
              onCompareTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CardComparisonScreen()),
                );
              },
            ),

            if (_showAdviceBanner) ...[
              const SizedBox(height: 14),
              _buildSmartAdviceBanner(isDark),
            ],

            const SizedBox(height: 24),

            // ==========================================================
            // 3. SECCIÓN "MIS TARJETAS" (DIGITAL CARDS STACK)
            // ==========================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Mis Tarjetas',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textHighDark : AppColors.slate900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    cardsAsync.maybeWhen(
                      data: (cards) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.glassWhite : AppColors.softSurfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.glassWhite : AppColors.softBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '${cards.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textMediumDark : AppColors.slate600,
                          ),
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CardFormScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.pastelMintText),
                  label: const Text(
                    'Agregar',
                    style: TextStyle(
                      color: AppColors.pastelMintText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            cardsAsync.when(
              data: (cards) {
                if (cards.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.credit_card_off_outlined,
                    title: 'No tienes tarjetas registradas',
                    message: 'Agrega tu primera tarjeta o activa el set de demostración para optimizar tus beneficios.',
                    actionLabel: 'Cargar Tarjetas Demo',
                    onAction: () {
                      ref.read(cardsProvider.notifier).resetToDemo();
                    },
                  );
                }

                return Column(
                  children: cards.map((card) {
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
                  }).toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CardShimmerPlaceholder(),
              ),
              error: (e, _) => ErrorStateView(
                title: 'No se pudieron cargar las tarjetas',
                message: '$e',
                onRetry: () => ref.refresh(cardsProvider),
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================================
            // 4. LISTA CRONOLÓGICA DE MOVIMIENTOS
            // ==========================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Movimientos Recientes',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textHighDark : AppColors.slate900,
                    letterSpacing: -0.2,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PurchaseFormScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.pastelMintText),
                  label: const Text(
                    'Registrar',
                    style: TextStyle(
                      color: AppColors.pastelMintText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            purchasesAsync.when(
              data: (purchases) {
                if (purchases.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.receipt_long_outlined,
                    title: 'No hay movimientos registrados',
                    message: 'Registra tus compras o carga el set de demostración para ver tus beneficios en tiempo real.',
                    actionLabel: 'Cargar Compras Demo',
                    onAction: () {
                      ref.read(purchasesProvider.notifier).resetToDemo();
                    },
                  );
                }

                // Ordenar cronológicamente (más recientes primero)
                final sorted = List.of(purchases)
                  ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

                final recent = sorted.take(6).toList();
                return Column(
                  children: recent.map((p) => PurchaseTile(purchase: p)).toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CardShimmerPlaceholder(),
              ),
              error: (e, _) => ErrorStateView(
                title: 'No se pudieron cargar los movimientos',
                message: '$e',
                onRetry: () => ref.refresh(purchasesProvider),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  /// 1. Saldo Principal Destacado en la parte superior con estética Soft UI
  Widget _buildHeroBalanceCard(BuildContext context, List<dynamic> cards, bool isDark) {
    final creditCards = cards.where((c) => c.isCredit && c.isActive).toList();
    final totalAvailable = creditCards.fold<int>(0, (sum, c) => sum + (c.calculatedAvailableCreditCents as int));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.softSurface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? AppColors.glassWhite : AppColors.softBorder,
          width: 1,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : const [
                AppColors.softShadowFloating,
              ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SALDO TOTAL DISPONIBLE',
                style: TextStyle(
                  color: isDark ? AppColors.textSubtleDark : AppColors.slate400,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.brandPrimary.withValues(alpha: 0.15)
                      : AppColors.pastelMintBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.brandPrimary.withValues(alpha: 0.3)
                        : AppColors.pastelMintBorder,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded, color: AppColors.pastelMintText, size: 13),
                    SizedBox(width: 4),
                    Text(
                      '+4.2% este mes',
                      style: TextStyle(
                        color: AppColors.pastelMintText,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Monto Principal Gigante y Limpio
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                MoneyFormatter.formatCents(totalAvailable),
                style: TextStyle(
                  color: isDark ? AppColors.textHighDark : AppColors.slate900,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'MXN',
                style: TextStyle(
                  color: isDark ? AppColors.textSubtleDark : AppColors.slate400,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Fila de Acciones Rápidas (Soft Pastel Pills)
          Row(
            children: [
              _buildSoftActionButton(
                label: 'Simular',
                icon: Icons.calculate_outlined,
                bg: isDark ? AppColors.darkSurfaceElevated : AppColors.pastelMintBg,
                color: AppColors.pastelMintText,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PurchaseSimulatorScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildSoftActionButton(
                label: 'Comparar',
                icon: Icons.compare_arrows_rounded,
                bg: isDark ? AppColors.darkSurfaceElevated : AppColors.pastelSkyBg,
                color: AppColors.pastelSkyText,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CardComparisonScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildSoftActionButton(
                label: '+ Tarjeta',
                icon: Icons.add_card_rounded,
                bg: isDark ? AppColors.darkSurfaceElevated : AppColors.pastelLavenderBg,
                color: AppColors.pastelLavenderText,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CardFormScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildSoftActionButton(
                label: 'Registrar',
                icon: Icons.receipt_long_rounded,
                bg: isDark ? AppColors.darkSurfaceElevated : AppColors.pastelAmberBg,
                color: AppColors.pastelAmberText,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PurchaseFormScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoftActionButton({
    required String label,
    required IconData icon,
    required Color bg,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 0.8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 2. Tarjetas de Resumen Financiero (Bento)
  Widget _buildFinancialSummaryBento(List<dynamic> cards, bool isDark) {
    final creditCards = cards.where((c) => c.isCredit && c.isActive).toList();
    final totalLimit = creditCards.fold<int>(0, (sum, c) => sum + (c.creditLimitCents as int));
    final totalBalance = creditCards.fold<int>(0, (sum, c) => sum + (c.currentBalanceCents as int));
    final totalAvailable = creditCards.fold<int>(0, (sum, c) => sum + (c.calculatedAvailableCreditCents as int));
    final globalRatio = totalLimit > 0 ? (totalBalance / totalLimit) : 0.0;

    return Column(
      children: [
        Row(
          children: [
            // Card Pastel Sky: Crédito Disponible
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.pastelSkyBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.glassWhite : AppColors.pastelSkyBorder,
                    width: 1,
                  ),
                  boxShadow: isDark ? null : const [AppColors.softShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Crédito Disponible',
                          style: TextStyle(
                            color: AppColors.pastelSkyText,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.pastelSkyText.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.pastelSkyText,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      MoneyFormatter.formatCents(totalAvailable),
                      style: TextStyle(
                        color: isDark ? AppColors.textHighDark : AppColors.slate900,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Línea global activa',
                      style: TextStyle(
                        color: isDark ? AppColors.textSubtleDark : AppColors.slate500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Card Pastel Blush: Saldo Utilizado
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.pastelBlushBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.glassWhite : AppColors.pastelBlushBorder,
                    width: 1,
                  ),
                  boxShadow: isDark ? null : const [AppColors.softShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saldo Utilizado',
                          style: TextStyle(
                            color: AppColors.pastelBlushText,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.pastelBlushText.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.credit_card_rounded,
                            color: AppColors.pastelBlushText,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      MoneyFormatter.formatCents(totalBalance),
                      style: TextStyle(
                        color: isDark ? AppColors.textHighDark : AppColors.slate900,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Por pagar este ciclo',
                      style: TextStyle(
                        color: isDark ? AppColors.textSubtleDark : AppColors.slate500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Barra de utilización global
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.softSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.glassWhite : AppColors.softBorder,
              width: 0.8,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Uso de línea: ${(globalRatio * 100).round()}%',
                    style: TextStyle(
                      color: isDark ? AppColors.textMediumDark : AppColors.slate700,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Límite: ${MoneyFormatter.formatCents(totalLimit)}',
                    style: TextStyle(
                      color: isDark ? AppColors.textSubtleDark : AppColors.slate400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 5,
                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.softSurfaceMuted,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: globalRatio.clamp(0.02, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: globalRatio > 0.60
                              ? AppColors.warning
                              : AppColors.brandPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Banner Inteligente de Consejos UX Financieros en Pastel Amber
  Widget _buildSmartAdviceBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.warning.withValues(alpha: 0.1) : AppColors.pastelAmberBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.warning.withValues(alpha: 0.25) : AppColors.pastelAmberBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.transparent : Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.pastelAmberText,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Consejo Inteligente: ',
                style: TextStyle(
                  color: isDark ? AppColors.textHighDark : AppColors.slate900,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: 'Paga el saldo total de tus tarjetas antes de la fecha límite para mantener tasa 0% y maximizar beneficios.',
                    style: TextStyle(
                      color: isDark ? AppColors.textMediumDark : AppColors.slate600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 16,
              color: isDark ? AppColors.textSubtleDark : AppColors.slate400,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() => _showAdviceBanner = false);
            },
          ),
        ],
      ),
    );
  }
}
