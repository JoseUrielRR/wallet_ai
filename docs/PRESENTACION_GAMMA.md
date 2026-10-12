# PRESENTACIÓN EJECUTIVA: WALLET AI
## Optimización Inteligente de Tarjetas de Crédito, Beneficios y Ciclos de Facturación en la Nube
### Materia: Diseño y Evaluación de Interfaces de Usuario
### Tecnológico Nacional de México - Instituto Tecnológico de Tijuana

> **Instrucciones para Gamma.app**:
> 1. Abre [gamma.app](https://gamma.app) y selecciona **"New from text"** / **"Paste in text"**.
> 2. Selecciona el formato **"Presentation"** (Diapositivas).
> 3. Copia y pega el contenido que se encuentra a continuación (cada sección separada por `---` generará una diapositiva individual).
> 4. Elige un tema visual oscuro estilo Fintech / Tech (ej. "Terminal", "Nebula", "Onyx" o "Emerald").

---

# TECNOLÓGICO NACIONAL DE MÉXICO
## INSTITUTO TECNOLÓGICO DE TIJUANA

**SUBDIRECCIÓN ACADÉMICA**  
**DEPARTAMENTO DE SISTEMAS Y COMPUTACIÓN**  

* **Carrera**: Ingeniería en Sistemas Computacionales  
* **Materia**: Diseño y Evaluación de Interfaces de Usuario  
* **Proyecto**: Wallet AI (Diseño, Arquitectura de Interfaz y Evaluación)  
* **Alumno**: Uriel Rodríguez (Número de Control: [Tu Número de Control])  
* **Periodo**: Septiembre - Noviembre 2026  

---

# Wallet AI
### SOFTWARE EN LA NUBE PARA LA OPTIMIZACIÓN INTELIGENTE DE TARJETAS DE CRÉDITO Y BENEFICIOS FINANCIEROS

* **Plataforma**: Cloud Web & Mobile (Flutter + Firebase Serverless)
* **Paradigma**: Zero-Knowledge Financial Privacy & Offline-First
* **Pregunta Central**: *"¿Qué tarjeta me conviene utilizar hoy y por qué?"*

---

# PROPUESTA

Plataforma inteligente en la nube que actúa como un **copiloto financiero proactivo**, calculando en tiempo real la combinación óptima entre **días de financiamiento sin intereses** y **retorno de recompensas (cashback y puntos)** para cada compra del usuario.

### Pilares de la Solución:
* **Copiloto Estratégico**: Reemplaza el seguimiento manual pasivo por recomendaciones algorítmicas deterministas en tiempo real.
* **Máxima Privacidad (Zero-Knowledge)**: Sin contraseñas bancarias, tokens móviles ni números de tarjeta completos (PAN/CVV).
* **Visión Unificada Multibanco**: Tarjetas de crédito, débito y préstamos personales consolidados en un único tablero interactivo.
* **Operación Híbrida Cloud + Offline**: Disponibilidad total aún sin cobertura de red en el punto de venta.

---

# JUSTIFICACIÓN

La gestión de finanzas personales contemporánea enfrenta una fragmentación crítica entre emisores bancarios y plataformas fintech:

* **Desconocimiento de Ciclos de Facturación**: Los usuarios desaprovechan hasta 50 días de financiamiento libre de intereses por comprar antes de sus fechas de corte.
* **Pérdida de Recompensas y Cashback**: Las reglas de beneficios por categoría son complejas y dispersas; el usuario promedio paga con el plástico equivocado perdiendo valor directo.
* **Estrés Financiero y Riesgo de Mora**: Cargos por pago tardío e intereses moratorios provocados por olvidos involuntarios de fechas límite de pago.
* **Barrera de Confianza en Apps Tradicionales**: Las herramientas agregadoras tradicionales exigen credenciales de banca electrónica vulnerables; Wallet AI elimina esa fricción mediante un modelo de conocimiento cero.

---

# OBJETIVO GENERAL

Desarrollar una plataforma en la nube con una **interfaz de usuario reactiva, accesible e intuitiva** que centralice y optimice la gestión de tarjetas de crédito y préstamos, transformando reglas complejas de facturación en **recomendaciones deterministas en tiempo real**, maximizando el ahorro y la liquidez sin comprometer credenciales bancarias.

---

# OBJETIVOS ESPECÍFICOS (PARTE 1)

### 01. Diseñar Interfaz Moderna e Intuitiva
Crear una experiencia minimalista orientada al bienestar financiero bajo **Material Design 3**, cumpliendo con estándares de accesibilidad **WCAG 2.1 nivel AA** y navegación fluida a 60 FPS.

### 02. Gestión Digital de Billetera
Implementar un módulo integral (CRUD) para tarjetas y préstamos personales con catálogos preconfigurados de instituciones bancarias (Nu, BBVA, Amex, Santander, etc.).

### 03. Motor de Recomendación en Tiempo Real
Desarrollar el algoritmo financiero determinista que identifica la tarjeta óptima del día y la presenta destacada en el **Hero Card** del Dashboard con su justificación matemática.

### 04. Simulador de Compras en Caja
Integrar un simulador instantáneo ("Smart Purchase") que clasifica las tarjetas según cashback neto y días de gracia libres para un importe y categoría específicos.

---

# OBJETIVOS ESPECÍFICOS (PARTE 2)

### 05. Calendario Financiero y Prevención de Mora
Implementar un calendario visual interactivo con codificación cromática (cortes, fechas límite de pago y amortizaciones) para eliminar recargos e intereses moratorios.

### 06. Seguridad Cloud de Conocimiento Cero
Asegurar la soberanía de datos del usuario mediante reglas estrictas en **Cloud Firestore** (`request.auth.uid == userId`) y enmascaramiento visual de plásticos (`•••• 1234`).

### 07. Resiliencia y Disponibilidad en la Nube
Garantizar una disponibilidad del **99.9%** mediante Firebase Serverless y persistencia local en caché para permitir operación continua en modo **Offline-First**.

### 08. Plan Riguroso de Evaluación de Interfaz
Ejecutar una auditoría de **Evaluación Heurística (10 principios de Nielsen)** y pruebas empíricas con usuarios reales, persiguiendo un puntaje superior a **80 puntos en la escala SUS**.

---

# ANÁLISIS DE USUARIOS (UX RESEARCH)

| Perfil de Usuario | Demografía y Contexto | Necesidad Principal | Frustración Crítica |
| :--- | :--- | :--- | :--- |
| **Alex: El Maximizador** | 27 años, Desarrollador, Tech Power-User, 4 tarjetas activas | Exprimir cada punto y cashback por categoría | Olvidar promociones y qué tarjeta usar en cada comercio |
| **Mariana: La Emprendedora** | 38 años, Dueña de Negocio, 3 tarjetas y 1 préstamo | Financiar compras de inventario a 50 días sin intereses | Pagar intereses moratorios por cortes cruzados |
| **Carlos: El Consolidador** | 45 años, Contador y Padre de Familia, perfil conservador | Control estricto de deudas globales y crédito disponible | Miedo a dar contraseñas bancarias a apps de terceros |

---

# ARQUITECTURA DE INFORMACIÓN Y NAVEGACIÓN

```
[ Splash / Verificación de Sesión ]
      │
      ├──> [ Login / Registro / Recuperación ] (Firebase Auth)
      │
      └──> [ App Shell de Navegación Persistente ]
            ├── 1. Dashboard (Hero Card: Recomendación Diaria + Métricas de Liquidez)
            ├── 2. Billetera Virtual (Mis Tarjetas + Mis Préstamos + Alta CRUD)
            ├── 3. Calendario Financiero (Cortes, Fechas Límite y Vencimientos)
            ├── 4. Actividad (Historial de Compras y Pagos Registrados)
            └── 5. Perfil y Ajustes (Modo Demo / Cloud, Tema Oscuro/Claro, Logout)
```

* **Flujos Modales Rápidos**: Simulador de compra inmediata en 2 toques, marcaje de pago rápido y vista flip de tarjetas.

---

# DISEÑO DE LA INTERFAZ / PROTOTIPO

### Especificaciones del Prototipo de Alta Fidelidad en Flutter:
* **Dashboard Hero Card**: Tarjeta virtual interactiva con gradientes dinámicos del banco, cálculo en vivo de días libres y botón de simulación rápida.
* **Billetera Segmentada**: Indicadores circulares y lineales del progreso de corte y nivel de utilización del crédito con semáforos suaves.
* **Calendario Cromático**:
  * 🔵 Azul: Fecha de Corte bancario.
  * 🟠 Ámbar: Fecha Límite de Pago (<3 días restantes).
  * 🟣 Morado: Cuota programada de préstamo.
* **Simulador de Compra**: Selector táctil de categoría comercial con cálculo instantáneo de cashback en pesos mexicanos.

---

# PLAN DE EVALUACIÓN DE LA INTERFAZ

### 1. Evaluación Heurística (Jakob Nielsen)
* Inspección técnica por expertos basada en los **10 principios heurísticos de Nielsen**.
* Clasificación de severidad de problemas: 0 (Sin problema), 1 (Cosmético), 2 (Menor), 3 (Mayor), 4 (Catastrófico).

### 2. Pruebas de Usabilidad con Usuarios Reales
* Muestra de 6 a 8 usuarios ejecutando 5 tareas clave (Registro, Alta de tarjeta, Consulta de recomendación, Simulación de compra y Calendario).
* **Métricas Clave de Rendimiento**:
  * **Tasa de Éxito de Tareas (TSR)**: Meta $\ge 90\%$
  * **Tiempo en Tarea (Time on Task)**: Meta $< 60\text{ s}$ en tareas principales
  * **Tasa de Errores**: Menos de $0.5$ errores promedio por usuario
  * **Escala de Usabilidad SUS**: Meta $> 80\text{ puntos}$ (Grado A - Excelente)

---

# CRONOGRAMA DE TRABAJO (11 SEMANAS)

* **Semanas 1 - 2 (14 Sep - 27 Sep)**: Definición del problema, justificación, UX Research, Benchmarking y Wireframes de baja fidelidad. *(Completado)*
* **Semanas 3 - 4 (28 Sep - 11 Oct)**: Arquitectura en la nube, Cloud Firestore, Firebase Auth, Prototipo interactivo en Flutter y 33 pruebas unitarias. *(Completado / En curso)*
* **Semanas 5 - 6 (12 Oct - 25 Oct)**: Motores de recomendación y simulador, Calendario financiero interactivo y ajuste responsivo (móvil, tablet, web).
* **Semanas 7 - 8 (26 Oct - 08 Nov)**: Auditoría de Evaluación Heurística de Nielsen e implementación de correcciones UI/UX prioritarias.
* **Semanas 9 - 10 (09 Nov - 22 Nov)**: Ejecución de pruebas con usuarios reales y levantamiento de métricas cuantitativas (TSR, ToT y encuesta SUS).
* **Semana 11 (23 Nov - 27 Nov)**: Análisis estadístico, consolidación del reporte final de evaluación y **Presentación Ejecutiva del Proyecto (27 de Noviembre)**.

---

# GRACIAS POR SU ATENCIÓN

### Wallet AI
*Optimizador Inteligente de Tarjetas de Crédito y Ciclos de Facturación en la Nube*

**¿Preguntas o comentarios?**
* **Repositorio**: Flutter 3.x + Firebase Serverless
* **Contacto**: Uriel Rodríguez
* **Instituto Tecnológico de Tijuana - TecNM**
