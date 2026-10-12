import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shell/presentation/screens/app_shell_screen.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const AppShellScreen();
        }
        return const AuthScreen();
      },
      loading: () => const _AuthSplashView(),
      error: (e, st) => const AuthScreen(),
    );
  }
}

class _AuthSplashView extends StatelessWidget {
  const _AuthSplashView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.softBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.pastelMintBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.brandPrimary.withValues(alpha: 0.5)
                      : AppColors.pastelMintBorder,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.brandPrimary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textHighDark : AppColors.slate900,
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.brandPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
