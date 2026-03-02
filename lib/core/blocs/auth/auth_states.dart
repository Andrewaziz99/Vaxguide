// Auth States

abstract class AuthStates {}

// ── Initial ──
class AuthInitialState extends AuthStates {}

// ── Login ──
class LoginLoadingState extends AuthStates {}

class LoginSuccessState extends AuthStates {
  final String uid;
  LoginSuccessState(this.uid);
}

class LoginErrorState extends AuthStates {
  final String error;
  LoginErrorState(this.error);
}

// ── Google Sign-In ──
class GoogleSignInLoadingState extends AuthStates {}

class GoogleSignInSuccessState extends AuthStates {
  final String uid;
  GoogleSignInSuccessState(this.uid);
}

class GoogleSignInErrorState extends AuthStates {
  final String error;
  GoogleSignInErrorState(this.error);
}

class GoogleSignInCancelledState extends AuthStates {}

class GoogleSignInNeedsProfileState extends AuthStates {
  final String uid;
  final String email;
  final String displayName;
  GoogleSignInNeedsProfileState({
    required this.uid,
    required this.email,
    required this.displayName,
  });
}

// ── Complete Profile (Google users) ──
class CompleteProfileLoadingState extends AuthStates {}

class CompleteProfileSuccessState extends AuthStates {}

class CompleteProfileErrorState extends AuthStates {
  final String error;
  CompleteProfileErrorState(this.error);
}

// ── Register ──
class RegisterLoadingState extends AuthStates {}

class RegisterSuccessState extends AuthStates {
  final String uid;
  RegisterSuccessState(this.uid);
}

class RegisterErrorState extends AuthStates {
  final String error;
  RegisterErrorState(this.error);
}

// ── Password Visibility ──
class PasswordVisibilityChangedState extends AuthStates {}

// ── Logout ──
class LogoutLoadingState extends AuthStates {}

class LogoutSuccessState extends AuthStates {}

class LogoutErrorState extends AuthStates {
  final String error;
  LogoutErrorState(this.error);
}
