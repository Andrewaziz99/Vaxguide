abstract class AdminStates {}

class AdminInitialState extends AdminStates {}

class AdminLoadingState extends AdminStates {}

class AdminSuccessState extends AdminStates {
  final String message;
  AdminSuccessState([this.message = '']);
}

class AdminErrorState extends AdminStates {
  final String error;
  AdminErrorState(this.error);
}

class AdminDeleteConfirmState extends AdminStates {}
