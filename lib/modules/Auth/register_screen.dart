import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/auth/auth_cubit.dart';
import 'package:vaxguide/core/blocs/auth/auth_states.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';
import 'package:vaxguide/modules/Auth/login_screen.dart';
import 'package:vaxguide/shared/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  // Step 1: Personal Info
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 2: Account Info
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Additional Info (in Step 2)
  final _addressController = TextEditingController();
  String? _selectedGender;

  int _currentStep = 1;
  static const int _totalSteps = 2;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _nextStep(AuthCubit cubit) {
    bool isValid = false;
    switch (_currentStep) {
      case 1:
        isValid = _formKeyStep1.currentState!.validate();
        break;
      case 2:
        isValid = _formKeyStep2.currentState!.validate();
        break;
    }

    if (isValid) {
      if (_currentStep < _totalSteps) {
        setState(() {
          _currentStep++;
        });
      } else {
        cubit.register(
          fullName: _fullNameController.text,
          username: _usernameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          password: _passwordController.text,
          address: _addressController.text,
          gender: _selectedGender ?? '',
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is RegisterSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  registrationSuccessful,
                  style: TextStyle(fontFamily: 'Alexandria'),
                ),
                backgroundColor: Colors.green,
              ),
            );
            navigateAndFinish(context, const LoginScreen());
          } else if (state is RegisterErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
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
          final isLoading = state is RegisterLoadingState;

          return ThemedScaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
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
                        size: 60,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      register,
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

                    // Step Indicator
                    RegistrationStepIndicator(
                      currentStep: _currentStep,
                      totalSteps: _totalSteps,
                    ),

                    const SizedBox(height: 32),

                    // Step Content
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCurrentStep(cubit),
                    ),

                    const SizedBox(height: 28),

                    // Navigation Buttons
                    Row(
                      children: [
                        // Back Button
                        if (_currentStep > 1)
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: isLoading ? null : _previousStep,
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
                                  back,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Alexandria',
                                  ),
                                ),
                              ),
                            ),
                          ),

                        if (_currentStep > 1) const SizedBox(width: 12),

                        // Next / Register Button
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _nextStep(cubit),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: fischerBlue100,
                                foregroundColor: fischerBlue900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: fischerBlue900,
                                      ),
                                    )
                                  : Text(
                                      _currentStep < _totalSteps
                                          ? next
                                          : register,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Alexandria',
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.white38, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          child: Divider(color: Colors.white38, thickness: 1),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Already have an account - Login
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          navigateAndFinish(context, const LoginScreen());
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
                          alreadyHaveAccount,
                          style: TextStyle(
                            fontSize: 16,
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
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep(AuthCubit cubit) {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2(cubit);
      default:
        return _buildStep1();
    }
  }

  /// Step 1: Personal Information
  Widget _buildStep1() {
    return Form(
      key: _formKeyStep1,
      child: Column(
        key: const ValueKey(1),
        children: [
          // Full Name
          CustomTextField(
            controller: _fullNameController,
            hintText: enterName,
            labelText: fullName,
            prefixIconData: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return enterName;
              }
              if (value.length < 3 || value.length > 50) {
                return nameValidation;
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Username
          CustomTextField(
            controller: _usernameController,
            hintText: usernameValidation,
            labelText: username,
            prefixIconData: Icons.alternate_email,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return usernameValidation;
              }
              if (value.length < 3 || value.length > 20) {
                return usernameValidation;
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Phone
          CustomTextField(
            controller: _phoneController,
            hintText: enterPhone,
            labelText: phone,
            prefixIconData: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return enterPhone;
              }
              if (value.length < 10 || value.length > 15) {
                return phoneValidation;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Step 2: Account Information
  Widget _buildStep2(AuthCubit cubit) {
    return Form(
      key: _formKeyStep2,
      child: Column(
        key: const ValueKey(2),
        children: [
          // Email
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
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return pleaseEnterValidEmail;
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Password
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

          const SizedBox(height: 20),

          // Confirm Password
          CustomTextField(
            controller: _confirmPasswordController,
            hintText: confirmPassword,
            labelText: confirmPassword,
            prefixIconData: Icons.lock_outline,
            obscureText: !cubit.isConfirmPasswordVisible,
            suffixIcon: IconButton(
              onPressed: () => cubit.toggleConfirmPasswordVisibility(),
              icon: Icon(
                cubit.isConfirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.white70,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return enterConfirmNewPassword;
              }
              if (value != _passwordController.text) {
                return passwordsDoNotMatch;
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Address
          CustomTextField(
            controller: _addressController,
            hintText: addressValidation,
            labelText: address,
            prefixIconData: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return addressValidation;
              }
              if (value.length < 5 || value.length > 100) {
                return addressValidation;
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Gender Dropdown
          _buildDropdownField(
            labelText: gender,
            value: _selectedGender,
            icon: Icons.wc_outlined,
            items: [
              DropdownMenuItem(value: 'male', child: Text(male)),
              DropdownMenuItem(value: 'female', child: Text(female)),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return fillAllFields;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required String? value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required FormFieldValidator<String>? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value, // ignore: deprecated_member_use
      items: items,
      onChanged: onChanged,
      validator: validator,
      dropdownColor: fischerBlue700,
      iconEnabledColor: Colors.white70,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontFamily: 'Alexandria',
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Alexandria',
        ),
        prefixIcon: Icon(icon, color: Colors.white),
        errorStyle: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
