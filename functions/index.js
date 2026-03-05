const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { defineSecret } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");
const nodemailer = require("nodemailer");

initializeApp();

// ── Gmail SMTP credentials (set via: firebase functions:secrets:set GMAIL_EMAIL / GMAIL_APP_PASSWORD) ──
const gmailEmail = defineSecret("GMAIL_EMAIL");
const gmailAppPassword = defineSecret("GMAIL_APP_PASSWORD");
// The admin email that receives support tickets
const supportReceiver = defineSecret("SUPPORT_RECEIVER_EMAIL");

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
          channelId: "vaccine_alerts_channel_v2",
          priority: "high",
          sound: "alert_sound",
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
            sound: "alert_sound.wav",
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

/**
 * Triggered when a new document is created in the "support_tickets" collection.
 * Sends an email to the support/admin email with the ticket details,
 * and a confirmation email to the user.
 */
exports.sendSupportTicketEmail = onDocumentCreated(
  {
    document: "support_tickets/{ticketId}",
    secrets: [gmailEmail, gmailAppPassword, supportReceiver],
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log("No data in snapshot");
      return;
    }

    const data = snapshot.data();
    const ticketId = event.params.ticketId;
    const userName = data.fullName || "مستخدم";
    const userEmail = data.email || "";
    const subject = data.subject || "بدون موضوع";
    const message = data.message || "";
    const createdAt = data.createdAt
      ? data.createdAt.toDate().toLocaleString("ar-EG", {
          dateStyle: "long",
          timeStyle: "short",
        })
      : new Date().toLocaleString("ar-EG");

    // Create reusable transporter using Gmail SMTP
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: gmailEmail.value(),
        pass: gmailAppPassword.value(),
      },
    });

    // ── Email to Admin/Support ──
    const adminMailOptions = {
      from: `"VaxGuide Support" <${gmailEmail.value()}>`,
      to: supportReceiver.value(),
      subject: `🎫 تذكرة دعم جديدة: ${subject}`,
      html: `
        <div dir="rtl" style="font-family: 'Segoe UI', Tahoma, Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #f8f9fa; border-radius: 12px; overflow: hidden;">
          <div style="background: linear-gradient(135deg, #0D3B66, #2980B9); padding: 24px; text-align: center;">
            <h1 style="color: white; margin: 0; font-size: 22px;">💉 VaxGuide</h1>
            <p style="color: #B3D7EE; margin: 8px 0 0; font-size: 14px;">تذكرة دعم جديدة</p>
          </div>
          <div style="padding: 24px;">
            <table style="width: 100%; border-collapse: collapse; margin-bottom: 16px;">
              <tr>
                <td style="padding: 10px 12px; background: #e9ecef; border-radius: 8px 8px 0 0; font-weight: bold; color: #495057;">رقم التذكرة</td>
                <td style="padding: 10px 12px; background: #e9ecef; border-radius: 8px 8px 0 0; color: #0D3B66; font-family: monospace;">${ticketId}</td>
              </tr>
              <tr>
                <td style="padding: 10px 12px; border-bottom: 1px solid #dee2e6; font-weight: bold; color: #495057;">الاسم</td>
                <td style="padding: 10px 12px; border-bottom: 1px solid #dee2e6;">${userName}</td>
              </tr>
              <tr>
                <td style="padding: 10px 12px; border-bottom: 1px solid #dee2e6; font-weight: bold; color: #495057;">البريد الإلكتروني</td>
                <td style="padding: 10px 12px; border-bottom: 1px solid #dee2e6;"><a href="mailto:${userEmail}">${userEmail}</a></td>
              </tr>
              <tr>
                <td style="padding: 10px 12px; border-bottom: 1px solid #dee2e6; font-weight: bold; color: #495057;">التاريخ</td>
                <td style="padding: 10px 12px; border-bottom: 1px solid #dee2e6;">${createdAt}</td>
              </tr>
              <tr>
                <td style="padding: 10px 12px; font-weight: bold; color: #495057;">الموضوع</td>
                <td style="padding: 10px 12px; font-weight: bold; color: #0D3B66;">${subject}</td>
              </tr>
            </table>
            <div style="background: white; border: 1px solid #dee2e6; border-radius: 8px; padding: 16px; margin-top: 8px;">
              <p style="margin: 0 0 8px; font-weight: bold; color: #495057;">الرسالة:</p>
              <p style="margin: 0; color: #212529; line-height: 1.7; white-space: pre-wrap;">${message}</p>
            </div>
            <p style="margin-top: 16px; text-align: center; color: #6c757d; font-size: 12px;">
              يمكنك الرد مباشرة على البريد الإلكتروني للمستخدم: <a href="mailto:${userEmail}">${userEmail}</a>
            </p>
          </div>
        </div>
      `,
    };

    // ── Confirmation email to User ──
    const userMailOptions = {
      from: `"VaxGuide Support" <${gmailEmail.value()}>`,
      to: userEmail,
      subject: `✅ تم استلام رسالتك - ${subject}`,
      html: `
        <div dir="rtl" style="font-family: 'Segoe UI', Tahoma, Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #f8f9fa; border-radius: 12px; overflow: hidden;">
          <div style="background: linear-gradient(135deg, #0D3B66, #2980B9); padding: 24px; text-align: center;">
            <h1 style="color: white; margin: 0; font-size: 22px;">💉 VaxGuide</h1>
            <p style="color: #B3D7EE; margin: 8px 0 0; font-size: 14px;">تأكيد استلام الرسالة</p>
          </div>
          <div style="padding: 24px;">
            <p style="color: #212529; font-size: 16px; margin-bottom: 16px;">مرحباً <strong>${userName}</strong>،</p>
            <p style="color: #495057; line-height: 1.7;">
              شكراً لتواصلك معنا. تم استلام رسالتك بنجاح وسنقوم بمراجعتها والرد عليك في أقرب وقت ممكن.
            </p>
            <div style="background: white; border: 1px solid #dee2e6; border-radius: 8px; padding: 16px; margin: 16px 0;">
              <p style="margin: 0 0 4px; font-weight: bold; color: #495057; font-size: 13px;">الموضوع:</p>
              <p style="margin: 0 0 12px; color: #0D3B66; font-weight: bold;">${subject}</p>
              <p style="margin: 0 0 4px; font-weight: bold; color: #495057; font-size: 13px;">رقم التذكرة:</p>
              <p style="margin: 0; color: #6c757d; font-family: monospace;">${ticketId}</p>
            </div>
            <p style="color: #6c757d; font-size: 13px; line-height: 1.6;">
              إذا كانت لديك أي استفسارات إضافية، يمكنك الرد على هذا البريد أو إرسال رسالة جديدة من خلال التطبيق.
            </p>
            <hr style="border: none; border-top: 1px solid #dee2e6; margin: 20px 0;" />
            <p style="text-align: center; color: #adb5bd; font-size: 11px; margin: 0;">
              فريق دعم VaxGuide &copy; ${new Date().getFullYear()}
            </p>
          </div>
        </div>
      `,
    };

    try {
      // Send both emails in parallel
      const [adminResult, userResult] = await Promise.all([
        transporter.sendMail(adminMailOptions),
        userEmail ? transporter.sendMail(userMailOptions) : Promise.resolve(null),
      ]);

      console.log(`✅ Admin email sent: ${adminResult.messageId}`);
      if (userResult) {
        console.log(`✅ User confirmation email sent: ${userResult.messageId}`);
      }
    } catch (error) {
      console.error("❌ Error sending support ticket email:", error);
    }
  }
);

/**
 * Triggered when a support ticket is updated.
 * If adminReply was added/changed, sends the reply to the user via email.
 */
exports.sendReplyEmail = onDocumentUpdated(
  {
    document: "support_tickets/{ticketId}",
    secrets: [gmailEmail, gmailAppPassword],
  },
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    // Only send email if adminReply was added or changed
    const oldReply = before.adminReply || "";
    const newReply = after.adminReply || "";
    if (!newReply || newReply === oldReply) {
      return;
    }

    const userName = after.fullName || "مستخدم";
    const userEmail = after.email || "";
    const subject = after.subject || "تذكرة الدعم";
    const ticketId = event.params.ticketId;
    const status = after.status || "in_progress";

    if (!userEmail) {
      console.log("No user email, skipping reply email.");
      return;
    }

    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: gmailEmail.value(),
        pass: gmailAppPassword.value(),
      },
    });

    const statusLabel =
      status === "resolved"
        ? "✅ تم الحل"
        : status === "in_progress"
        ? "⏳ قيد المعالجة"
        : "📋 مفتوح";

    const mailOptions = {
      from: `"VaxGuide Support" <${gmailEmail.value()}>`,
      to: userEmail,
      subject: `💬 رد على تذكرتك: ${subject}`,
      html: `
        <div dir="rtl" style="font-family: 'Segoe UI', Tahoma, Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #f8f9fa; border-radius: 12px; overflow: hidden;">
          <div style="background: linear-gradient(135deg, #0D3B66, #2980B9); padding: 24px; text-align: center;">
            <h1 style="color: white; margin: 0; font-size: 22px;">💉 VaxGuide</h1>
            <p style="color: #B3D7EE; margin: 8px 0 0; font-size: 14px;">رد من فريق الدعم</p>
          </div>
          <div style="padding: 24px;">
            <p style="color: #212529; font-size: 16px; margin-bottom: 16px;">مرحباً <strong>${userName}</strong>،</p>
            <p style="color: #495057; line-height: 1.7; margin-bottom: 16px;">
              تم الرد على تذكرتك بخصوص: <strong>"${subject}"</strong>
            </p>

            <div style="background: white; border: 1px solid #dee2e6; border-radius: 8px; padding: 16px; margin-bottom: 16px;">
              <p style="margin: 0 0 4px; font-weight: bold; color: #495057; font-size: 12px;">رسالتك:</p>
              <p style="margin: 0; color: #6c757d; font-size: 13px; line-height: 1.5; border-right: 3px solid #dee2e6; padding-right: 12px;">${after.message || ""}</p>
            </div>

            <div style="background: #e8f5e9; border: 1px solid #a5d6a7; border-radius: 8px; padding: 16px; margin-bottom: 16px;">
              <p style="margin: 0 0 4px; font-weight: bold; color: #2e7d32; font-size: 12px;">رد فريق الدعم:</p>
              <p style="margin: 0; color: #1b5e20; font-size: 14px; line-height: 1.7; white-space: pre-wrap;">${newReply}</p>
            </div>

            <div style="text-align: center; margin-bottom: 16px;">
              <span style="display: inline-block; background: #e3f2fd; color: #0D3B66; padding: 6px 16px; border-radius: 20px; font-size: 13px; font-weight: bold;">
                حالة التذكرة: ${statusLabel}
              </span>
            </div>

            <p style="color: #6c757d; font-size: 13px; line-height: 1.6;">
              إذا كانت لديك أي استفسارات إضافية، يمكنك إرسال رسالة جديدة من خلال التطبيق.
            </p>
            <hr style="border: none; border-top: 1px solid #dee2e6; margin: 20px 0;" />
            <p style="text-align: center; color: #adb5bd; font-size: 11px; margin: 0;">
              فريق دعم VaxGuide &copy; ${new Date().getFullYear()}
            </p>
          </div>
        </div>
      `,
    };

    try {
      const result = await transporter.sendMail(mailOptions);
      console.log(`✅ Reply email sent to ${userEmail}: ${result.messageId}`);
    } catch (error) {
      console.error("❌ Error sending reply email:", error);
    }
  }
);

