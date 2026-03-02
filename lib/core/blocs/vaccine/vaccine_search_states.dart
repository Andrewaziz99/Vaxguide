abstract class VaccineSearchStates {}

class VaccineSearchInitialState extends VaccineSearchStates {}

class VaccineSearchLoadingState extends VaccineSearchStates {}

class VaccineSearchSuccessState extends VaccineSearchStates {}

class VaccineSearchEmptyState extends VaccineSearchStates {}

class VaccineSearchErrorState extends VaccineSearchStates {
  final String error;
  VaccineSearchErrorState(this.error);
}
