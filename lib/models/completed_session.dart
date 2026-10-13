import 'session_model.dart';

// بيانات الجلسة بعد إنهائها.
// حالياً بتنحفظ بذاكرة التطبيق فقط.
class CompletedSession {
  final SessionModel session;
  final DateTime endTime;
  final Duration actualDuration;

  // المبلغ الناتج عن الحساب التلقائي.
  final int calculatedAmount;

  // المبلغ الذي اعتمده الموظف عند الإنهاء.
  final int finalAmount;

  // سبب التعديل اختياري.
  final String? adjustmentReason;

  const CompletedSession({
    required this.session,
    required this.endTime,
    required this.actualDuration,
    required this.calculatedAmount,
    required this.finalAmount,
    this.adjustmentReason,
  });
}
