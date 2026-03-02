import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vaxguide/core/blocs/auth/auth_states.dart';
import 'package:vaxguide/core/constants/auth_constants.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/network/local/cache_helper.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(AuthInitialState());

  static AuthCubit get(context) => BlocProvider.of(context);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

      // Save session to cache
      await _saveSessionToCache(uid: uid, email: email.trim());

      emit(LoginSuccessState(uid));
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

      // Check if user document already exists in Firestore
      bool userExists = false;
      try {
        // Force token refresh to ensure Firestore recognizes the auth
        await userCredential.user!.getIdToken(true);
        final userDoc = await _firestore.collection('users').doc(uid).get();
        userExists = userDoc.exists;
      } catch (e) {
        debugPrint('Firestore user check failed: $e');
        // If token refresh or Firestore check fails, treat as new user
        userExists = false;
      }

      if (userExists) {
        // Existing user — go straight to home
        await _saveSessionToCache(uid: uid, email: userEmail);
        emit(GoogleSignInSuccessState(uid));
      } else {
        // New Google user — needs to complete personal info
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
      await _firestore.collection('users').doc(uid).set({
        'fullName': fullName.trim(),
        'username': username.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'address': address.trim(),
        'gender': gender,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

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

      // Save user profile data to Firestore
      await _firestore.collection('users').doc(uid).set({
        'fullName': fullName.trim(),
        'username': username.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'address': address.trim(),
        'gender': gender,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

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

  // ── Logout ──

  Future<void> logout() async {
    emit(LogoutLoadingState());

    try {
      await _auth.signOut();
      await _googleSignIn.signOut();

      // Clear cached session
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
