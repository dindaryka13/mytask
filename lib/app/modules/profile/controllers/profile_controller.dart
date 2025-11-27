import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/user_model.dart';

class ProfileController extends GetxController {
  final supabase = Supabase.instance.client;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isEditing = false.obs;
  final RxBool isLoading = false.obs;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final socialMediaController = TextEditingController();

  final RxInt totalTasks = 0.obs;
  final RxInt completedTasks = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadStatistics();
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    socialMediaController.dispose();
    super.onClose();
  }

  // ============================================================
  // 🔹 LOAD USER DATA from Supabase
  // ============================================================
  Future<void> loadUserData() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return;

      final response = await supabase
          .from('users')
          .select()
          .eq('id', authUser.id)
          .single();

      currentUser.value = UserModel.fromJson(response);

      usernameController.text = currentUser.value!.username;
      emailController.text = currentUser.value!.email;
      socialMediaController.text = currentUser.value!.socialMedia ?? '';

    } catch (e) {
      print('Error loadUserData: $e');
      Get.snackbar('Error', 'Failed to load profile');
    }
  }

  // ============================================================
  // 🔹 UPDATE USER PROFILE
  // ============================================================
  Future<void> updateProfile() async {
    if (currentUser.value == null) return;

    // Validation
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Username cannot be empty',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    if (!emailController.text.contains('@')) {
      Get.snackbar('Error', 'Enter a valid email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      await supabase.from('users').update({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'sosmed': socialMediaController.text.trim(),
      }).eq('id', currentUser.value!.id);

      currentUser.value = currentUser.value!.copyWith(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        socialMedia: socialMediaController.text.trim(),
      );

      isEditing.value = false;

      Get.snackbar('Success', 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }

    isLoading.value = false;
  }

  // ============================================================
  // 🔹 UPDATE PROFILE IMAGE (Avatar)
  // ============================================================
  Future<void> updateProfileImage(String imageUrl) async {
    try {
      final userId = currentUser.value!.id;

      await supabase.from('users').update({'avatar_url': imageUrl}).eq('id', userId);

      currentUser.value = currentUser.value!.copyWith(profileImage: imageUrl);

      Get.snackbar(
        'Success',
        'Profile picture updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error updating image: $e');
      Get.snackbar('Error', 'Failed to update image');
    }
  }

  // ============================================================
  // 🔹 LOAD STATISTICS from Supabase
  // ============================================================
  Future<void> loadStatistics() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return;

      // total tasks
      final total = await supabase
          .from('tasks')
          .select()
          .eq('user_id', authUser.id);

      // completed tasks
      final completed = await supabase
          .from('tasks')
          .select()
          .eq('user_id', authUser.id)
          .eq('is_completed', true);

      totalTasks.value = total.length;
      completedTasks.value = completed.length;

    } catch (e) {
      print('Error loadStatistics: $e');
      totalTasks.value = 0;
      completedTasks.value = 0;
    }
  }

  // ============================================================
  // 🔹 GET COMPLETION PERCENTAGE
  // ============================================================
  double getCompletionPercentage() {
    if (totalTasks.value == 0) return 0;
    return (completedTasks.value / totalTasks.value) * 100;
  }

  // ============================================================
  // 🔹 TOGGLE EDIT MODE
  // ============================================================
  void toggleEditMode() {
    isEditing.value = !isEditing.value;

    if (!isEditing.value) {
      usernameController.text = currentUser.value!.username;
      emailController.text = currentUser.value!.email;
      socialMediaController.text = currentUser.value!.socialMedia ?? '';
    }
  }

  // ============================================================
  // 🔹 LOGOUT
  // ============================================================
  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await supabase.auth.signOut();
              Get.offAllNamed('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
