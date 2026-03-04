import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/home/home_cubit.dart';
import 'package:vaxguide/core/blocs/home/home_states.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/modules/Home/widgets/article_card.dart';
import 'package:vaxguide/modules/Home/widgets/vaccine_alert_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadHomeData(),
      child: BlocBuilder<HomeCubit, HomeStates>(
        builder: (context, state) {
          if (state is HomeLoadingState) {
            return const Center(
              child: CircularProgressIndicator(color: fischerBlue100),
            );
          }

          if (state is HomeErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, color: red500, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'حدث خطأ أثناء تحميل البيانات',
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => HomeCubit.get(context).loadHomeData(),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: fischerBlue300,
                    ),
                    label: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        color: fischerBlue300,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final cubit = HomeCubit.get(context);
          final articles = cubit.articles;
          final alerts = cubit.visibleAlerts;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Vaccine Alert Banners ──
              if (alerts.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      ...alerts.map(
                        (alert) => VaccineAlertBanner(
                          alert: alert,
                          onDismiss: () => cubit.dismissAlert(alert.id),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),

              // ── Section Header: Latest News ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: fischerBlue300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'آخر الأخبار',
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Articles List ──
              if (articles.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 60,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'لا توجد مقالات حالياً',
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == articles.length) {
                        return const SizedBox(height: 20);
                      }
                      return ArticleCard(article: articles[index]);
                    },
                    childCount: articles.length + 1, // +1 for bottom padding
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
