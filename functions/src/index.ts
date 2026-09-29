import * as admin from 'firebase-admin';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { processDailyReminders } from './modules/notifications/reminders';

admin.initializeApp();

/**
 * Tarea programada diaria (ejecutada cada mañana a las 09:00 UTC)
 * Envía notificaciones de corte y pago a usuarios con preferencias activas
 */
export const dailyReminderJob = onSchedule(
  {
    schedule: '0 9 * * *',
    timeZone: 'America/Mexico_City',
    retryCount: 2,
  },
  async () => {
    const result = await processDailyReminders();
    console.log(`[DailyReminders] Evaluadas ${result.processedCount} tarjetas. Notificaciones enviadas: ${result.notificationsSent}`);
  }
);

/**
 * Trigger al registrar una nueva compra:
 * Actualiza el balance acumulado y recalcula estadísticas de gasto en el perfil
 */
export const onPurchaseCreated = onDocumentCreated(
  'users/{userId}/purchases/{purchaseId}',
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const purchase = snap.data();
    const userId = event.params.userId;
    const db = admin.firestore();

    // Actualizar métricas acumuladas en el usuario
    const userRef = db.doc(`users/${userId}`);
    await userRef.set(
      {
        totalPurchasesRecorded: admin.firestore.FieldValue.increment(1),
        totalRewardEarnedCents: admin.firestore.FieldValue.increment(purchase.estimatedRewardCents || 0),
        lastActivityAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  }
);
