# Wallet AI - Optimizador Inteligente de Billetera y Fechas de Corte

[![Flutter Version](https://img.shields.io/badge/Flutter-3.44+-02569B?logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2F%20Hexagonal-brightgreen)](docs/ARCHITECTURE.md)
[![License](https://img.shields.io/badge/License-Proprietary-blue)](#)

Wallet AI es un asistente financiero personal y optimizador de billetera móvil desarrollado en **Flutter & Dart**. Analiza fechas de corte, fechas límite de pago, periodos de facturación, beneficios y preferencias para responder de forma determinista y transparente:

> **"¿Qué tarjeta me conviene utilizar hoy y por qué?"**

---

## 🚀 Características Principales

* **🌟 Recomendación del Día**: Identifica la tarjeta óptima según inicio de ciclo de facturación reciente (hasta 50 días de crédito sin intereses) y promociones de cashback vigentes.
* **💳 Billetera Virtual Interactiva**: Administración integral de tarjetas de crédito y débito con barras de progreso de ciclo de facturación y control de utilización de línea de crédito.
* **⚡ Simulador de Compras en Vivo**: Permite ingresar un monto y una categoría (Supermercado, Gasolina, Restaurantes, etc.) para comparar en tiempo real el beneficio neto en pesos y los días disponibles de financiamiento en cada tarjeta.
* **📅 Calendario Financiero Integral**: Visualización mensual y semanal con marcadores para fechas de corte, fechas límite de pago y cuotas de préstamos.
* **💰 Gestión de Préstamos**: Control de saldo insoluto, cálculo de cuotas y fechas de amortización de obligaciones financieras.
* **🛡️ Zero-Knowledge de Seguridad**: No solicita números completos (PAN), ni CVV, ni contraseñas bancarias. Opera con reglas matemáticas auditables.
* **🔄 Dual-Mode Arquitectónico**: Operación 100% offline y modo demostración local instantáneo, con capacidad de sincronización con Firebase (Auth + Cloud Firestore + Functions).

---

## 📂 Documentación del Proyecto

Consulte la especificación técnica completa en el directorio [`docs/`](docs/):

* [Visión General del Proyecto (`docs/PROJECT_OVERVIEW.md`)](docs/PROJECT_OVERVIEW.md)
* [Arquitectura de Software (`docs/ARCHITECTURE.md`)](docs/ARCHITECTURE.md)
* [Plan de Implementación y Fases (`docs/IMPLEMENTATION_PLAN.md`)](docs/IMPLEMENTATION_PLAN.md)
* [Esquema de Base de Datos (`docs/DATABASE_SCHEMA.md`)](docs/DATABASE_SCHEMA.md)
* [Reglas de Negocio Financieras (`docs/BUSINESS_RULES.md`)](docs/BUSINESS_RULES.md)
* [Especificación UI/UX Fintech (`docs/UI_UX_SPECIFICATION.md`)](docs/UI_UX_SPECIFICATION.md)
* [Plan de Seguridad y Privacidad (`docs/SECURITY_PLAN.md`)](docs/SECURITY_PLAN.md)
* [Estrategia y Plan de Pruebas (`docs/TESTING_PLAN.md`)](docs/TESTING_PLAN.md)
* [Decisiones Arquitectónicas ADR (`docs/DECISIONS.md`)](docs/DECISIONS.md)

---

## 🛠️ Requisitos Previos y Ejecución

### Entorno Requerido
* **Flutter SDK**: 3.44.0 o superior (con Dart 3.12+).
* **Git**: Instalado.
* **Plataformas Soportadas**: macOS Desktop, Web, Android, iOS.

### Ejecución Local Rápida (Modo Demo)
```bash
# Navegar a la app Flutter
cd wallet_ai/app

# Instalar dependencias
flutter pub get

# Ejecutar pruebas unitarias del motor financiero
flutter test

# Ejecutar en macOS desktop o Chrome
flutter run -d macos
# o
flutter run -d chrome
```
