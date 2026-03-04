import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/admin/admin_states.dart';
import 'package:vaxguide/core/models/article_model.dart';
import 'package:vaxguide/core/models/vaccine_alert_model.dart';
import 'package:vaxguide/core/models/vaccine_model.dart';
import 'package:vaxguide/core/repositories/article_repo.dart';
import 'package:vaxguide/core/repositories/user_repo.dart';
import 'package:vaxguide/core/repositories/vaccine_alert_repo.dart';
import 'package:vaxguide/core/repositories/vaccine_repo.dart';

class AdminCubit extends Cubit<AdminStates> {
  final VaccineRepo _vaccineRepo;
  final ArticleRepo _articleRepo;
  final VaccineAlertRepo _alertRepo;
  final UserRepo _userRepo;

  AdminCubit({
    VaccineRepo? vaccineRepo,
    ArticleRepo? articleRepo,
    VaccineAlertRepo? alertRepo,
    UserRepo? userRepo,
  }) : _vaccineRepo = vaccineRepo ?? VaccineRepo(),
       _articleRepo = articleRepo ?? ArticleRepo(),
       _alertRepo = alertRepo ?? VaccineAlertRepo(),
       _userRepo = userRepo ?? UserRepo(),
       super(AdminInitialState());

  static AdminCubit get(BuildContext context) => BlocProvider.of(context);

  // ══════════════════════════════════════════
  // VACCINES
  // ══════════════════════════════════════════

  Stream<List<VaccineModel>> streamVaccines() =>
      _vaccineRepo.streamAllVaccines();

  Future<void> addVaccine(VaccineModel vaccine) async {
    emit(AdminLoadingState());
    try {
      await _vaccineRepo.addVaccine(vaccine);
      emit(AdminSuccessState('تم إضافة التطعيم بنجاح'));
    } catch (e) {
      debugPrint('AdminCubit addVaccine error: $e');
      emit(AdminErrorState(e.toString()));
    }
  }

  Future<void> updateVaccine(VaccineModel vaccine) async {
    emit(AdminLoadingState());
    try {
      await _vaccineRepo.replaceVaccine(vaccine);
      emit(AdminSuccessState('تم تحديث التطعيم بنجاح'));
    } catch (e) {
      debugPrint('AdminCubit updateVaccine error: $e');
      emit(AdminErrorState(e.toString()));
    }
  }

  Future<void> deleteVaccine(String id) async {
    emit(AdminLoadingState());
    try {
      await _vaccineRepo.deleteVaccine(id);
      emit(AdminSuccessState('تم حذف التطعيم بنجاح'));
    } catch (e) {
      debugPrint('AdminCubit deleteVaccine error: $e');
      emit(AdminErrorState(e.toString()));
    }
  }

  // ══════════════════════════════════════════
  // ARTICLES
  // ══════════════════════════════════════════

  Stream<List<ArticleModel>> streamArticles() =>
      _articleRepo.streamAllArticles();

  Future<void> addArticle(ArticleModel article) async {
    emit(AdminLoadingState());
    try {
      await _articleRepo.addArticle(article);
      emit(AdminSuccessState('تم إضافة المقال بنجاح'));
    } catch (e) {
      debugPrint('AdminCubit addArticle error: $e');
      emit(AdminErrorState(e.toString()));
    }
  }

  Future<void> updateArticle(String id, Map<String, dynamic> data) async {
    emit(AdminLoadingState());
    try {
      await _articleRepo.updateArticle(id, data);
      emit(AdminSuccessState('تم تحديث المقال بنجاح'));
    } catch (e) {
      debugPrint('AdminCubit updateArticle error: $e');
      emit(AdminErrorState(e.toString()));
    }
  }

  Future<void> deleteArticle(String id) async {
    emit(AdminLoadingState());
    try {
      await _articleRepo.deleteArticle(id);
      emit(AdminSuccessState('تم حذف المقال بنجاح'));
    } catch (e) {
      debugPrint('AdminCubit deleteArticle error: $e');
      emit(AdminErrorState(e.toString()));
    }
  }

  // ══════════════════════════════════════════
  // VACCINE ALERTS
  // ══════════════════════════════════════════

  Stream<List<VaccineAlertModel>> streamAlerts() =>
      _alertRepo.streamAllAlerts();

  Future<void> addAlert(VaccineAlertModel alert) async {
    emit(AdminLoadingState());
    try {
      await _alertRepo.addAlert(alert);
      emit(AdminSuccessState('تم إضافة التنبيه بنجاح'));
    } catch (e) {
      debugPrint('AdminCubit addAlert error: $e');
      emit(AdminErrorState(e.toString()));
    }
  }

  Future<void> updateAlert(String id, Map<String, dynamic> data) async {
    emit(AdminLoadingState());
    try {
      await _alertRepo.updateAlert(id, data);
      emit(AdminSuccessState('تم تحديث التنبيه بنجاح'));
    } catch (e) {
      debugPrint('AdminCubit updateAlert error: $e');
      emit(AdminErrorState(e.toString()));
    }
  }

  Future<void> deleteAlert(String id) async {
    emit(AdminLoadingState());
    try {
      await _alertRepo.deleteAlert(id);
      emit(AdminSuccessState('تم حذف التنبيه بنجاح'));
    } catch (e) {
      debugPrint('AdminCubit deleteAlert error: $e');
      emit(AdminErrorState(e.toString()));
    }
  }

  // ══════════════════════════════════════════
  // USERS
  // ══════════════════════════════════════════

  Future<void> updateUserType(String uid, String userType) async {
    emit(AdminLoadingState());
    try {
      await _userRepo.updateUserType(uid, userType);
      emit(AdminSuccessState('تم تحديث نوع المستخدم بنجاح'));
    } catch (e) {
      debugPrint('AdminCubit updateUserType error: $e');
      emit(AdminErrorState(e.toString()));
    }
  }

  Future<void> deleteUser(String uid) async {
    emit(AdminLoadingState());
    try {
      await _userRepo.deleteUser(uid);
      emit(AdminSuccessState('تم حذف المستخدم بنجاح'));
    } catch (e) {
      debugPrint('AdminCubit deleteUser error: $e');
      emit(AdminErrorState(e.toString()));
    }
  }
}
