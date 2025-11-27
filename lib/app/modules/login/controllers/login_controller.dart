import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends GetxController {
  // Form key
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable states
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final rememberMe = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Get Supabase client instance
  final _supabase = Supabase.instance.client;

  // Toggle remember me
  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  // Validators
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  // MAIN LOGIN FUNCTION
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = response.user;

      if (user != null) {
        // === NEW PART: AUTO GENERATE PROFILE IF NOT EXIST ===
        final userId = user.id;

        // Check if profile exists
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        // If profile not exist, create one
        if (profile == null) {
          await _supabase.from('profiles').insert({
            'id': userId,
            'username': user.email?.split('@').first ?? 'User',
            'email': user.email,
            'sosmed': '',
            'photo_url': null,
          });
        }

        // Navigate to home
        Get.offAllNamed('/home');

        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } on AuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Google Login (dummy)
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      // TODO: Implement Google Sign In
      await Future.delayed(const Duration(seconds: 2));

      Get.offAllNamed('/home');

      Get.snackbar(
        'Success',
        'Logged in with Google!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Google sign in failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navigation
  void navigateToSignup() => Get.toNamed('/signup');
  void navigateToForgotPassword() => Get.toNamed('/forgot-password');
}
