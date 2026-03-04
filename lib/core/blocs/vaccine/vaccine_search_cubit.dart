import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/vaccine/vaccine_search_states.dart';
import 'package:vaxguide/core/models/vaccine_category.dart';
import 'package:vaxguide/core/models/vaccine_model.dart';
import 'package:vaxguide/core/repositories/vaccine_repo.dart';

class VaccineSearchCubit extends Cubit<VaccineSearchStates> {
  final VaccineRepo _vaccineRepo;

  VaccineSearchCubit({VaccineRepo? vaccineRepo})
    : _vaccineRepo = vaccineRepo ?? VaccineRepo(),
      super(VaccineSearchInitialState());

  static VaccineSearchCubit get(BuildContext context) =>
      BlocProvider.of(context);

  List<VaccineModel> vaccines = [];
  VaccineCategory? selectedCategory;
  String? selectedSubcategory;
  List<String> travelCountries = [];

  // ── NAVIGATION ──

  /// Go back to categories screen.
  void goToCategories() {
    selectedCategory = null;
    selectedSubcategory = null;
    vaccines = [];
    emit(VaccineSearchInitialState());
  }

  /// Select a category — show subcategory dropdown.
  Future<void> selectCategory(VaccineCategory category) async {
    selectedCategory = category;
    selectedSubcategory = null;
    vaccines = [];

    if (category == VaccineCategory.travel) {
      // Load available countries for autocomplete
      try {
        travelCountries = await _vaccineRepo.getTravelCountries();
      } catch (e) {
        debugPrint('VaccineSearchCubit getTravelCountries error: $e');
        travelCountries = [];
      }
      emit(VaccineCategorySelectedState(category));
    } else if (category == VaccineCategory.additional) {
      // Load dynamic subcategories from Firestore
      try {
        final subs = await _vaccineRepo.getSubcategoriesForCategory(
          category.key,
        );
        emit(VaccineCategorySelectedState(category, subcategories: subs));
      } catch (e) {
        debugPrint('VaccineSearchCubit getSubcategories error: $e');
        emit(VaccineCategorySelectedState(category));
      }
    } else {
      // preschool / school — subcategories are static in enum
      emit(
        VaccineCategorySelectedState(
          category,
          subcategories: category.subcategories,
        ),
      );
    }
  }

  /// Select a subcategory and fetch vaccines.
  Future<void> selectSubcategory(String subcategory) async {
    if (selectedCategory == null) return;

    selectedSubcategory = subcategory;
    emit(VaccineSearchLoadingState());

    try {
      vaccines = await _vaccineRepo.getVaccinesByCategoryAndSubcategory(
        selectedCategory!.key,
        subcategory,
      );

      if (vaccines.isEmpty) {
        emit(VaccineSearchEmptyState());
      } else {
        emit(VaccineSearchSuccessState());
      }
    } catch (e) {
      debugPrint('VaccineSearchCubit selectSubcategory error: $e');
      emit(VaccineSearchErrorState(e.toString()));
    }
  }

  /// Search travel vaccines by country name.
  Future<void> searchByCountry(String country) async {
    if (country.trim().isEmpty) return;

    selectedSubcategory = country;
    emit(VaccineSearchLoadingState());

    try {
      vaccines = await _vaccineRepo.searchTravelVaccinesByCountry(
        country.trim(),
      );

      if (vaccines.isEmpty) {
        emit(VaccineSearchEmptyState());
      } else {
        emit(VaccineSearchSuccessState());
      }
    } catch (e) {
      debugPrint('VaccineSearchCubit searchByCountry error: $e');
      emit(VaccineSearchErrorState(e.toString()));
    }
  }

  // ── CRUD (kept for admin features) ──

  Future<String> addVaccine(VaccineModel vaccine) async {
    try {
      final id = await _vaccineRepo.addVaccine(vaccine);
      return id;
    } catch (e) {
      debugPrint('VaccineSearchCubit addVaccine error: $e');
      emit(VaccineSearchErrorState(e.toString()));
      rethrow;
    }
  }

  Future<VaccineModel?> getVaccineById(String id) async {
    try {
      return await _vaccineRepo.getVaccineById(id);
    } catch (e) {
      debugPrint('VaccineSearchCubit getVaccineById error: $e');
      return null;
    }
  }

  Future<void> updateVaccine(String id, Map<String, dynamic> data) async {
    try {
      await _vaccineRepo.updateVaccine(id, data);
    } catch (e) {
      debugPrint('VaccineSearchCubit updateVaccine error: $e');
      emit(VaccineSearchErrorState(e.toString()));
    }
  }

  Future<void> deleteVaccine(String id) async {
    try {
      await _vaccineRepo.deleteVaccine(id);
    } catch (e) {
      debugPrint('VaccineSearchCubit deleteVaccine error: $e');
      emit(VaccineSearchErrorState(e.toString()));
    }
  }
}
