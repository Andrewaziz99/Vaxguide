import 'package:vaxguide/core/models/vaccine_category.dart';

abstract class VaccineSearchStates {}

/// Initial state — show 4 category buttons.
class VaccineSearchInitialState extends VaccineSearchStates {}

/// A category was selected — show subcategory dropdown.
class VaccineCategorySelectedState extends VaccineSearchStates {
  final VaccineCategory category;
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
