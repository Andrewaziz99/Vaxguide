import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vaxguide/core/blocs/auth/auth_states.dart';
import 'package:vaxguide/core/constants/auth_constants.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/models/user_model.dart';
import 'package:vaxguide/core/network/local/cache_helper.dart';
import 'package:vaxguide/core/repositories/user_repo.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit({UserRepo? userRepo})
    : _userRepo = userRepo ?? UserRepo(),
      super(AuthInitialState());

  static AuthCubit get(context) => BlocProvider.of(context);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepo _userRepo;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '480865338978-cjshde2gl1vt92g1gun5djh70a8nr7bb.apps.googleusercontent.com',
  );

  // ── Password Visibility ──

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(PasswordVisibilityChangedState());
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    emit(PasswordVisibilityChangedState());
  }

  // ── Login ──

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoadingState());

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = userCredential.user!.uid;

      await _saveSessionToCache(uid: uid, email: email.trim());

      // Check if user needs to complete profile
      final user = await _userRepo.getUserById(uid);
      if (user != null && user.firstLogin) {
        emit(LoginNeedsProfileState(uid: uid, email: email.trim()));
      } else {
        emit(LoginSuccessState(uid));
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Login FirebaseAuthException: ${e.code} - ${e.message}');
      emit(LoginErrorState(_mapFirebaseAuthError(e.code)));
    } on FirebaseException catch (e) {
      debugPrint('Login FirebaseException: ${e.code} - ${e.message}');
      emit(LoginErrorState(_mapFirebaseAuthError(e.code)));
    } catch (e) {
      debugPrint('Login unexpected error: $e');
      emit(LoginErrorState(errorUnknownError));
    }
  }

  // ── Google Sign-In ──

  Future<void> googleSignIn() async {
    emit(GoogleSignInLoadingState());

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        emit(GoogleSignInCancelledState());
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final uid = userCredential.user!.uid;
      final userEmail = userCredential.user!.email ?? '';
      final displayName = userCredential.user!.displayName ?? '';

      // Check if user document already exists via repo
      bool userExists = false;
      try {
        await userCredential.user!.getIdToken(true);
        userExists = await _userRepo.userExists(uid);
      } catch (e) {
        debugPrint('Firestore user check failed: $e');
        userExists = false;
      }

      if (userExists) {
        await _saveSessionToCache(uid: uid, email: userEmail);

        // Check if existing user needs to complete profile
        final user = await _userRepo.getUserById(uid);
        if (user != null && user.firstLogin) {
          emit(
            GoogleSignInNeedsProfileState(
              uid: uid,
              email: userEmail,
              displayName: displayName,
            ),
          );
        } else {
          emit(GoogleSignInSuccessState(uid));
        }
      } else {
        emit(
          GoogleSignInNeedsProfileState(
            uid: uid,
            email: userEmail,
            displayName: displayName,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'GoogleSignIn FirebaseAuthException: ${e.code} - ${e.message}',
      );
      emit(GoogleSignInErrorState(_mapFirebaseAuthError(e.code)));
    } on FirebaseException catch (e) {
      debugPrint('GoogleSignIn FirebaseException: ${e.code} - ${e.message}');
      emit(GoogleSignInErrorState(_mapFirebaseAuthError(e.code)));
    } catch (e) {
      debugPrint('GoogleSignIn unexpected error: $e');
      emit(GoogleSignInErrorState(errorUnknownError));
    }
  }

  // ── Complete Google Profile ──

  Future<void> completeGoogleProfile({
    required String uid,
    required String fullName,
    required String username,
    required String phone,
    required String email,
    required String address,
    required String gender,
  }) async {
    emit(CompleteProfileLoadingState());

    try {
      final user = UserModel(
        uid: uid,
        fullName: fullName.trim(),
        username: username.trim(),
        phone: phone.trim(),
        email: email.trim(),
        address: address.trim(),
        gender: gender,
        firstLogin: false,
      );

      await _userRepo.createUser(user);

      await _saveSessionToCache(uid: uid, email: email.trim());

      emit(CompleteProfileSuccessState());
    } on FirebaseException catch (e) {
      debugPrint('CompleteProfile FirebaseException: ${e.code} - ${e.message}');
      emit(CompleteProfileErrorState(errorUnknownError));
    } catch (e) {
      debugPrint('CompleteProfile unexpected error: $e');
      emit(CompleteProfileErrorState(errorUnknownError));
    }
  }

  // ── Register ──

  Future<void> register({
    required String fullName,
    required String username,
    required String phone,
    required String email,
    required String password,
    required String address,
    required String gender,
  }) async {
    emit(RegisterLoadingState());

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = userCredential.user!.uid;

      final user = UserModel(
        uid: uid,
        fullName: fullName.trim(),
        username: username.trim(),
        phone: phone.trim(),
        email: email.trim(),
        address: address.trim(),
        gender: gender,
      );

      await _userRepo.createUser(user);

      emit(RegisterSuccessState(uid));
    } on FirebaseAuthException catch (e) {
      debugPrint('Register FirebaseAuthException: ${e.code} - ${e.message}');
      emit(RegisterErrorState(_mapFirebaseAuthError(e.code)));
    } on FirebaseException catch (e) {
      debugPrint('Register FirebaseException: ${e.code} - ${e.message}');
      emit(RegisterErrorState(_mapFirebaseAuthError(e.code)));
    } catch (e) {
      debugPrint('Register unexpected error: $e');
      emit(RegisterErrorState(errorUnknownError));
    }
  }

  // ── Reset Password ──

  Future<void> resetPassword({required String email}) async {
    emit(ResetPasswordLoadingState());

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      emit(ResetPasswordSuccessState());
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'ResetPassword FirebaseAuthException: ${e.code} - ${e.message}',
      );
      emit(ResetPasswordErrorState(_mapFirebaseAuthError(e.code)));
    } on FirebaseException catch (e) {
      debugPrint('ResetPassword FirebaseException: ${e.code} - ${e.message}');
      emit(ResetPasswordErrorState(_mapFirebaseAuthError(e.code)));
    } catch (e) {
      debugPrint('ResetPassword unexpected error: $e');
      emit(ResetPasswordErrorState(errorUnknownError));
    }
  }

  // ── Logout ──

  Future<void> logout() async {
    emit(LogoutLoadingState());

    try {
      await _auth.signOut();
      await _googleSignIn.signOut();

      await CacheHelper.removeData(key: AuthConstants.cacheKeyUserId);
      await CacheHelper.removeData(key: AuthConstants.cacheKeyIsLoggedIn);
      await CacheHelper.removeData(key: AuthConstants.cacheKeyEmail);
      await CacheHelper.removeData(key: AuthConstants.cacheKeyLastLoginTime);
      await CacheHelper.removeData(key: AuthConstants.cacheKeySessionExpiry);

      emit(LogoutSuccessState());
    } catch (e) {
      emit(LogoutErrorState(errorUnknownError));
    }
  }

  // ── Helpers ──

  Future<void> _saveSessionToCache({
    required String uid,
    required String email,
  }) async {
    await CacheHelper.saveData(key: AuthConstants.cacheKeyUserId, value: uid);
    await CacheHelper.saveData(
      key: AuthConstants.cacheKeyIsLoggedIn,
      value: true,
    );
    await CacheHelper.saveData(key: AuthConstants.cacheKeyEmail, value: email);
    await CacheHelper.saveData(
      key: AuthConstants.cacheKeyLastLoginTime,
      value: DateTime.now().toIso8601String(),
    );
    await CacheHelper.saveData(
      key: AuthConstants.cacheKeySessionExpiry,
      value: DateTime.now().add(AuthConstants.sessionTimeout).toIso8601String(),
    );
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return errorInvalidEmail;
      case 'user-not-found':
        return errorUserNotFound;
      case 'wrong-password':
        return errorWrongPassword;
      case 'user-disabled':
        return errorUserDisabled;
      case 'too-many-requests':
        return errorTooManyRequests;
      case 'network-request-failed':
        return errorNetworkRequestFailed;
      case 'operation-not-allowed':
        return errorOperationNotAllowed;
      case 'weak-password':
        return errorWeakPassword;
      case 'email-already-in-use':
        return errorEmailAlreadyInUse;
      case 'invalid-credential':
        return errorInvalidCredential;
      case 'account-exists-with-different-credential':
        return errorAccountExistsWithDifferentCredential;
      case 'requires-recent-login':
        return errorRequiresRecentLogin;
      default:
        return errorUnknownError;
    }
  }
}
