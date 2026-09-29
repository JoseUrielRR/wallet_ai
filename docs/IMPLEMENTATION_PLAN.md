# Wallet AI - Implementation Plan & Progress Tracker

## Matriz de Fases de Implementación

| Fase | Título | Estado | Pruebas Asociadas | Archivos Clave |
|---|---|---|---|---|
| **Fase 0** | Inspección y Planificación | **En progreso** | N/A (Docs & Env check) | `docs/*.md`, `README.md` |
| **Fase 1** | Fundamentos y Setup de App | **Pendiente** | Smoke tests, routing | `app/lib/main.dart`, `theme/`, `routes.dart` |
| **Fase 2** | Motor Financiero y Ciclos de Facturación | **Pendiente** | Unit tests de fechas, bisiestos, cashback | `core/domain/`, `features/engine/` |
| **Fase 3** | Billetera y Tarjetas (CRUD & Loans) | **Pendiente** | Repository tests, validation tests | `features/cards/`, `features/loans/` |
| **Fase 4** | Dashboard y Tarjeta Recomendada | **Pendiente** | Widget tests de métricas y recomendación | `features/dashboard/` |
| **Fase 5** | Calendario Financiero y Compras | **Pendiente** | Date calculation & cycle allocation tests | `features/calendar/`, `features/purchases/` |
| **Fase 6** | Motor de Recomendaciones y Comparador | **Pendiente** | Multicriteria ranking & eligibility tests | `features/recommendations/`, `simulator/` |
| **Fase 7** | Configuración Firebase y Cloud Functions | **Pendiente** | Security rules test, functions unit test | `firebase/`, `functions/` |
| **Fase 8** | Notificaciones Inteligentes | **Pendiente** | Notification schedule & deduplication tests| `features/notifications/` |
| **Fase 9** | Refinamiento UI/UX y Accesibilidad | **Pendiente** | Integration tests, edge cases | Whole app UI polish, dark/light mode |
| **Fase 10**| Documentación Final y Entrega | **Pendiente** | Checklist de verificación final | README, User guides, scripts |

---

## Detalle de Tareas por Fase

### Fase 0. Inspección y Planificación
* [x] Inspeccionar herramientas del sistema (Flutter, Dart, Git, Node, Firebase CLI).
* [x] Identificar plataformas viables (macOS desktop, web, Android/iOS tooling).
* [x] Documentar herramientas faltantes (Node.js/npm no presentes en PATH; Flutter 3.44.0 disponible).
* [x] Crear documentación completa en `docs/`:
  - [x] `docs/PROJECT_OVERVIEW.md`
  - [x] `docs/ARCHITECTURE.md`
  - [x] `docs/IMPLEMENTATION_PLAN.md`
  - [ ] `docs/DATABASE_SCHEMA.md`
  - [ ] `docs/BUSINESS_RULES.md`
  - [ ] `docs/UI_UX_SPECIFICATION.md`
  - [ ] `docs/SECURITY_PLAN.md`
  - [ ] `docs/TESTING_PLAN.md`
  - [ ] `docs/DECISIONS.md`

### Fase 1. Fundamentos
* [ ] Inicializar proyecto Flutter en `wallet_ai/app`.
* [ ] Configurar dependencias en `pubspec.yaml` (flutter_riverpod, go_router, intl, uuid, etc.).
* [ ] Implementar Theme Fintech (Material 3, colores primarios, superficies, tipografía, Dark/Light mode).
* [ ] Configurar navegación principal por BottomNavigationBar (5 pestañas: Inicio, Billetera, Calendario, Actividad, Perfil).
* [ ] Configurar inyección de dependencias y Mock/Demo Repository Provider.

### Fase 2. Motor Financiero
* [ ] Modelar Value Objects (`Money`, `CutoffRule`, `BillingCycleDateRange`).
* [ ] Implementar `BillingCycleEngine`:
  - Cálculo de fecha de corte para meses de 28, 29, 30 y 31 días.
  - Reglas de ajuste por fin de semana o día inhábil bancario.
  - Determinación de ciclo asignado a una compra según fecha de transacción.
  - Cálculo de días de financiamiento libre de intereses (hasta 50 días).
* [ ] Implementar `CashbackCalculator`:
  - Cálculo de recompensa por categoría.
  - Manejo de topes máximos por periodo y gasto mínimo elegible.
* [ ] Crear suite de pruebas unitarias exhaustivas en `test/engine/`.

### Fase 3. Billetera y Préstamos
* [ ] Implementar entidades `UserCard`, `CardIssuer`, `CardProduct`, `Loan`.
* [ ] Implementar `LocalCardRepository` con persistencia y datos semilla de prueba (Banco Aurora, Horizonte, Prisma).
* [ ] Construir vistas de Billetera: listado de tarjetas, tarjeta interactiva con progreso de ciclo y uso de crédito.
* [ ] Formulario completo de creación/edición de tarjeta con validaciones de fechas.
* [ ] Módulo de préstamos personales: alta, saldo insoluto, cálculo de cuotas y fechas de pago.

### Fase 4. Dashboard
* [ ] Componente Hero: "Tarjeta recomendada del día" con explicación clara del motivo ("Hoy es 15 de septiembre. Tu tarjeta Nu acaba de iniciar ciclo...").
* [ ] Tarjetas de resumen financiero: Crédito total disponible, saldo utilizado global, utilización en porcentaje.
* [ ] Carrusel de tarjetas con acceso directo a detalles.
* [ ] Próximos pagos inminentes con alertas de proximidad (menos de 3 días, 7 días).
* [ ] Feed de actividad reciente y beneficios destacados.

### Fase 5. Calendario Financiero y Compras
* [ ] Calendario financiero interactivo con vistas mensual y semanal.
* [ ] Marcadores diferenciados por color: Fecha de corte, Fecha límite de pago, Pago de préstamo, Compras.
* [ ] Registro manual de compras con asignación automática al ciclo de facturación de la tarjeta.
* [ ] Historial de compras con filtros por categoría y tarjeta.

### Fase 6. Motor de Recomendaciones
* [ ] Implementar `RecommendationEngine`:
  - Evaluación multicriterio: Recompensa neta + Días de crédito disponibles + Crédito disponible vs Importe.
  - Explicabilidad: estructura con criterios aplicados, advertencias y nivel de certeza.
* [ ] Simulador de compras ("Smart Purchase Assistant"): selector de categoría e importe con comparación en tiempo real de todas las tarjetas.
* [ ] Pantalla comparativa de tarjetas con matriz de decisión.

### Fase 7. Firebase y Cloud Functions
* [ ] Definir esquemas y reglas de seguridad `firestore.rules` con denegación por defecto y aislamiento por UID.
* [ ] Crear índices requeridos en `firestore.indexes.json`.
* [ ] Implementar Cloud Functions en TypeScript (`functions/src`):
  - Recálculo programado de recomendaciones.
  - Recordatorios de fechas de corte y pago.
* [ ] Adaptadores de repositorio Firestore listos para conectarse en producción.

### Fase 8. Notificaciones Inteligentes
* [ ] Módulo de notificaciones con soporte para FCM y notificaciones locales de recordatorio.
* [ ] Pantalla de configuración de notificaciones: días de anticipación, hora preferida, tipos de avisos.
* [ ] Mecanismo de deduplicación de alertas para evitar spam.

### Fase 9. Refinamiento y Calidad
* [ ] Verificación de accesibilidad, contrastes, modo oscuro y tamaños de pantalla.
* [ ] Manejo de estados de carga (shimmers), estados vacíos con llamadas a la acción, estados de error.
* [ ] Ejecución de suite completa de pruebas (`flutter test`).

### Fase 10. Documentación Final
* [ ] `README.md` completo con arquitectura, capturas/diagramas, instrucciones de instalación y uso.
* [ ] Manual de configuración de Firebase y variables de entorno.
* [ ] Guía de ejecución en emulador o dispositivo físico.
