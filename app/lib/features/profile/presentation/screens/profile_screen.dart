import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../loans/presentation/providers/loans_provider.dart';
import '../../../purchases/presentation/providers/purchases_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _selectedCurrency = 'MXN';
  bool _closingAlerts = true;
  bool _paymentAlerts = true;
  int _alertDaysBefore = 3;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? AppColors.textHighDark : AppColors.slate900;
    final secondaryTextColor = isDark ? AppColors.textMediumDark : AppColors.slate500;
    final sectionTitleColor = isDark ? AppColors.brandPrimaryLight : AppColors.slate500;
    final cardBgColor = isDark ? AppColors.darkSurface : AppColors.softSurface;
    final cardBorderColor = isDark ? AppColors.darkBorder : AppColors.softBorder;
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.softBorderSubtle;
    final dropdownBgColor = isDark ? AppColors.darkSurfaceElevated : Colors.white;

    final currentUser = ref.watch(currentUserProvider);
    final userDisplayName = currentUser?.displayName?.isNotEmpty == true
        ? currentUser!.displayName!
        : (currentUser?.isAnonymous == true
            ? 'Usuario Invitado'
            : (currentUser?.email != null ? currentUser!.email!.split('@').first : 'Alex Rivera'));
    final userEmail = currentUser?.isAnonymous == true
        ? 'Modo Invitado (Sincronización Local / Firebase)'
        : (currentUser?.email ?? 'alex.rivera@ejemplo.com');
    final parts = userDisplayName.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (userDisplayName.length >= 2 ? userDisplayName.substring(0, 2).toUpperCase() : 'AI');

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.softBackground,
        elevation: 0,
        title: Text(
          'Perfil y Configuración',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: primaryTextColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Tarjeta de Usuario Soft UI
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: isDark ? null : const [AppColors.softShadow],
            ),
            child: Material(
              color: cardBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(color: cardBorderColor, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: isDark
                          ? AppColors.brandPrimary.withValues(alpha: 0.2)
                          : AppColors.pastelMintBg,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.pastelMintText,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userDisplayName,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: primaryTextColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            userEmail,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Configuración Financiera y Regional
          Text(
            'PREFERENCIAS FINANCIERAS',
            style: TextStyle(
              color: sectionTitleColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: isDark ? null : const [AppColors.softShadow],
            ),
            child: Material(
              color: cardBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: cardBorderColor, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(
                  'Moneda Principal',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                subtitle: Text(
                  'Utilizada para cálculos y comparativas',
                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCurrency,
                    dropdownColor: dropdownBgColor,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: secondaryTextColor,
                    ),
                    style: TextStyle(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'MXN',
                        child: Text('MXN (\$ Peso)', style: TextStyle(color: primaryTextColor)),
                      ),
                      DropdownMenuItem(
                        value: 'USD',
                        child: Text('USD (\$ Dólar)', style: TextStyle(color: primaryTextColor)),
                      ),
                      DropdownMenuItem(
                        value: 'EUR',
                        child: Text('EUR (€ Euro)', style: TextStyle(color: primaryTextColor)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCurrency = val);
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 3. Configuración de Notificaciones
          Text(
            'NOTIFICACIONES INTELIGENTES',
            style: TextStyle(
              color: sectionTitleColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: isDark ? null : const [AppColors.softShadow],
            ),
            child: Material(
              color: cardBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: cardBorderColor, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    activeTrackColor: AppColors.brandPrimary,
                    activeThumbColor: Colors.white,
                    inactiveTrackColor: isDark ? AppColors.darkSurfaceElevated : AppColors.softSurfaceMuted,
                    title: Text(
                      'Alertas de Fecha de Corte',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    subtitle: Text(
                      'Aviso para diferir compras grandes un día después',
                      style: TextStyle(color: secondaryTextColor, fontSize: 12),
                    ),
                    value: _closingAlerts,
                    onChanged: (v) => setState(() => _closingAlerts = v),
                  ),
                  Divider(height: 1, color: dividerColor),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    activeTrackColor: AppColors.brandPrimary,
                    activeThumbColor: Colors.white,
                    inactiveTrackColor: isDark ? AppColors.darkSurfaceElevated : AppColors.softSurfaceMuted,
                    title: Text(
                      'Alertas de Fecha Límite de Pago',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    subtitle: Text(
                      'Recordatorio antes de que se generen intereses',
                      style: TextStyle(color: secondaryTextColor, fontSize: 12),
                    ),
                    value: _paymentAlerts,
                    onChanged: (v) => setState(() => _paymentAlerts = v),
                  ),
                  Divider(height: 1, color: dividerColor),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      'Anticipación de Recordatorios',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _alertDaysBefore,
                        dropdownColor: dropdownBgColor,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: secondaryTextColor,
                        ),
                        style: TextStyle(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 1,
                            child: Text('1 día antes', style: TextStyle(color: primaryTextColor)),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text('3 días antes', style: TextStyle(color: primaryTextColor)),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text('5 días antes', style: TextStyle(color: primaryTextColor)),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _alertDaysBefore = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 4. Privacidad y Gestión de Datos
          Text(
            'PRIVACIDAD Y GESTIÓN DE DATOS',
            style: TextStyle(
              color: sectionTitleColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: isDark ? null : const [AppColors.softShadow],
            ),
            child: Material(
              color: cardBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: cardBorderColor, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.brandPrimary.withValues(alpha: 0.15)
                            : AppColors.pastelMintBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        color: AppColors.pastelMintText,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      'Seguridad Zero-Knowledge',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    subtitle: Text(
                      'Wallet AI nunca solicita números completos de tarjeta (PAN), CVV ni NIP bancario.',
                      style: TextStyle(color: secondaryTextColor, fontSize: 12),
                    ),
                  ),
                  Divider(height: 1, color: dividerColor),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.brandSecondary.withValues(alpha: 0.15)
                            : AppColors.pastelSkyBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_sync_rounded,
                        color: AppColors.pastelSkyText,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      'Restablecer Datos de Demostración',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    subtitle: Text(
                      'Recarga las tarjetas de Banco Aurora, Horizonte y Prisma',
                      style: TextStyle(color: secondaryTextColor, fontSize: 12),
                    ),
                    onTap: () {
                      ref.read(cardsProvider.notifier).resetToDemo();
                      ref.read(loansProvider.notifier).resetToDemo();
                      ref.read(purchasesProvider.notifier).resetToDemo();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Se han restaurado los datos de prueba.')),
                      );
                    },
                  ),
                  Divider(height: 1, color: dividerColor),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.error.withValues(alpha: 0.15)
                            : AppColors.pastelBlushBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_sweep_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      'Vaciar Billetera',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    subtitle: Text(
                      'Elimina todas las tarjetas, compras y préstamos locales',
                      style: TextStyle(color: secondaryTextColor, fontSize: 12),
                    ),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: cardBgColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text(
                            '¿Vaciar toda la información?',
                            style: TextStyle(
                              color: primaryTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          content: Text(
                            'Esta acción eliminará todas las tarjetas y registros locales.',
                            style: TextStyle(color: secondaryTextColor),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Vaciar Todo'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(cardsProvider.notifier).clearAll();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Billetera vaciada exitosamente.')),
                          );
                        }
                      }
                    },
                  ),
                  Divider(height: 1, color: dividerColor),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.brandPrimary.withValues(alpha: 0.15)
                            : AppColors.pastelMintBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.brandPrimary,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    subtitle: Text(
                      'Desconecta tu sesión actual en este dispositivo',
                      style: TextStyle(color: secondaryTextColor, fontSize: 12),
                    ),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: cardBgColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text(
                            '¿Cerrar sesión?',
                            style: TextStyle(
                              color: primaryTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          content: Text(
                            'Tendrás que volver a ingresar tus credenciales para acceder a tus tarjetas.',
                            style: TextStyle(color: secondaryTextColor),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandPrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Cerrar Sesión'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(authControllerProvider.notifier).signOut();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // 5. Información de la Aplicación
          Center(
            child: Column(
              children: [
                Text(
                  '${AppConstants.appName} v${AppConstants.appVersion}',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Optimizador Financiero de Tarjetas y Fechas de Corte',
                  style: TextStyle(
                    color: secondaryTextColor.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
