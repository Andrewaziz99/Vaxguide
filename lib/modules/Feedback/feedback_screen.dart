import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/models/feedback_model.dart';
import 'package:vaxguide/core/models/user_model.dart';
import 'package:vaxguide/core/repositories/feedback_repo.dart';
import 'package:vaxguide/core/repositories/user_repo.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  final _feedbackRepo = FeedbackRepo();
  final _additionalCtrl = TextEditingController();

  int _easeOfUse = 0;
  int _clarityOfInfo = 0;
  int _reliability = 0;
  int _overallExperience = 0;

  bool _isSubmitting = false;
  bool _isSubmitted = false;
  bool _alreadySubmitted = false;
  bool _isLoading = true;
  UserModel? _user;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final user = await UserRepo().getUserById(uid);
      final alreadySubmitted = await _feedbackRepo.hasUserSubmittedFeedback(
        uid,
      );
      if (mounted) {
        setState(() {
          _user = user;
          _alreadySubmitted = alreadySubmitted;
          _isLoading = false;
        });
        _animController.forward();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _additionalCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate all ratings are filled
    if (_easeOfUse == 0 ||
        _clarityOfInfo == 0 ||
        _reliability == 0 ||
        _overallExperience == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: red700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text(
            feedbackPleaseRate,
            style: TextStyle(fontFamily: 'Alexandria'),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final feedback = FeedbackModel(
        id: '',
        uid: uid,
        fullName: _user?.fullName ?? '',
        email: _user?.email ?? '',
        easeOfUse: _easeOfUse,
        clarityOfInfo: _clarityOfInfo,
        reliabilityAndAccuracy: _reliability,
        overallExperience: _overallExperience,
        additionalFeatures: _additionalCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      await _feedbackRepo.submitFeedback(feedback);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: red700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: const Text(
              feedbackError,
              style: TextStyle(fontFamily: 'Alexandria'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      backgroundImagePath: 'assets/images/bg2.png',
      appBar: AppBar(
        title: const Text(
          feedbackTitle,
          style: TextStyle(
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: fischerBlue100),
            )
          : _alreadySubmitted
          ? _buildAlreadySubmitted()
          : _isSubmitted
          ? _buildSuccessState()
          : _buildFeedbackForm(),
    );
  }

  // ── Already Submitted State ──
  Widget _buildAlreadySubmitted() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              feedbackAlreadySubmitted,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Success State ──
  Widget _buildSuccessState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.greenAccent.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.greenAccent,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              feedbackSuccess,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: fischerBlue500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  back,
                  style: TextStyle(
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
    );
  }

  // ── Feedback Form ──
  Widget _buildFeedbackForm() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    fischerBlue500.withValues(alpha: 0.2),
                    fischerBlue700.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: fischerBlue300.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.rate_review_rounded,
                      color: Colors.amber,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          feedbackSubtitle,
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feedbackDesc,
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Rating Questions ──
            _GlassCard(
              child: Column(
                children: [
                  _buildRatingQuestion(
                    question: feedbackEaseOfUse,
                    icon: Icons.touch_app_rounded,
                    rating: _easeOfUse,
                    onChanged: (val) => setState(() => _easeOfUse = val),
                  ),
                  _buildDivider(),
                  _buildRatingQuestion(
                    question: feedbackClarityOfInfo,
                    icon: Icons.visibility_rounded,
                    rating: _clarityOfInfo,
                    onChanged: (val) => setState(() => _clarityOfInfo = val),
                  ),
                  _buildDivider(),
                  _buildRatingQuestion(
                    question: feedbackReliability,
                    icon: Icons.verified_rounded,
                    rating: _reliability,
                    onChanged: (val) => setState(() => _reliability = val),
                  ),
                  _buildDivider(),
                  _buildRatingQuestion(
                    question: feedbackOverallExperience,
                    icon: Icons.emoji_emotions_rounded,
                    rating: _overallExperience,
                    onChanged: (val) =>
                        setState(() => _overallExperience = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Additional Features / Suggestions ──
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feedbackAdditionalFeatures,
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _additionalCtrl,
                    maxLines: 4,
                    style: const TextStyle(
                      fontFamily: 'Alexandria',
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: feedbackAdditionalFeaturesHint,
                      hintStyle: TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: fischerBlue300),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Submit Button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
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
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _isSubmitting ? feedbackSubmitting : feedbackSubmit,
                  style: const TextStyle(
                    fontFamily: 'Alexandria',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Single Rating Question Widget ──
  Widget _buildRatingQuestion({
    required String question,
    required IconData icon,
    required int rating,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: fischerBlue300, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isSelected = starIndex <= rating;
              return GestureDetector(
                onTap: () => onChanged(starIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isSelected
                        ? Colors.amber
                        : Colors.white.withValues(alpha: 0.25),
                    size: isSelected ? 38 : 34,
                  ),
                ),
              );
            }),
          ),
          if (rating > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Center(
                child: Text(
                  _getRatingLabel(rating),
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 11,
                    color: Colors.amber.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'ضعيف';
      case 2:
        return 'مقبول';
      case 3:
        return 'جيد';
      case 4:
        return 'جيد جداً';
      case 5:
        return 'ممتاز';
      default:
        return '';
    }
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Divider(
        color: fischerBlue100.withValues(alpha: 0.1),
        thickness: 1,
      ),
    );
  }
}

// ── Glass Card Widget ──
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: child,
        ),
      ),
    );
  }
}
