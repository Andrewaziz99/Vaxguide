import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaxguide/core/blocs/admin/admin_cubit.dart';
import 'package:vaxguide/core/models/feedback_model.dart';
import 'package:vaxguide/core/styles/colors.dart';

class ManageFeedbackTab extends StatelessWidget {
  const ManageFeedbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminCubit.get(context);

    return StreamBuilder<List<FeedbackModel>>(
      stream: cubit.streamFeedback(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: fischerBlue100),
          );
        }

        final feedbackList = snapshot.data ?? [];

        if (feedbackList.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.rate_review_rounded,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 12),
                Text(
                  'لا توجد تقييمات حالياً',
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          physics: const BouncingScrollPhysics(),
          itemCount: feedbackList.length,
          itemBuilder: (context, index) =>
              _FeedbackTile(feedback: feedbackList[index]),
        );
      },
    );
  }
}

class _FeedbackTile extends StatelessWidget {
  final FeedbackModel feedback;

  const _FeedbackTile({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat(
      'yyyy/MM/dd - HH:mm',
      'ar',
    ).format(feedback.createdAt);

    return GestureDetector(
      onTap: () => _openDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: fischerBlue900.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: fischerBlue300.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      feedback.fullName.isNotEmpty
                          ? feedback.fullName
                          : 'مستخدم بدون اسم',
                      style: const TextStyle(
                        fontFamily: 'Alexandria',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RatingBadge(averageRating: feedback.averageRating),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                feedback.email,
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  color: fischerBlue300,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                feedback.additionalFeatures.isEmpty
                    ? 'لا توجد ملاحظات إضافية'
                    : feedback.additionalFeatures,
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                dateText,
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FeedbackDetailsSheet(
        feedback: feedback,
        cubit: AdminCubit.get(context),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double averageRating;

  const _RatingBadge({required this.averageRating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
          const SizedBox(width: 4),
          Text(
            averageRating.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: 'Alexandria',
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackDetailsSheet extends StatelessWidget {
  final FeedbackModel feedback;
  final AdminCubit cubit;

  const _FeedbackDetailsSheet({required this.feedback, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: fischerBlue900.withValues(alpha: 0.95),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Text(
                    feedback.fullName,
                    style: const TextStyle(
                      fontFamily: 'Alexandria',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feedback.email,
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      color: fischerBlue300,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _scoreRow('سهولة الاستخدام', feedback.easeOfUse),
                  _scoreRow('وضوح المعلومات', feedback.clarityOfInfo),
                  _scoreRow(
                    'الدقة والموثوقية',
                    feedback.reliabilityAndAccuracy,
                  ),
                  _scoreRow('التجربة العامة', feedback.overallExperience),
                  const SizedBox(height: 16),
                  Text(
                    'ملاحظات إضافية',
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: fischerBlue700.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: fischerBlue300.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      feedback.additionalFeatures.isEmpty
                          ? 'لا توجد ملاحظات إضافية.'
                          : feedback.additionalFeatures,
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await cubit.deleteFeedback(feedback.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text(
                      'حذف التقييم',
                      style: TextStyle(fontFamily: 'Alexandria'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: red700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _scoreRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Alexandria',
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            '$value/5',
            style: TextStyle(
              fontFamily: 'Alexandria',
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
