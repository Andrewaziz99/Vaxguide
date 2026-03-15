import 'package:vaxguide/core/models/vaccine_category_model.dart';

abstract class VaccineSearchStates {}

/// Initial state — show category buttons loaded from Firestore.
class VaccineSearchInitialState extends VaccineSearchStates {
  final List<VaccineCategoryModel> categories;
  VaccineSearchInitialState({this.categories = const []});
}

/// Categories are loading from Firestore.
class VaccineSearchCategoriesLoadingState extends VaccineSearchStates {}

/// A category was selected — show subcategory dropdown.
class VaccineCategorySelectedState extends VaccineSearchStates {
  final VaccineCategoryModel category;
  final List<String> subcategories;
  VaccineCategorySelectedState(this.category, {this.subcategories = const []});
}

/// Loading vaccines from Firestore.
class VaccineSearchLoadingState extends VaccineSearchStates {}

/// Vaccines loaded successfully.
class VaccineSearchSuccessState extends VaccineSearchStates {}

/// No vaccines found.
class VaccineSearchEmptyState extends VaccineSearchStates {}

/// Error fetching vaccines.
class VaccineSearchErrorState extends VaccineSearchStates {
  final String error;
  VaccineSearchErrorState(this.error);
}
