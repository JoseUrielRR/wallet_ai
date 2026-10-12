import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _mapErrorMessage(dynamic error) {
    debugPrint('[AuthScreen] Error capturado en autenticación: $error');
    final raw = error.toString();
    final msg = raw.toLowerCase();

    if (msg.contains('operation-not-allowed')) {
      return 'El proveedor de Correo/Contraseña no está habilitado en Firebase Console (Authentication > Sign-in method). Habilítalo para continuar.';
    }
    if (msg.contains('user-not-found') || msg.contains('wrong-password') || msg.contains('invalid-credential')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (msg.contains('email-already-in-use')) {
      return 'Ya existe una cuenta registrada con este correo.';
    }
    if (msg.contains('weak-password')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (msg.contains('invalid-email')) {
      return 'Ingresa un correo electrónico válido.';
    }
    if (msg.contains('network-request-failed') || msg.contains('socketexception') || msg.contains('connection failed') || msg.contains('network')) {
      return 'Sin conexión con los servidores de Firebase. Verifica tu conexión a internet.';
    }
    if (msg.contains('firebase-not-initialized')) {
      return 'Firebase no está inicializado en la aplicación.';
    }
    if (error is Failure && error.message.isNotEmpty) {
      return error.message;
    }
    return raw.isNotEmpty ? raw : 'Ocurrió un error al procesar tu solicitud. Intenta nuevamente.';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = ref.read(authControllerProvider.notifier);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isRegisterMode) {
      final name = _nameController.text.trim();
      await authController.registerWithEmail(
        email,
        password,
        displayName: name.isNotEmpty ? name : null,
      );
    } else {
      await authController.signInWithEmail(email, password);
    }
  }

  Future<void> _continueAsGuest() async {
    await ref.read(authControllerProvider.notifier).signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    final primaryTextColor = isDark ? AppColors.textHighDark : AppColors.slate900;
    final secondaryTextColor = isDark ? AppColors.textMediumDark : AppColors.slate500;
    final cardBgColor = isDark ? AppColors.darkSurface : AppColors.softSurface;
    final cardBorderColor = isDark ? AppColors.darkBorder : AppColors.softBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.softBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Logo & Identidad de Marca Soft UI
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.pastelMintBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.brandPrimary.withValues(alpha: 0.5)
                            : AppColors.pastelMintBorder,
                        width: 2,
                      ),
                      boxShadow: isDark ? null : const [AppColors.softShadow],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.brandPrimary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: primaryTextColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Optimizador inteligente de tarjetas y recompensas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. Tarjeta del Formulario
                  Container(
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: cardBorderColor),
                      boxShadow: isDark ? null : const [AppColors.softShadow],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Selector de pestaña (Iniciar Sesión / Registro)
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceElevated : AppColors.softSurfaceMuted,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_isRegisterMode) {
                                        setState(() => _isRegisterMode = false);
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: !_isRegisterMode
                                            ? (isDark ? AppColors.darkSurface : Colors.white)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: !_isRegisterMode && !isDark
                                            ? const [AppColors.softShadow]
                                            : null,
                                      ),
                                      child: Text(
                                        'Iniciar Sesión',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: !_isRegisterMode ? FontWeight.w700 : FontWeight.w600,
                                          fontSize: 13.5,
                                          color: !_isRegisterMode ? primaryTextColor : secondaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!_isRegisterMode) {
                                        setState(() => _isRegisterMode = true);
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _isRegisterMode
                                            ? (isDark ? AppColors.darkSurface : Colors.white)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: _isRegisterMode && !isDark
                                            ? const [AppColors.softShadow]
                                            : null,
                                      ),
                                      child: Text(
                                        'Crear Cuenta',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: _isRegisterMode ? FontWeight.w700 : FontWeight.w600,
                                          fontSize: 13.5,
                                          color: _isRegisterMode ? primaryTextColor : secondaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Banner de Error
                          if (authState.hasError) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.error.withValues(alpha: 0.15) : AppColors.pastelBlushBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark ? AppColors.error.withValues(alpha: 0.4) : AppColors.pastelBlushBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _mapErrorMessage(authState.error),
                                      style: TextStyle(
                                        color: isDark ? AppColors.textHighDark : AppColors.pastelBlushText,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Campo Nombre (solo en registro)
                          if (_isRegisterMode) ...[
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: 'Nombre completo',
                                hintText: 'Ej. Alex Rivera',
                                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Por favor ingresa tu nombre';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Campo Correo
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              hintText: 'tu@correo.com',
                              prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Ingresa tu correo';
                              }
                              if (!val.contains('@') || !val.contains('.')) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Campo Contraseña
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Ingresa tu contraseña';
                              }
                              if (val.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Campo Confirmar Contraseña (solo registro)
                          if (_isRegisterMode) ...[
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Confirmar contraseña',
                                prefixIcon: const Icon(Icons.lock_clock_outlined, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              validator: (val) {
                                if (val != _passwordController.text) {
                                  return 'Las contraseñas no coinciden';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Botón Principal
                          ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    _isRegisterMode ? 'Crear Cuenta' : 'Iniciar Sesión',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Separador o Botón Invitado
                  Row(
                    children: [
                      Expanded(child: Divider(color: cardBorderColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'O bien',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: cardBorderColor)),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Botón de Inicio Anónimo / Modo Invitado
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : _continueAsGuest,
                    icon: const Icon(Icons.bolt_rounded, color: AppColors.brandPrimary, size: 18),
                    label: const Text('Continuar como Invitado'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryTextColor,
                      side: BorderSide(color: cardBorderColor),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Podrás registrar tu correo más tarde sin perder tus datos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
