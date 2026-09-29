import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil y Configuración', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjeta de Usuario
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.brandPrimary.withValues(alpha: 0.2),
                  child: const Text('AR', style: TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alex Rivera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textHighDark)),
                    SizedBox(height: 2),
                    Text('alex.rivera@ejemplo.com', style: TextStyle(color: AppColors.textMediumDark, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Configuración Financiera y Regional
          const Text('PREFERENCIAS FINANCIERAS', style: TextStyle(color: AppColors.textSubtleDark, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Card(
            color: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.darkBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Moneda Principal'),
                  subtitle: const Text('Utilizada para cálculos y comparativas'),
                  trailing: DropdownButton<String>(
                    value: _selectedCurrency,
                    dropdownColor: AppColors.darkSurfaceElevated,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'MXN', child: Text('MXN (\$ Peso)')),
                      DropdownMenuItem(value: 'USD', child: Text('USD (\$ Dólar)')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR (€ Euro)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCurrency = val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Configuración de Notificaciones
          const Text('NOTIFICACIONES INTELIGENTES', style: TextStyle(color: AppColors.textSubtleDark, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Card(
            color: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.darkBorder),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Alertas de Fecha de Corte'),
                  subtitle: const Text('Aviso para diferir compras grandes un día después'),
                  value: _closingAlerts,
                  onChanged: (v) => setState(() => _closingAlerts = v),
                ),
                const Divider(height: 1, color: AppColors.darkBorder),
                SwitchListTile(
                  title: const Text('Alertas de Fecha Límite de Pago'),
                  subtitle: const Text('Recordatorio antes de que se generen intereses'),
                  value: _paymentAlerts,
                  onChanged: (v) => setState(() => _paymentAlerts = v),
                ),
                const Divider(height: 1, color: AppColors.darkBorder),
                ListTile(
                  title: const Text('Anticipación de Recordatorios'),
                  trailing: DropdownButton<int>(
                    value: _alertDaysBefore,
                    dropdownColor: AppColors.darkSurfaceElevated,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 día antes')),
                      DropdownMenuItem(value: 3, child: Text('3 días antes')),
                      DropdownMenuItem(value: 5, child: Text('5 días antes')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _alertDaysBefore = val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Privacidad y Gestión de Datos
          const Text('PRIVACIDAD Y GESTIÓN DE DATOS', style: TextStyle(color: AppColors.textSubtleDark, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Card(
            color: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.darkBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.security, color: AppColors.brandPrimary),
                  title: const Text('Seguridad Zero-Knowledge'),
                  subtitle: const Text('Wallet AI nunca solicita números completos de tarjeta (PAN), CVV ni NIP bancario.'),
                ),
                const Divider(height: 1, color: AppColors.darkBorder),
                ListTile(
                  leading: const Icon(Icons.cloud_sync_outlined, color: AppColors.brandSecondary),
                  title: const Text('Restablecer Datos de Demostración'),
                  subtitle: const Text('Recarga las tarjetas de Banco Aurora, Horizonte y Prisma'),
                  onTap: () {
                    ref.read(cardsProvider.notifier).resetToDemo();
                    ref.read(loansProvider.notifier).resetToDemo();
                    ref.read(purchasesProvider.notifier).resetToDemo();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Se han restaurado los datos de prueba.')),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.darkBorder),
                ListTile(
                  leading: const Icon(Icons.delete_sweep_outlined, color: AppColors.error),
                  title: const Text('Vaciar Billetera'),
                  subtitle: const Text('Elimina todas las tarjetas, compras y préstamos locales'),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.darkSurface,
                        title: const Text('¿Vaciar toda la información?'),
                        content: const Text('Esta acción eliminará todas las tarjetas y registros locales.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Vaciar Todo', style: TextStyle(color: Colors.white)),
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
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Información de la Aplicación
          Center(
            child: Column(
              children: [
                Text(
                  '${AppConstants.appName} v${AppConstants.appVersion}',
                  style: const TextStyle(color: AppColors.textSubtleDark, fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Optimizador Financiero de Tarjetas y Fechas de Corte',
                  style: TextStyle(color: AppColors.textSubtleDark, fontSize: 11),
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
