# Wallet AI - Security & Privacy Plan

## 1. Principio Rector: Zero-Knowledge de Credenciales Financieras

Wallet AI es un **optimizador de reglas y fechas**, NO un agregador de transferencias o pasarela de pago:
1. **NUNCA se solicita, transmite ni almacena**:
   - El número completo de 16 dígitos de la tarjeta (Primary Account Number - PAN).
   - El código de seguridad valor de verificación (CVV / CVC).
   - El Número de Identificación Personal (NIP / PIN).
   - Contraseñas o credenciales de banca electrónica / token móvil.
2. **Datos Permitidos de Tarjeta**:
   - Nombre de la institución y producto (ej. "Nu", "BBVA Oro").
   - Alias amigable asignado por el usuario (ej. "Mi Moradita").
   - Últimos 4 dígitos opcionales (exclusivamente para que el usuario identifique físicamente su plástico).
   - Límite de crédito, saldo aproximado y reglas de fechas (día de corte y pago).

---

## 2. Seguridad en Base de Datos (Cloud Firestore Rules)

### 2.1. Política de Acceso: Denegación por Defecto
El acceso no autenticado o el acceso transversal entre cuentas de usuario está completamente bloqueado a nivel de motor de base de datos en `firebase/firestore.rules`.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Función de ayuda para verificar autenticación y propiedad
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }

    // Regla de usuario: solo el propio usuario puede leer y escribir sus datos
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      // Subcolecciones privadas (cards, purchases, loans, notifications)
      match /{allSubcollections=**} {
        allow read, write: if isOwner(userId);
      }
    }

    // Catálogos públicos del mercado (lectura libre para autenticados, escritura bloqueada)
    match /catalog_issuers/{issuerId} {
      allow read: if request.auth != null;
      allow write: if false; // Solo mediante script administrativo con Service Account
    }

    match /catalog_products/{productId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // Denegación explícita para cualquier otra ruta
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 3. Gestión de Secretos y Variables de Entorno

* No se incluye ningún archivo `.env` real, clave de API privada ni archivo `google-services.json` / `GoogleService-Info.plist` con credenciales de producción en el repositorio de control de versiones.
* Se provee `.env.example` con la estructura documentada.
* Para el desarrollo y pruebas locales, el sistema opera con el `LocalDemoDataSource` sin requerir credenciales externas.

---

## 4. Sanitización y Validación de Entradas

1. **Montos Monetarios**:
   - Validación estricta de valores positivos.
   - Conversión a centavos enteros (`int`) antes de cualquier persistencia para erradicar errores de precisión y ataques de desbordamiento decimal.
2. **Días de Corte y Pago**:
   - Rango forzado de $1 \le \text{día} \le 31$.
   - Normalización de fin de mes documentada en `docs/BUSINESS_RULES.md`.
3. **Validación de Texto**:
   - Escape de cadenas en alias y notas para prevenir inyecciones.
   - Longitud máxima restringida en campos de texto (alias max 40 caracteres, notas max 500).

---

## 5. Auditoría de Logs y Manejo Seguro de Errores

* Las trazas de depuración (`debugPrint` / `Logger`) nunca imprimirán datos financieros agregados ni identificadores personales en consolas no protegidas.
* Los mensajes de error mostrados al usuario son informativos pero genéricos ("No fue posible guardar la tarjeta. Por favor verifica tu conexión."), previniendo fuga de detalles internos del backend o stack traces.

---

## 6. Política de Eliminación de Datos (Derecho al Olvido)

* El usuario tiene acceso directo en `Perfil > Privacidad y Datos` a:
  1. **Restablecer Billetera**: Elimina todas sus tarjetas, préstamos y compras de forma inmediata.
  2. **Eliminar Cuenta Completa**: Borrado en cascada de su documento de usuario en Firestore y eliminación de su registro en Firebase Authentication.
