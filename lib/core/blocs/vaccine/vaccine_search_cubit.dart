import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/vaccine/vaccine_search_states.dart';
import 'package:vaxguide/core/models/vaccine_model.dart';

class VaccineSearchCubit extends Cubit<VaccineSearchStates> {
  VaccineSearchCubit() : super(VaccineSearchInitialState());

  static VaccineSearchCubit get(BuildContext context) =>
      BlocProvider.of(context);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<VaccineModel> _allVaccines = [];
  List<VaccineModel> filteredVaccines = [];

  // ── Current filter/search state ──
  String _searchQuery = '';
  String? selectedAgeGroup;
  String? selectedDisease;
  String? selectedManufacturer;

  // ── Distinct values extracted from data ──
  List<String> get ageGroups => _allVaccines
      .map((v) => v.ageGroup)
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList();

  List<String> get diseases => _allVaccines
      .map((v) => v.disease)
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList();

  List<String> get manufacturers => _allVaccines
      .map((v) => v.manufacturer)
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList();

  bool get hasActiveFilters =>
      selectedAgeGroup != null ||
      selectedDisease != null ||
      selectedManufacturer != null;

  /// Fetch all vaccines from Firestore once, then filter locally.
  Future<void> fetchVaccines() async {
    emit(VaccineSearchLoadingState());

    try {
      final snapshot = await _firestore
          .collection('vaccines')
          .orderBy('name')
          .get();

      _allVaccines = snapshot.docs
          .map((doc) => VaccineModel.fromFirestore(doc))
          .toList();

      filteredVaccines = List.from(_allVaccines);

      if (filteredVaccines.isEmpty) {
        emit(VaccineSearchEmptyState());
      } else {
        emit(VaccineSearchSuccessState());
      }
    } catch (e) {
      debugPrint('VaccineSearchCubit fetchVaccines error: $e');
      emit(VaccineSearchErrorState(e.toString()));
    }
  }

  /// Update search query and re-apply all filters.
  void searchVaccines(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Set age group filter and re-apply.
  void filterByAgeGroup(String? ageGroup) {
    selectedAgeGroup = ageGroup;
    _applyFilters();
  }

  /// Set disease filter and re-apply.
  void filterByDisease(String? disease) {
    selectedDisease = disease;
    _applyFilters();
  }

  /// Set manufacturer filter and re-apply.
  void filterByManufacturer(String? manufacturer) {
    selectedManufacturer = manufacturer;
    _applyFilters();
  }

  /// Clear all filters and search.
  void clearFilters() {
    selectedAgeGroup = null;
    selectedDisease = null;
    selectedManufacturer = null;
    _searchQuery = '';
    _applyFilters();
  }

  /// Core filtering logic — combines search query + all active filters.
  void _applyFilters() {
    final trimmed = _searchQuery.trim().toLowerCase();

    filteredVaccines = _allVaccines.where((vaccine) {
      // Text search
      if (trimmed.isNotEmpty) {
        final matchesSearch =
            vaccine.name.toLowerCase().contains(trimmed) ||
            vaccine.disease.toLowerCase().contains(trimmed) ||
            vaccine.manufacturer.toLowerCase().contains(trimmed);
        if (!matchesSearch) return false;
      }

      // Age group filter
      if (selectedAgeGroup != null && vaccine.ageGroup != selectedAgeGroup) {
        return false;
      }

      // Disease filter
      if (selectedDisease != null && vaccine.disease != selectedDisease) {
        return false;
      }

      // Manufacturer filter
      if (selectedManufacturer != null &&
          vaccine.manufacturer != selectedManufacturer) {
        return false;
      }

      return true;
    }).toList();

    if (filteredVaccines.isEmpty) {
      emit(VaccineSearchEmptyState());
    } else {
      emit(VaccineSearchSuccessState());
    }
  }
}
