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

  // MAIN LOGIN FUNCTION (SIMPLE)
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final email = emailController.text.trim();
      final password = passwordController.text;
      
      print(' Attempting login for: $email');

      // Sign in dengan Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      print(' Auth successful. User ID: ${user?.id}');

      if (user != null) {
        // Langsung masuk ke home
        Get.offAllNamed('/home');
      }
    } on AuthException catch (e) {
      print(' Auth error: ${e.message}');
      
      String errorMessage;
      
      // More specific error messages
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        errorMessage = 'Email atau password salah. Silakan coba lagi.';
      } else if (e.message.toLowerCase().contains('email not confirmed')) {
        errorMessage = 'Email belum diverifikasi. Silakan periksa email Anda untuk verifikasi.';
      } else if (e.message.toLowerCase().contains('network')) {
        errorMessage = 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
      } else {
        errorMessage = 'Terjadi kesalahan: ${e.message}';
      }
      
      // Reset password field
      passwordController.clear();
      
      Get.snackbar(
        'Gagal Masuk',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      print(' Unexpected error: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan. Silakan coba lagi nanti.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Google Login
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.mytask://login-callback',
      );

      // Wait for callback
      await Future.delayed(const Duration(seconds: 2));
      
      final user = _supabase.auth.currentUser;
      
      if (user != null) {
        // Check/create profile
        final profile = await _supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profile == null) {
          await _supabase.from('users').insert({
            'id': user.id,
            'username': user.email?.split('@').first ?? 'User',
            'email': user.email,
            'avatar_url': user.userMetadata?['avatar_url'],
            'bio': null,
            'sosmed': null,
          });
        }

        Get.offAllNamed('/home');

        Get.snackbar(
          'Success',
          'Logged in with Google!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      print('Google login error: $e');
      Get.snackbar(
        'Error',
        'Google sign in is not available yet',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
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