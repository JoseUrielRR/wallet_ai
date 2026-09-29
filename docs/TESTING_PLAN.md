# Wallet AI - Testing Plan & QA Strategy

## 1. Filosofía de Pruebas

En una aplicación financiera, la **exactitud matemática y de fechas** tiene prioridad máxima sobre cualquier otro aspecto. Un error de un día en la fecha de corte puede inducir al usuario a cargos por mora e intereses indeseados.

Por ello, la estrategia de QA implementa la pirámide de testing con énfasis en pruebas unitarias puras y deterministas del motor de reglas, independientes de Flutter y Firebase.

---

## 2. Cobertura de Pruebas Unitarias del Motor Financiero

### 2.1. Casos de Prueba de Fechas (`BillingCycleEngineTest`)

| ID | Escenario | Entrada | Resultado Esperado |
|---|---|---|---|
| `TC-DATE-01` | Compra el mismo día del corte | Corte: día 15, Compra: 15-Sep | Asignada al ciclo que cierra hoy; pago en la fecha límite de Sep. |
| `TC-DATE-02` | Compra el día posterior al corte | Corte: día 15, Compra: 16-Sep | Asignada al siguiente ciclo (corte en Octubre); maximiza días libres. |
| `TC-DATE-03` | Corte configurado en día 31 en mes de 30 días | Corte: día 31, Mes: Abril | Corte efectivo ajustado al día 30 de Abril. |
| `TC-DATE-04` | Corte configurado en día 31 en Febrero no bisiesto | Corte: día 31, Año: 2025 | Corte efectivo ajustado al 28 de Febrero. |
| `TC-DATE-05` | Corte en Febrero bisiesto | Corte: día 31, Año: 2028 | Corte efectivo ajustado al 29 de Febrero. |
| `TC-DATE-06` | Transición de fin de año | Compra: 28-Dic, Corte: 10-Ene | Ciclo correctamente asignado al año siguiente. |
| `TC-DATE-07` | Regla de N días tras corte | Corte: día 10, Regla: +20 días | Fecha de pago calculada exactamente a 20 días naturales. |
| `TC-DATE-08` | Ajuste por fin de semana | Pago cae en Domingo, `adjustForHolidays: true` | Fecha de pago postergada al Lunes hábil siguiente. |

### 2.2. Casos de Prueba de Cashback (`CashbackCalculatorTest`)

| ID | Escenario | Entrada | Resultado Esperado |
|---|---|---|---|
| `TC-CASH-01` | Cashback simple en categoría | Compra $1,500 en Supermercado, Tasa: 3% | Recompensa: $45.00 MXN. |
| `TC-CASH-02` | Compra bajo monto mínimo | Compra $500, Mínimo requerido: $1,000 | Recompensa: $0.00 MXN con advertencia de gasto mínimo. |
| `TC-CASH-03` | Tope mensual de cashback alcanzado | Acumulado previo: $480, Tope: $500, Cashback bruto: $50 | Recompensa ajustada a $20.00 MXN (tope restante). |
| `TC-CASH-04` | Promoción temporal vencida | Fecha compra: 20-Oct, Vigencia promoción: hasta 30-Sep | Se descarta promoción vencida; aplica beneficio general o cero. |
| `TC-CASH-05` | Categoría no elegible | Compra en "Entretenimiento", Tarjeta solo bonifica "Gasolina" | Tasa 0% o tasa base general documentada. |

### 2.3. Casos de Prueba de Recomendaciones (`RecommendationEngineTest`)

| ID | Escenario | Entrada | Resultado Esperado |
|---|---|---|---|
| `TC-REC-01` | Tarjeta con crédito insuficiente | Compra: $15,000, Tarjeta A tiene $10,000 disponible, Tarjeta B tiene $20,000 | Tarjeta A se descarta o marca con advertencia; Tarjeta B es elegible. |
| `TC-REC-02` | Tarjeta inactiva o pausada | Tarjeta A ofrece 5% pero está pausada | Tarjeta A descartada; se recomienda la mejor activa. |
| `TC-REC-03` | Tarjeta recién cortada vs tarjeta a punto de cortar | Ambas 1% cashback, Tarjeta A cortó ayer (+45 días), Tarjeta B corta mañana (+2 días) | Tarjeta A gana por mayor holgura de financiamiento. |
| `TC-REC-04` | Ausencia de tarjetas | Usuario sin tarjetas registradas | Retorna recomendación vacía con indicación clara para registrar una tarjeta. |
| `TC-REC-05` | Explicabilidad del resultado | Solicitud de recomendación | El objeto devuelto incluye lista de razones claras, advertencias y nivel de certeza. |

---

## 3. Pruebas de Widgets e Integración

* **Card Widget**: Verifica el renderizado de barras de progreso, chips de alerta y cambio de color al superar el 70% de utilización.
* **Formulario de Tarjeta**: Comprobación de que fechas imposibles o límites negativos sean rechazados con mensajes de validación inline.
* **Simulador de Compra**: Prueba de actualización reactiva instantánea del ranking al cambiar el monto o la categoría en la interfaz.

---

## 4. Ejecución de Pruebas

Las pruebas se ejecutarán mediante el runner estándar de Flutter:
```bash
flutter test
```
Ninguna fase se considerará concluida si los tests unitarios reportan fallos.
