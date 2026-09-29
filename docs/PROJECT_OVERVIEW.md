# Wallet AI - Project Overview

## 1. Visión General del Producto

**Wallet AI** es una aplicación móvil de finanzas personales inteligente de última generación diseñada para maximizar el valor financiero de los usuarios al gestionar sus tarjetas de crédito, débito, préstamos y beneficios financieros.

A diferencia de las aplicaciones bancarias tradicionales o los sistemas de cobranza que se enfocan en saldos pasados y deudas, Wallet AI actúa como un **copiloto proactivo y estratégico**. Transforma datos complejos (fechas de corte, fechas límite de pago, periodos de facturación, tasas de interés, categorías de recompensas, topes de cashback y promociones) en recomendaciones claras, deterministas y accionables.

La pregunta clave que responde cada día es:
> **"¿Qué tarjeta me conviene utilizar hoy y por qué?"**

---

## 2. Objetivos Principales

1. **Optimización Financiera Diaria**: Indicar con precisión matemática qué tarjeta ofrece el máximo tiempo de financiamiento sin intereses (días disponibles hasta el vencimiento) y qué tarjeta maximiza las recompensas (cashback o puntos) para cada tipo de gasto.
2. **Claridad y Control del Flujo de Efectivo**: Ofrecer un calendario financiero integral que unifique cortes, vencimientos de tarjetas, pagos de préstamos y compras proyectadas, eliminando sorpresas de cargos por pago tardío e intereses moratorios.
3. **Privacidad y Soberanía de Datos**: Arquitectura segura de conocimiento cero sobre credenciales bancarias. No solicita contraseñas, CVV ni números completos de tarjetas (PAN). Solo requiere los últimos 4 dígitos opcionales y reglas de facturación.
4. **Independencia Bancaria**: Catálogo universal configurable de emisores y productos financieros (Nu, BBVA, Santander, Banorte, Citibanamex, Amex, Hey Banco, etc.), permitiendo tanto sincronización en la nube como operación 100% offline o en modo demo sin conexión obligatoria a APIs bancarias cerradas.
5. **Transparencia Absoluta**: Cada recomendación desglosa sus criterios, reglas evaluadas, advertencias de crédito disponible y nivel de certeza de los datos (confirmado vs estimado).

---

## 3. Público Objetivo y Casos de Uso

### Perfiles de Usuario
* **Optimizadores de Recompensas (Maximizers)**: Usuarios con múltiples tarjetas que buscan exprimir cada punto y porcentaje de cashback en cada categoría (gasolina, supermercados, viajes, servicios).
* **Gestores de Liquidez (Cash Flow Managers)**: Profesionales o freelancers que necesitan financiar compras de inventario o gastos corrientes aprovechando hasta 45-50 días de crédito sin intereses, seleccionando tarjetas recién cortadas.
* **Usuarios en Consolidación de Deuda**: Personas que buscan visibilidad consolidada de sus tarjetas y préstamos personales para priorizar pagos y evitar sobreendeudamiento.

### Casos de Uso Clave
1. **Recomendación Diaria Matutina**: Revisión rápida al inicio del día sobre qué tarjeta tiene el ciclo de facturación más fresco y promociones vigentes.
2. **Simulador de Compra en Punto de Venta**: Ingreso de importe (ej. $1,500 MXN) y categoría (ej. Supermercado) antes de pagar para ver el ranking comparativo de tarjetas según cashback neto y días de crédito.
3. **Monitoreo de Ciclo de Facturación**: Detección del día de corte para diferir gastos grandes un día después del corte y obtener el ciclo completo de financiamiento.
4. **Gestión de Préstamos Personales**: Control de cuotas, fechas de amortización y saldo insoluto de préstamos bancarios o personales sin mezclarlo artificialmente con líneas de crédito rotativo.

---

## 4. Pilares de Diseño y Principios Rectores

* **Funcionalidad Real**: Todo botón, selector, filtro y tarjeta responde a lógica de negocio real. Cero maquetas vacías o decorativas.
* **Motor Financiero Determinista e Independiente**: Cálculos de días calendario, años bisiestos, cambios de mes y reglas de recompensas desacoplados de frameworks visuales y probados con suites exhaustivas de pruebas unitarias.
* **Separación de Entornos y Modo Demo Local**: La app es 100% interactiva desde el primer segundo gracias a un motor de datos de demostración enriquecido (Aurora, Horizonte, Prisma), conmutador a backend de Firebase en cualquier momento.
* **Diseño Fintech Moderno y Accesible**: Material Design 3 con paleta refinada, soporte para Dark Mode, tipografía legible y microinteracciones de alta calidad.
