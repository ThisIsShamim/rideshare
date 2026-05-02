import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // New state variables for Gender and Role
  String? _selectedGender;
  String? _selectedRole;
  final List<String> _genderOptions = ['Male', 'Female'];
  final List<String> _roleOptions = ['Student', 'Teacher', 'Staff'];

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // void _handleSignUp() {
  //   if (!_formKey.currentState!.validate()) return;
  //   if (!_agreeToTerms) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'Please agree to the Terms & Privacy Policy',
  //           style: GoogleFonts.plusJakartaSans(fontSize: 11.sp),
  //         ),
  //         backgroundColor: AppTheme.error,
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //       ),
  //     );
  //     return;
  //   }
  //   setState(() => _isLoading = true);

  //   // You can now access _selectedGender and _selectedRole here
  //   // print("Gender: $_selectedGender, Role: $_selectedRole");

  //   Future.delayed(const Duration(milliseconds: 900), () {
  //     if (!mounted) return;
  //     setState(() => _isLoading = false);
  //     Navigator.pushReplacementNamed(context, AppRoutes.findARideScreen);
  //   });
  // }

  // Code er upore import korte bhulbe na:
  // import 'package:http/http.dart' as http;
  // import 'dart:convert';

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please agree to Terms')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Firebase Auth (create account)
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      String uid = userCredential.user!.uid;

      // 2️⃣ Firestore save
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid,
        "fullname": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "gender": _selectedGender,
        "usertype": _selectedRole,
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account Created Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.findARideScreen);
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    child: _buildForm(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark, AppTheme.primary, AppTheme.secondary],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      padding: EdgeInsets.fromLTRB(5.w, 4.h, 5.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 9.w,
              height: 9.w,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(38),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 5.w,
              ),
            ),
          ),
          SizedBox(height: 2.5.h),
          Text(
            'Create account',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 0.6.h),
          Text(
            'Join thousands of riders and drivers today',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 1.h),
          _buildLabel('Full name'),
          SizedBox(height: 0.8.h),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Jane Doe',
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: AppTheme.muted,
                size: 5.w,
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Name is required';
              if (v.trim().length < 2) return 'Enter your full name';
              return null;
            },
          ),
          SizedBox(height: 2.h),

          // --- NEW GENDER DROPDOWN ---
          _buildLabel('Gender'),
          SizedBox(height: 0.8.h),
          _buildDropdown(
            value: _selectedGender,
            hint: 'Select Gender',
            icon: Icons.wc_outlined,
            items: _genderOptions,
            onChanged: (val) => setState(() => _selectedGender = val),
            validatorMsg: 'Please select your gender',
          ),
          SizedBox(height: 2.h),

          // --- NEW ROLE DROPDOWN ---
          _buildLabel('I am a'),
          SizedBox(height: 0.8.h),
          _buildDropdown(
            value: _selectedRole,
            hint: 'Select Role',
            icon: Icons.badge_outlined,
            items: _roleOptions,
            onChanged: (val) => setState(() => _selectedRole = val),
            validatorMsg: 'Please select your role',
          ),
          SizedBox(height: 2.h),

          _buildLabel('Email address'),
          SizedBox(height: 0.8.h),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'you@example.com',
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                color: AppTheme.muted,
                size: 5.w,
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(
                r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$',
              ).hasMatch(v.trim())) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 2.h),
          _buildLabel('Password'),
          SizedBox(height: 0.8.h),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: AppTheme.muted,
                size: 5.w,
              ),
              suffixIcon: GestureDetector(
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.muted,
                  size: 5.w,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),
          SizedBox(height: 2.h),
          _buildLabel('Confirm password'),
          SizedBox(height: 0.8.h),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: AppTheme.muted,
                size: 5.w,
              ),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                child: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.muted,
                  size: 5.w,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: 2.h),
          _buildTermsRow(),
          SizedBox(height: 2.5.h),
          SizedBox(
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
                disabledBackgroundColor: AppTheme.primary.withAlpha(153),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Create Account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 2.5.h),
          _buildLoginPrompt(),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  // --- NEW HELPER WIDGET FOR DROPDOWNS ---
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    required String validatorMsg,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.muted),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.muted),
        prefixIcon: Icon(icon, color: AppTheme.muted, size: 5.w),
        // Adding consistent content padding
        contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? validatorMsg : null,
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildTermsRow() {
    return GestureDetector(
      onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 5.w,
            height: 5.w,
            child: Checkbox(
              value: _agreeToTerms,
              onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
              activeColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Sign In',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
