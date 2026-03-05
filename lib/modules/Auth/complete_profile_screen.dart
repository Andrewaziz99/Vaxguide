import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/auth/auth_cubit.dart';
import 'package:vaxguide/core/blocs/auth/auth_states.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';
import 'package:vaxguide/layout/layout.dart';
import 'package:vaxguide/shared/widgets.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String uid;
  final String email;
  final String displayName;

  const CompleteProfileScreen({
    super.key,
    required this.uid,
    required this.email,
    required this.displayName,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    // Pre-fill the full name from Google display name
    _fullNameController = TextEditingController(text: widget.displayName);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is CompleteProfileSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  profileCompletedSuccessfully,
                  style: TextStyle(fontFamily: 'Alexandria'),
                ),
                backgroundColor: Colors.green,
              ),
            );
            navigateAndFinish(context, const AppLayout());
          } else if (state is CompleteProfileErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error,
                  style: const TextStyle(fontFamily: 'Alexandria'),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = AuthCubit.get(context);
          final isLoading = state is CompleteProfileLoadingState;

          return ThemedScaffold(
            body: Center(
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
                          Icons.person_add_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        completeYourProfile,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Alexandria',
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      const Text(
                        completeProfileSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontFamily: 'Alexandria',
                        ),
                      ),

                      const SizedBox(height: 32),

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
                      DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text(male)),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text(female),
                          ),
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
                        dropdownColor: fischerBlue700,
                        iconEnabledColor: Colors.white70,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Alexandria',
                        ),
                        decoration: const InputDecoration(
                          labelText: gender,
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Alexandria',
                          ),
                          prefixIcon: Icon(
                            Icons.wc_outlined,
                            color: Colors.white,
                          ),
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    cubit.completeGoogleProfile(
                                      uid: widget.uid,
                                      fullName: _fullNameController.text,
                                      username: _usernameController.text,
                                      phone: _phoneController.text,
                                      email: widget.email,
                                      address: _addressController.text,
                                      gender: _selectedGender ?? '',
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
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: fischerBlue900,
                                  ),
                                )
                              : const Text(
                                  save,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
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
          );
        },
      ),
    );
  }
}
