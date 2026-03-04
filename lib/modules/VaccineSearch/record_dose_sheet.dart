import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaxguide/core/models/user_model.dart';
import 'package:vaxguide/core/models/vaccine_model.dart';
import 'package:vaxguide/core/network/notification_service.dart';
import 'package:vaxguide/core/repositories/user_repo.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/utils/dose_schedule_helper.dart';

/// Shows a bottom sheet for the user to record a vaccine dose
/// and automatically schedules a reminder for the next dose if applicable.
Future<void> showRecordDoseSheet(
  BuildContext context,
  VaccineModel vaccine,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _RecordDoseSheet(vaccine: vaccine),
  );
}

class _RecordDoseSheet extends StatefulWidget {
  final VaccineModel vaccine;
  const _RecordDoseSheet({required this.vaccine});

  @override
  State<_RecordDoseSheet> createState() => _RecordDoseSheetState();
}

class _RecordDoseSheetState extends State<_RecordDoseSheet> {
  final _notesCtrl = TextEditingController();
  late final DoseScheduleInfo _scheduleInfo;
  int _selectedDose = 1;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  int _dosesTaken = 0;

  @override
  void initState() {
    super.initState();
    _scheduleInfo = DoseScheduleHelper.getScheduleInfo(
      widget.vaccine.name,
      widget.vaccine.schedule,
    );
    _selectedDose = 1; // default, updated once history loads
    _loadDosesTaken();
  }

  Future<void> _loadDosesTaken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final user = await UserRepo().getUserById(uid);
    if (user == null) return;

    final count = user.vaccineHistory
        .where((e) => e.vaccineId == widget.vaccine.id)
        .length;

    if (mounted) {
      setState(() {
        _dosesTaken = count;
        _selectedDose = (count + 1).clamp(1, _scheduleInfo.totalDoses);
      });
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextDoseDate = _scheduleInfo.getNextDoseDate(
      _selectedDose,
      _selectedDate,
    );
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: fischerBlue900.withValues(alpha: 0.92),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(color: fischerBlue300.withValues(alpha: 0.2)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: fischerBlue100.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.vaccines_rounded,
                          color: fischerBlue100,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تسجيل جرعة',
                              style: TextStyle(
                                fontFamily: 'Alexandria',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.vaccine.name,
                              style: TextStyle(
                                fontFamily: 'Alexandria',
                                fontSize: 13,
                                color: fischerBlue300,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Dose progress indicator
                  if (_scheduleInfo.totalDoses > 1) ...[
                    _buildDoseProgress(),
                    const SizedBox(height: 20),
                  ],

                  // Dose selector
                  _buildDoseSelector(),
                  const SizedBox(height: 16),

                  // Date picker
                  _buildDatePicker(),
                  const SizedBox(height: 16),

                  // Notes field
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    style: const TextStyle(
                      fontFamily: 'Alexandria',
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      labelText: 'ملاحظات (اختياري)',
                      labelStyle: TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: fischerBlue300.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: fischerBlue300),
                      ),
                      filled: true,
                      fillColor: fischerBlue900.withValues(alpha: 0.5),
                    ),
                  ),

                  // Next dose info
                  if (nextDoseDate != null) ...[
                    const SizedBox(height: 16),
                    _buildNextDoseInfo(nextDoseDate),
                  ],

                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: fischerBlue500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        disabledBackgroundColor: fischerBlue700.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(
                        _isLoading ? 'جارٍ التسجيل...' : 'تسجيل الجرعة',
                        style: const TextStyle(
                          fontFamily: 'Alexandria',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Dose progress ──
  Widget _buildDoseProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تقدم الجرعات',
              style: TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '$_dosesTaken / ${_scheduleInfo.totalDoses}',
              style: const TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: fischerBlue100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_scheduleInfo.totalDoses, (i) {
            final isTaken = i < _dosesTaken;
            final isSelected = i == _selectedDose - 1;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(
                  left: i < _scheduleInfo.totalDoses - 1 ? 3 : 0,
                ),
                decoration: BoxDecoration(
                  color: isTaken
                      ? Colors.greenAccent
                      : isSelected
                      ? fischerBlue300
                      : fischerBlue700.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Dose selector ──
  Widget _buildDoseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم الجرعة',
          style: TextStyle(
            fontFamily: 'Alexandria',
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_scheduleInfo.totalDoses, (i) {
            final doseNum = i + 1;
            final isSelected = doseNum == _selectedDose;
            final isTaken = i < _dosesTaken;
            return GestureDetector(
              onTap: () => setState(() => _selectedDose = doseNum),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? fischerBlue500
                      : isTaken
                      ? Colors.greenAccent.withValues(alpha: 0.15)
                      : fischerBlue900.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? fischerBlue300
                        : isTaken
                        ? Colors.greenAccent.withValues(alpha: 0.3)
                        : fischerBlue300.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isTaken)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: Colors.greenAccent,
                        ),
                      ),
                    Text(
                      _scheduleInfo.getDoseLabel(doseNum),
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : isTaken
                            ? Colors.greenAccent
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Date picker ──
  Widget _buildDatePicker() {
    final dateStr = DateFormat('yyyy/MM/dd', 'ar').format(_selectedDate);
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: fischerBlue300,
                  onPrimary: Colors.white,
                  surface: fischerBlue900,
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: fischerBlue900.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: fischerBlue300.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 18, color: fischerBlue300),
            const SizedBox(width: 10),
            Text(
              'تاريخ التطعيم: $dateStr',
              style: const TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.edit_calendar_rounded,
              size: 18,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  // ── Next dose info ──
  Widget _buildNextDoseInfo(DateTime nextDoseDate) {
    final nextDateStr = DateFormat('yyyy/MM/dd', 'ar').format(nextDoseDate);
    final daysUntil = nextDoseDate.difference(DateTime.now()).inDays;
    final nextLabel = _scheduleInfo.getDoseLabel(_selectedDose + 1);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_rounded,
            color: Colors.amber,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سيتم تذكيرك بموعد $nextLabel',
                  style: const TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$nextDateStr (بعد $daysUntil يوم)',
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 11,
                    color: Colors.amber.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Submit ──
  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      final entry = VaccineHistoryEntry(
        vaccineId: widget.vaccine.id,
        vaccineName: widget.vaccine.name,
        dateAdministered: _selectedDate,
        dose: _scheduleInfo.getDoseLabel(_selectedDose),
        notes: _notesCtrl.text.trim(),
      );

      await UserRepo().addVaccineHistory(uid, entry);

      // Schedule next dose reminder if applicable
      final nextDoseDate = _scheduleInfo.getNextDoseDate(
        _selectedDose,
        _selectedDate,
      );
      if (nextDoseDate != null) {
        final nextDoseNumber = _selectedDose + 1;
        final nextLabel = _scheduleInfo.getDoseLabel(nextDoseNumber);

        await NotificationService.instance.scheduleDoseReminder(
          vaccineId: widget.vaccine.id,
          vaccineName: widget.vaccine.name,
          nextDoseNumber: nextDoseNumber,
          nextDoseLabel: nextLabel,
          scheduledDate: nextDoseDate,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: fischerBlue700,
            content: Text(
              nextDoseDate != null
                  ? 'تم تسجيل الجرعة بنجاح ✅ سيتم تذكيرك بالجرعة القادمة'
                  : 'تم تسجيل الجرعة بنجاح ✅',
              style: const TextStyle(fontFamily: 'Alexandria'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: red700,
            content: Text(
              'حدث خطأ أثناء تسجيل الجرعة: $e',
              style: const TextStyle(fontFamily: 'Alexandria'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
