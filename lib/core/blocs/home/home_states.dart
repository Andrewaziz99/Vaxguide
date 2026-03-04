import 'package:vaxguide/core/models/article_model.dart';
import 'package:vaxguide/core/models/vaccine_alert_model.dart';

abstract class HomeStates {}

/// Initial state.
class HomeInitialState extends HomeStates {}

/// Loading data from Firestore.
class HomeLoadingState extends HomeStates {}

/// Data loaded successfully.
class HomeLoadedState extends HomeStates {
  final List<ArticleModel> articles;
  final List<VaccineAlertModel> alerts;

  HomeLoadedState({required this.articles, required this.alerts});
}

/// Error loading data.
class HomeErrorState extends HomeStates {
  final String error;
  HomeErrorState(this.error);
}

/// An alert was dismissed locally.
class HomeAlertDismissedState extends HomeStates {}
