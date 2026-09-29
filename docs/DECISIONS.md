# Wallet AI - Architecture Decision Records (ADR)

## ADR-001: Elección de Arquitectura Limpia y Modular (Clean Architecture)
* **Estado**: Aceptado.
* **Contexto**: Wallet AI maneja reglas financieras complejas (ciclos de corte, días de gracia, cashback, topes y rankings) que deben ser altamente auditables, testeables y resistentes a cambios futuros en la interfaz o backend.
* **Decisión**: Estructurar el código en 4 capas estrictas (Dominio, Aplicación, Presentación y Datos), ubicando la lógica matemática en el Dominio sin ninguna dependencia de Flutter o Firebase.
* **Consecuencias**: El motor financiero puede probarse en milisegundos con pruebas unitarias de Dart puras; la interfaz puede rediseñarse sin alterar las fórmulas financieras.

---

## ADR-002: Gestión de Estado con Riverpod 2.x
* **Estado**: Aceptado.
* **Contexto**: Se requiere una solución de estado reactiva, fuertemente tipada, testeable sin necesidad de contexto de Flutter (`BuildContext`) y que facilite la inyección de dependencias para alternar entre el entorno de demostración local y Firebase.
* **Decisión**: Utilizar `flutter_riverpod` con `NotifierProvider` y `AsyncNotifierProvider`.
* **Consecuencias**: No requiere inyección de dependencias adicional (como GetIt), previene fugas de memoria al liberar providers no utilizados y permite mocks limpios en tests de widgets y unitarios.

---

## ADR-003: Representación Monetaria en Centavos Enteros
* **Estado**: Aceptado.
* **Contexto**: El estándar IEEE 754 de números de coma flotante (`double` en Dart) produce anomalías de redondeo notorias (ej. `0.1 + 0.2 = 0.30000000000000004`), lo cual es inaceptable en un sistema financiero.
* **Decisión**: Almacenar y operar todos los montos en la unidad monetaria mínima (centavos enteros de tipo `int`). Se introduce un Value Object `Money` y formateadores de moneda para la capa de presentación.
* **Consecuencias**: Cero discrepancias de redondeo en balances, cashback acumulado o amortización de préstamos.

---

## ADR-004: Motor de Reglas Determinista vs Modelo LLM para Cálculos
* **Estado**: Aceptado.
* **Contexto**: El usuario necesita saber con absoluta certeza y justificación matemática por qué una tarjeta es la mejor opción.
* **Decisión**: Implementar un motor de reglas multicriterio explícito (`RecommendationEngine`) en código compilado determinista. No se delega el cálculo matemático a LLMs generativos propensos a alucinaciones de fechas.
* **Consecuencias**: Respuestas instantáneas en menos de 5ms, auditabilidad total, funcionamiento offline completo y reproducibilidad del 100%.

---

## ADR-005: Dual Repository: Modo Demo Local y Firebase Cloud
* **Estado**: Aceptado.
* **Contexto**: El sistema debe ser inmediatamente funcional y ejecutable en desarrollo local sin requerir credenciales de Firebase de inmediato, pero debe tener la capacidad nativa de conectarse a Firebase Authentication y Firestore.
* **Decisión**: Diseñar las interfaces de repositorio (`ICardRepository`, `IPurchaseRepository`, etc.) con dos implementaciones intercambiables: `LocalDemoRepository` (con datos iniciales simulados de Banco Aurora, Horizonte y Prisma) y `FirestoreRepository`.
* **Consecuencias**: El proyecto arranca de inmediato, los desarrolladores y evaluadores pueden probar todos los flujos sin configuración de nube previa.

---

## ADR-006: Backend Cloud Functions en TypeScript
* **Estado**: Aceptado.
* **Contexto**: Se requiere un backend serverless para tareas programadas de notificaciones de corte y recálculo de beneficios públicos.
* **Decisión**: Implementar Cloud Functions en TypeScript en el directorio `functions/`, con tipado estricto compartido con el modelo de datos.
