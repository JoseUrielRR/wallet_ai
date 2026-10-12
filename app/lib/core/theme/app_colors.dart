import 'package:flutter/material.dart';

/// Paleta de colores Fintech Soft UI y Pastel para Wallet AI
class AppColors {
  AppColors._();

  // Soft UI Light Mode Tokens (Primary Theme)
  static const Color softBackground = Color(0xFFF8FAFC); // Porcelana suave
  static const Color softSurface = Color(0xFFFFFFFF); // Blanco puro para tarjetas
  static const Color softSurfaceMuted = Color(0xFFF1F5F9); // Gris suave para contenedores
  static const Color softBorder = Color(0xFFE2E8F0); // Borde ultra suave
  static const Color softBorderSubtle = Color(0xFFF1F5F9);

  // Paleta de Colores Pastel Semánticos
  // Pastel Mint / Esmeralda (A favor / Disponible / Recomendación)
  static const Color pastelMintBg = Color(0xFFE6F9F0);
  static const Color pastelMintText = Color(0xFF059669);
  static const Color pastelMintBorder = Color(0xFFA7F3D0);

  // Pastel Lavender / Púrpura (Aurora / Nu / Recompensas)
  static const Color pastelLavenderBg = Color(0xFFF3E8FF);
  static const Color pastelLavenderText = Color(0xFF7C3AED);
  static const Color pastelLavenderBorder = Color(0xFFDDD6FE);

  // Pastel Sky Blue / Océano (BBVA / Horizonte / Servicios)
  static const Color pastelSkyBg = Color(0xFFEFF6FF);
  static const Color pastelSkyText = Color(0xFF0284C7);
  static const Color pastelSkyBorder = Color(0xFFBAE6FD);

  // Pastel Blush / Coral (Gastos / Saldo utilizado / Alertas)
  static const Color pastelBlushBg = Color(0xFFFFF1F2);
  static const Color pastelBlushText = Color(0xFFE11D48);
  static const Color pastelBlushBorder = Color(0xFFFECDD3);

  // Pastel Amber / Mantequilla (Vencimientos próximos / Precaución)
  static const Color pastelAmberBg = Color(0xFFFFFBEB);
  static const Color pastelAmberText = Color(0xFFD97706);
  static const Color pastelAmberBorder = Color(0xFFFDE68A);

  // Tipografía Limpia Slate (High Contrast & Readability)
  static const Color slate900 = Color(0xFF0F172A); // Encabezados principales y montos
  static const Color slate700 = Color(0xFF334155); // Subtítulos y etiquetas destacadas
  static const Color slate500 = Color(0xFF64748B); // Texto secundario
  static const Color slate400 = Color(0xFF94A3B8); // Captions, fechas y placeholders

  // Sombras Soft UI
  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x0A0F172A),
    blurRadius: 18,
    offset: Offset(0, 6),
  );

  static const BoxShadow softShadowFloating = BoxShadow(
    color: Color(0x140F172A),
    blurRadius: 24,
    offset: Offset(0, 10),
  );

  // Dark Mode Tokens (Compatibility)
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkSurfaceElevated = Color(0xFF21262D);
  static const Color darkBorder = Color(0xFF30363D);

  // Light Mode Tokens (Legacy aliases)
  static const Color lightBackground = softBackground;
  static const Color lightSurface = softSurface;
  static const Color lightSurfaceElevated = softSurfaceMuted;
  static const Color lightBorder = softBorder;

  // Brand Accents
  static const Color brandPrimary = Color(0xFF10B981); // Emerald Mint
  static const Color brandPrimaryLight = Color(0xFF34D399);
  static const Color brandPrimaryDark = Color(0xFF059669);
  static const Color brandSecondary = Color(0xFF0284C7); // Sky Blue
  static const Color brandPurple = Color(0xFF8B5CF6); // Lavender Purple
  static const Color brandGold = Color(0xFFF59E0B); // Amber

  // Realistic Banking Card Palettes
  static const Color nuPurple = Color(0xFF8A05BE);
  static const Color nuPurpleDark = Color(0xFF530082);
  static const Color bbvaNavy = Color(0xFF004481);
  static const Color bbvaNavyLight = Color(0xFF1464A5);
  static const Color rappiGraphite = Color(0xFF1E293B);
  static const Color rappiOrange = Color(0xFFFF5722);
  static const Color rappiOrangeLight = Color(0xFFFF8A65);

  // Glassmorphic & Overlay Tokens
  static const Color glassWhite = Color(0x1FFFFFFF);
  static const Color glassWhiteSubtle = Color(0x0DFFFFFF);
  static const Color glassWhiteHigh = Color(0x33FFFFFF);
  static const Color emeraldGlow = Color(0x3310B981);
  static const Color purpleGlow = Color(0x338B5CF6);
  static const Color blueGlow = Color(0x330284C7);

  // Status & Semaphores
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0284C7);

  // Text Tokens
  static const Color textHighDark = Color(0xFFF0F6FC);
  static const Color textMediumDark = Color(0xFF8B949E);
  static const Color textSubtleDark = Color(0xFF6E7681);

  static const Color textHighLight = slate900;
  static const Color textMediumLight = slate600;
  static const Color textSubtleLight = slate400;

  // Helper alias
  static const Color slate600 = Color(0xFF475569);

  // Card Gradients & Gloss
  static const LinearGradient cardGloss = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x28FFFFFF),
      Color(0x05FFFFFF),
      Colors.transparent,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient heroBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE6F9F0),
      Color(0xFFF0FDF4),
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient nuGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7C3AED),
      Color(0xFF6366F1),
      Color(0xFF4F46E5),
    ],
  );

  static const LinearGradient bbvaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0284C7),
      Color(0xFF0EA5E9),
      Color(0xFF1D4ED8),
    ],
  );

  static const LinearGradient rappiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF334155),
      Color(0xFF0F172A),
    ],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
      Color(0xFF047857),
    ],
  );
}
