import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/home/home_states.dart';
import 'package:vaxguide/core/models/article_model.dart';
import 'package:vaxguide/core/models/vaccine_alert_model.dart';
import 'package:vaxguide/core/repositories/article_repo.dart';
import 'package:vaxguide/core/repositories/vaccine_alert_repo.dart';

class HomeCubit extends Cubit<HomeStates> {
  final ArticleRepo _articleRepo;
  final VaccineAlertRepo _alertRepo;

  StreamSubscription<List<ArticleModel>>? _articlesSub;
  StreamSubscription<List<VaccineAlertModel>>? _alertsSub;

  List<ArticleModel> articles = [];
  List<VaccineAlertModel> alerts = [];
  final Set<String> _dismissedAlertIds = {};

  HomeCubit({ArticleRepo? articleRepo, VaccineAlertRepo? alertRepo})
    : _articleRepo = articleRepo ?? ArticleRepo(),
      _alertRepo = alertRepo ?? VaccineAlertRepo(),
      super(HomeInitialState());

  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  void loadHomeData() {
    emit(HomeLoadingState());

    _articlesSub = _articleRepo.streamPublishedArticles().listen(
      (articleList) {
        articles = articleList;
        _emitLoaded();
      },
      onError: (error) {
        debugPrint('HomeCubit articles stream error: $error');
        emit(HomeErrorState(error.toString()));
      },
    );

    _alertsSub = _alertRepo.streamActiveAlerts().listen(
      (alertList) {
        alerts = alertList;
        _emitLoaded();
      },
      onError: (error) {
        debugPrint('HomeCubit alerts stream error: $error');
        alerts = [];
        _emitLoaded();
      },
    );
  }

  void dismissAlert(String alertId) {
    _dismissedAlertIds.add(alertId);
    _emitLoaded();
  }

  List<VaccineAlertModel> get visibleAlerts =>
      alerts.where((a) => !_dismissedAlertIds.contains(a.id)).toList();

  void _emitLoaded() {
    emit(HomeLoadedState(articles: articles, alerts: visibleAlerts));
  }

  @override
  Future<void> close() {
    _articlesSub?.cancel();
    _alertsSub?.cancel();
    return super.close();
  }
}
