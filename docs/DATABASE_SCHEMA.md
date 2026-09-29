# Wallet AI - Database Schema Specification (Firestore & Local)

## 1. Principios de Modelado de Datos

1. **Monedas y Precisión**: Todos los importes monetarios se almacenan como enteros en su mínima unidad monetaria (ej. centavos de peso/dólar: `$1,500.00 MXN` = `150000` integer) o acompañados de su código ISO 4217 (`MXN`, `USD`, `EUR`) para evitar cualquier error de redondeo de punto flotante.
2. **Fechas Estrictas**:
   - `timestamp` UTC para eventos puntuales (`createdAt`, `updatedAt`, `purchaseDate`).
   - `YYYY-MM-DD` (ISO 8601 String) para fechas de corte y límites de pago independientes de la zona horaria del usuario.
   - `dayOfMonth` (1 a 31) para reglas periódicas de corte y pago.
3. **Aislamiento Multiusuario**: En Cloud Firestore, todas las colecciones de usuario residen bajo `/users/{userId}/...` asegurando que las reglas de seguridad protejan estrictamente los datos de cada titular.
4. **Desnormalización Controlada**: Datos críticos para visualización rápida (alias de tarjeta, logo/color de emisor, nombre del banco) se duplican en las compras y recomendaciones para evitar lecturas de N+1 documentos.

---

## 2. Colecciones y Documentos

### 2.1. Colección `/users/{userId}`
Contiene el perfil y las configuraciones maestras del usuario.

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | String | UID de Firebase Authentication |
| `email` | String | Correo electrónico principal |
| `displayName` | String | Nombre para saludos y perfil |
| `currency` | String | Moneda por defecto (ej. `MXN`) |
| `timezone` | String | Zona horaria IANA (ej. `America/Mexico_City`) |
| `preferences` | Map | Preferencias del usuario (priorizar cashback vs días de crédito) |
| `notificationSettings` | Map | Configuración de recordatorios (días de anticipación, hora) |
| `createdAt` | Timestamp | Fecha de creación de cuenta |
| `updatedAt` | Timestamp | Última modificación |

```json
{
  "id": "usr_99812",
  "email": "usuario@ejemplo.com",
  "displayName": "Alex Rivera",
  "currency": "MXN",
  "timezone": "America/Mexico_City",
  "preferences": {
    "primaryGoal": "maximize_rewards",
    "minCreditGraceDays": 20,
    "notifyPaymentDaysBefore": 3
  },
  "notificationSettings": {
    "closingDateAlerts": true,
    "paymentDueDateAlerts": true,
    "promotionsAlerts": true,
    "preferredHour": 9
  },
  "createdAt": "2026-09-01T12:00:00Z",
  "updatedAt": "2026-09-28T20:00:00Z"
}
```

---

### 2.2. Subcolección `/users/{userId}/cards/{cardId}`
Tarjetas de crédito o débito registradas por el usuario.

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | String | Identificador único de la tarjeta del usuario |
| `userId` | String | Propietario de la tarjeta |
| `issuerId` | String | ID del emisor (ej. `iss_nu`, `iss_bbva`) |
| `productId` | String | ID del producto del catálogo (opcional) |
| `issuerName` | String | Nombre del banco o institución |
| `productName` | String | Nombre comercial de la tarjeta |
| `alias` | String | Nombre personalizado asignado por el usuario |
| `type` | String | `credit`, `debit` |
| `last4` | String | Últimos 4 dígitos (opcional, longitud max: 4) |
| `currency` | String | Código de moneda (ej. `MXN`) |
| `creditLimitCents` | Integer | Límite total en centavos (ej. `5000000` = $50,000.00) |
| `currentBalanceCents` | Integer | Saldo utilizado actualmente |
| `availableCreditCents` | Integer | Crédito disponible confirmado o derivado |
| `statementClosingDay` | Integer | Día del mes en que corta (1..31) |
| `paymentDueDay` | Integer | Día del mes límite de pago (1..31) |
| `daysBetweenCutoffAndDue` | Integer | Días de gracia fijos si la entidad usa regla de +20 días |
| `adjustForHolidays` | Boolean | Si aplica corrimiento por fin de semana o día festivo |
| `benefits` | Array[Map] | Lista de beneficios y porcentajes de cashback activos |
| `colorHex` | String | Código de color para renderizar en UI (ej. `#8A05BE`) |
| `status` | String | `active`, `paused`, `archived` |
| `verificationStatus` | String | `confirmed`, `estimated` |
| `createdAt` | Timestamp | Timestamp de registro |
| `updatedAt` | Timestamp | Timestamp de última actualización |

---

### 2.3. Subcolección `/users/{userId}/purchases/{purchaseId}`
Registro manual o simulado de compras.

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | String | UUID de la transacción |
| `userId` | String | Propietario |
| `cardId` | String | ID de la tarjeta empleada |
| `cardAlias` | String | Alias de la tarjeta para visualización rápida |
| `amountCents` | Integer | Importe en centavos |
| `currency` | String | Moneda |
| `category` | String | Categoría (`supermarket`, `dining`, `fuel`, `travel`, `online`, etc.) |
| `description` | String | Concepto o notas |
| `merchant` | String | Nombre del comercio |
| `purchaseDate` | String | Fecha ISO `YYYY-MM-DD` |
| `billingCycleId` | String | Identificador del ciclo asignado (`YYYY-MM-cardId`) |
| `estimatedRewardCents` | Integer | Recompensa estimada calculada |
| `status` | String | `recorded`, `settled`, `cancelled` |
| `createdAt` | Timestamp | Timestamp de creación |

---

### 2.4. Subcolección `/users/{userId}/loans/{loanId}`
Préstamos personales, automotrices o hipotecarios.

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | String | Identificador del préstamo |
| `userId` | String | Propietario |
| `name` | String | Nombre descriptivo (ej. "Préstamo Auto") |
| `lender` | String | Institución prestamista |
| `originalAmountCents` | Integer | Monto original prestado |
| `outstandingBalanceCents` | Integer | Saldo insoluto pendiente |
| `interestRateAnnual` | Double | Tasa de interés anual (ej. `18.5`) |
| `paymentAmountCents` | Integer | Monto de la cuota periódica |
| `paymentFrequency` | String | `monthly`, `biweekly`, `weekly` |
| `nextPaymentDate` | String | Fecha del próximo pago `YYYY-MM-DD` |
| `status` | String | `active`, `paid_off`, `overdue` |
| `notes` | String | Notas adicionales |

---

### 2.5. Colección Pública `/catalog_issuers` y `/catalog_products`
Catálogo de instituciones y productos financieros del mercado (lectura pública, escritura solo administradores).

* `/catalog_issuers/{issuerId}`:
  - `id`: `iss_nu`
  - `name`: `Nu México`
  - `country`: `MX`
  - `logoUrl`: Referencia o asset icon
  - `website`: URL oficial

* `/catalog_products/{productId}`:
  - `id`: `prod_nu_credit`
  - `issuerId`: `iss_nu`
  - `name`: `Tarjeta de Crédito Nu`
  - `type`: `credit`
  - `defaultDaysAfterCutoff`: 10
  - `benefits`:
    - `[ { "category": "all", "rewardRate": 0.0, "type": "cashback" } ]`
  - `annualFeeCents`: 0
  - `termsUrl`: Enlace a términos y condiciones oficiales
