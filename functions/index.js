const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

/**
 * Triggered when a new document is created in the "vaccine_alerts" collection.
 * Sends a push notification to all devices subscribed to the "vaccine_alerts" topic.
 */
exports.sendAlertNotification = onDocumentCreated(
  "vaccine_alerts/{alertId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log("No data in snapshot");
      return;
    }

    const data = snapshot.data();
    const title = data.title || "تنبيه جديد";
    const message = data.message || "";
    const severity = data.severity || "info";
    const vaccineName = data.vaccineName || "";
    const isActive = data.isActive !== undefined ? data.isActive : true;

    // Only send notification for active alerts
    if (!isActive) {
      console.log("Alert is not active, skipping notification.");
      return;
    }

    // Build the notification payload
    const notification = {
      title: title,
      body: message.length > 200 ? message.substring(0, 200) + "..." : message,
    };

    // Additional data payload (accessible in the app)
    const dataPayload = {
      alertId: event.params.alertId,
      severity: severity,
      vaccineName: vaccineName,
      type: "vaccine_alert",
    };

    const fcmMessage = {
      topic: "vaccine_alerts",
      notification: notification,
      data: dataPayload,
      android: {
        priority: "high",
        notification: {
          channelId: "vaccine_alerts_channel",
          priority: "high",
          defaultSound: true,
          defaultVibrateTimings: true,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: notification.title,
              body: notification.body,
            },
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    try {
      const response = await getMessaging().send(fcmMessage);
      console.log(
        `✅ Notification sent successfully for alert "${title}": ${response}`
      );
    } catch (error) {
      console.error("❌ Error sending notification:", error);
    }
  }
);

