import * as admin from 'firebase-admin';
import { createNormalizedDate, adjustForWeekend } from '../billing/billing-cycle';

export async function processDailyReminders(): Promise<{ processedCount: number; notificationsSent: number }> {
  const db = admin.firestore();
  const messaging = admin.messaging();
  const now = new Date();
  const todayUtc = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));

  let processedCount = 0;
  let notificationsSent = 0;

  // Consultar usuarios con notificaciones activas
  const usersSnapshot = await db.collection('users').get();

  for (const userDoc of usersSnapshot.docs) {
    const userData = userDoc.data();
    const userId = userDoc.id;
    const notificationSettings = userData.notificationSettings || {};
    const fcmToken = userData.fcmToken;

    if (!fcmToken) continue;

    const cardsSnapshot = await db.collection(`users/${userId}/cards`).where('status', '==', 'active').get();

    for (const cardDoc of cardsSnapshot.docs) {
      processedCount++;
      const card = cardDoc.data();
      if (card.type !== 'credit') continue;

      const closingDay = card.statementClosingDay || 15;
      const paymentDay = card.paymentDueDay || 5;

      const closingDate = createNormalizedDate(todayUtc.getUTCFullYear(), todayUtc.getUTCMonth() + 1, closingDay);
      let paymentDueDate = createNormalizedDate(todayUtc.getUTCFullYear(), todayUtc.getUTCMonth() + 1, paymentDay);
      if (card.adjustForHolidays) {
        paymentDueDate = adjustForWeekend(paymentDueDate);
      }

      const diffDaysCutoff = Math.round((closingDate.getTime() - todayUtc.getTime()) / (1000 * 60 * 60 * 24));
      const diffDaysPayment = Math.round((paymentDueDate.getTime() - todayUtc.getTime()) / (1000 * 60 * 60 * 24));

      // 1. Recordatorio de Corte (1 día antes)
      if (notificationSettings.closingDateAlerts && diffDaysCutoff === 1) {
        const deduplicationKey = `cutoff_${card.id}_${closingDate.toISOString().slice(0, 10)}`;
        const notifRef = db.doc(`users/${userId}/notifications/${deduplicationKey}`);
        const exists = (await notifRef.get()).exists;

        if (!exists) {
          await messaging.send({
            token: fcmToken,
            notification: {
              title: `Corte Mañana: ${card.alias || card.productName}`,
              body: `Tu tarjeta corta mañana. Si postergas compras grandes 2 días, obtendrás hasta 45 días de crédito libre.`,
            },
          });
          await notifRef.set({
            title: `Corte Mañana: ${card.alias || card.productName}`,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            status: 'sent',
          });
          notificationsSent++;
        }
      }

      // 2. Recordatorio de Pago (3 días antes)
      const alertDays = userData.preferences?.notifyPaymentDaysBefore || 3;
      if (notificationSettings.paymentDueDateAlerts && diffDaysPayment === alertDays) {
        const deduplicationKey = `payment_${card.id}_${paymentDueDate.toISOString().slice(0, 10)}`;
        const notifRef = db.doc(`users/${userId}/notifications/${deduplicationKey}`);
        const exists = (await notifRef.get()).exists;

        if (!exists) {
          await messaging.send({
            token: fcmToken,
            notification: {
              title: `Pago Próximo: ${card.alias || card.productName}`,
              body: `Tu fecha límite de pago es en ${diffDaysPayment} días. Liquida tu saldo para evitar intereses.`,
            },
          });
          await notifRef.set({
            title: `Pago Próximo: ${card.alias || card.productName}`,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            status: 'sent',
          });
          notificationsSent++;
        }
      }
    }
  }

  return { processedCount, notificationsSent };
}
