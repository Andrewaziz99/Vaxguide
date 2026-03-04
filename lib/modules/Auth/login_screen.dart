import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/auth/auth_cubit.dart';
import 'package:vaxguide/core/blocs/auth/auth_states.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';
import 'package:vaxguide/layout/layout.dart';
import 'package:vaxguide/modules/Auth/complete_profile_screen.dart';
import 'package:vaxguide/modules/Auth/register_screen.dart';
import 'package:vaxguide/shared/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is LoginSuccessState) {
            navigateAndFinish(context, const AppLayout());
          } else if (state is LoginNeedsProfileState) {
            navigateAndFinish(
              context,
              CompleteProfileScreen(
                uid: state.uid,
                email: state.email,
                displayName: '',
              ),
            );
          } else if (state is LoginErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  state.error,
                  style: const TextStyle(fontFamily: 'Alexandria'),
                ),
              ),
            );
          } else if (state is GoogleSignInSuccessState) {
            navigateAndFinish(context, const AppLayout());
          } else if (state is GoogleSignInErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  state.error,
                  style: const TextStyle(fontFamily: 'Alexandria'),
                ),
              ),
            );
          } else if (state is GoogleSignInCancelledState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  googleSignInCancelled,
                  style: TextStyle(fontFamily: 'Alexandria'),
                ),
              ),
            );
          } else if (state is GoogleSignInNeedsProfileState) {
            navigateAndFinish(
              context,
              CompleteProfileScreen(
                uid: state.uid,
                email: state.email,
                displayName: state.displayName,
              ),
            );
          } else if (state is ResetPasswordSuccessState) {
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  resetPasswordSuccess,
                  style: TextStyle(fontFamily: 'Alexandria'),
                ),
              ),
            );
          } else if (state is ResetPasswordErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  state.error,
                  style: const TextStyle(fontFamily: 'Alexandria'),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = AuthCubit.get(context);
          final isLoading =
              state is LoginLoadingState || state is GoogleSignInLoadingState;

          return ThemedScaffold(
            body: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),

                          // App Logo / Icon
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.vaccines_rounded,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Welcome Title
                          const Text(
                            welcomeMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Alexandria',
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          const Text(
                            signInToContinue,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontFamily: 'Alexandria',
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Email Field
                          CustomTextField(
                            controller: _emailController,
                            hintText: pleaseEnterYourEmail,
                            labelText: email,
                            prefixIconData: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return pleaseEnterYourEmail;
                              }
                              if (!RegExp(
                                r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return pleaseEnterValidEmail;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Password Field
                          CustomTextField(
                            controller: _passwordController,
                            hintText: pleaseEnterYourPassword,
                            labelText: password,
                            prefixIconData: Icons.lock_outline,
                            obscureText: !cubit.isPasswordVisible,
                            suffixIcon: IconButton(
                              onPressed: () => cubit.togglePasswordVisibility(),
                              icon: Icon(
                                cubit.isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return pleaseEnterYourPassword;
                              }
                              if (value.length < 6) {
                                return passwordMustBe6Characters;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // Forgot Password
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: TextButton(
                              onPressed: () => _showResetPasswordDialog(
                                context,
                                cubit,
                              ),
                              child: const Text(
                                forgotPassword,
                                style: TextStyle(
                                  color: fischerBlue100,
                                  fontSize: 14,
                                  fontFamily: 'Alexandria',
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        cubit.login(
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: fischerBlue100,
                                foregroundColor: fischerBlue900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: isLoading && state is LoginLoadingState
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: fischerBlue900,
                                      ),
                                    )
                                  : const Text(
                                      login,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Alexandria',
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Divider with "أو"
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.white38,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  or,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                    fontFamily: 'Alexandria',
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.white38,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Google Sign-In Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () => cubit.googleSignIn(),
                              icon: Image.network(
                                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                height: 24,
                                width: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.g_mobiledata_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  );
                                },
                              ),
                              label: const Text(
                                signInWithGoogle,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Alexandria',
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.white54,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () {
                                navigateAndFinish(
                                  context,
                                  const RegisterScreen(),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.white54,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                register,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Alexandria',
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),

                // Modern Loading Overlay
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.55),
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) {
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 32,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                fischerBlue900.withValues(alpha: 0.95),
                                fischerBlue700.withValues(alpha: 0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: fischerBlue100.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: fischerBlue100.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3.5,
                                    color: fischerBlue100,
                                    backgroundColor: fischerBlue100.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                state is GoogleSignInLoadingState
                                    ? googleSignInLoading
                                    : loginLoading,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Alexandria',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                pleaseWait,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                  fontFamily: 'Alexandria',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, AuthCubit cubit) {
    final resetEmailController = TextEditingController(
      text: _emailController.text,
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<AuthCubit, AuthStates>(
          builder: (context, state) {
            final isSending = state is ResetPasswordLoadingState;

            return AlertDialog(
              backgroundColor: fischerBlue900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: fischerBlue100.withValues(alpha: 0.2),
                ),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: fischerBlue100.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: fischerBlue100,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      resetPasswordTitle,
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      resetPasswordMessage,
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: email,
                        labelStyle: TextStyle(
                          fontFamily: 'Alexandria',
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: fischerBlue300.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: fischerBlue300),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        filled: true,
                        fillColor: fischerBlue900.withValues(alpha: 0.5),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return pleaseEnterYourEmail;
                        }
                        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value.trim())) {
                          return pleaseEnterValidEmail;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSending ? null : () => Navigator.pop(ctx),
                  child: Text(
                    resetPasswordCancel,
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            cubit.resetPassword(
                              email: resetEmailController.text.trim(),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fischerBlue500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          resetPasswordSend,
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
