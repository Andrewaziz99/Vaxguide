import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// One-time script to seed the Firestore 'vaccine_alerts' collection with sample data.
/// Call [seedAlerts] once, then remove or disable it.
Future<void> seedAlerts() async {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('vaccine_alerts');

  final now = DateTime.now();

  final sampleAlerts = [
    // ──────────────── تنبيهات عالية الخطورة ────────────────
    {
      'title': '⚠️ حملة تطعيم طارئة ضد شلل الأطفال',
      'message':
          'أعلنت وزارة الصحة عن حملة تطعيم طارئة ضد شلل الأطفال للأطفال من سن يوم حتى 5 سنوات. '
          'الحملة تبدأ من الأحد القادم ولمدة 4 أيام في جميع المحافظات. التطعيم مجاني وإلزامي.',
      'severity': 'high',
      'vaccineName': 'لقاح شلل الأطفال الفموي (OPV)',
      'isActive': true,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 6))),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(days: 30))),
    },
    {
      'title': '🦠 تنبيه: انتشار فيروس كورونا المستجد - متحور جديد',
      'message':
          'رصدت منظمة الصحة العالمية متحوراً جديداً من فيروس كورونا. يُنصح بتلقي الجرعة التنشيطية '
          'المحدّثة المتوفرة في المراكز الصحية، خاصةً لكبار السن وأصحاب الأمراض المزمنة.',
      'severity': 'high',
      'vaccineName': 'لقاح كوفيد-19 المحدّث',
      'isActive': true,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(days: 60))),
    },

    // ──────────────── تنبيهات متوسطة ────────────────
    {
      'title': '📢 تذكير: موسم لقاح الإنفلونزا بدأ',
      'message':
          'بدأ موسم تلقي لقاح الإنفلونزا الموسمية لعام 2026. يُنصح بتلقي اللقاح خلال شهري أكتوبر ونوفمبر '
          'قبل بدء ذروة انتشار الفيروس. اللقاح متوفر في الصيدليات والمستشفيات.',
      'severity': 'medium',
      'vaccineName': 'لقاح الإنفلونزا الموسمية',
      'isActive': true,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(days: 45))),
    },
    {
      'title': '🏥 تحديث مواعيد مراكز التطعيم',
      'message':
          'تم تعديل مواعيد العمل في مراكز التطعيم لتصبح من الساعة 8 صباحاً حتى 8 مساءً يومياً '
          'بما في ذلك أيام الجمعة والسبت، وذلك لتسهيل حصول المواطنين على التطعيمات.',
      'severity': 'medium',
      'vaccineName': '',
      'isActive': true,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(days: 90))),
    },

    // ──────────────── تنبيهات معلوماتية ────────────────
    {
      'title': '💡 لقاح جديد ضد الملاريا معتمد من WHO',
      'message':
          'أعلنت منظمة الصحة العالمية عن اعتماد لقاح جديد ضد الملاريا (R21/Matrix-M) للأطفال. '
          'من المتوقع أن يُسهم في خفض الوفيات الناتجة عن الملاريا بشكل كبير في أفريقيا.',
      'severity': 'info',
      'vaccineName': 'لقاح الملاريا R21',
      'isActive': true,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 7))),
      'expiresAt': null,
    },
    {
      'title': '📋 تذكير بتطعيمات المدارس',
      'message':
          'يُرجى من أولياء أمور طلاب الصف الأول الابتدائي التأكد من استكمال تطعيمات أطفالهم '
          'المطلوبة قبل بدء العام الدراسي. يمكنكم مراجعة أقرب وحدة صحية.',
      'severity': 'info',
      'vaccineName': '',
      'isActive': true,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 10))),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(days: 60))),
    },
  ];

  debugPrint('🔄 بدء رفع بيانات التنبيهات إلى Firestore...');

  final batch = firestore.batch();

  for (final alert in sampleAlerts) {
    final docRef = collection.doc();
    batch.set(docRef, alert);
  }

  try {
    await batch.commit();
    debugPrint('✅ تم رفع ${sampleAlerts.length} تنبيه بنجاح!');
  } catch (e) {
    debugPrint('❌ خطأ أثناء رفع التنبيهات: $e');
  }
}
