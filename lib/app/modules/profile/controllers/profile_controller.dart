import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/user_model.dart';

class ProfileController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isEditing = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;

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
  // 📹 LOAD USER DATA from Supabase
  // ============================================================
  Future<void> loadUserData() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) {
        Get.offAllNamed('/login');
        return;
      }

      final response = await supabase
          .from('users')
          .select()
          .eq('id', authUser.id)
          .single();

      currentUser.value = UserModel.fromJson(response);

      usernameController.text = currentUser.value!.username;
      emailController.text = currentUser.value!.email;
      socialMediaController.text = currentUser.value!.socialMedia ?? '';

      print('✅ User data loaded: ${currentUser.value!.username}');
    } catch (e) {
      print('❌ Error loadUserData: $e');
    }
  }

  // ============================================================
  // 📹 UPDATE USER PROFILE
  // ============================================================
  Future<void> updateProfile() async {
    if (currentUser.value == null) return;

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
      print('❌ Error updateProfile: $e');
      Get.snackbar('Error', 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // 📸 PICK IMAGE FROM GALLERY
  // ============================================================
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        print('📷 Image selected: ${image.path}');
        await uploadAndUpdateProfileImage(image.path);
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ============================================================
  // 📸 TAKE PHOTO FROM CAMERA
  // ============================================================
  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        print('📷 Photo captured: ${photo.path}');
        await uploadAndUpdateProfileImage(photo.path);
      }
    } catch (e) {
      print('❌ Error taking photo: $e');
      Get.snackbar(
        'Error',
        'Failed to take photo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ============================================================
  // ☁️ UPLOAD AND UPDATE PROFILE IMAGE
  // ============================================================
  Future<void> uploadAndUpdateProfileImage(String imagePath) async {
    if (currentUser.value == null) {
      print('❌ No current user');
      return;
    }
    
    if (isUploadingImage.value) {
      print('⚠️ Upload already in progress');
      return;
    }

    print('🔄 Starting image upload process...');
    isUploadingImage.value = true;
    String? fileName; // Declare fileName here to use in the finally block

    try {
      final userId = currentUser.value!.id;
      print('👤 User ID: $userId');
      
      final file = File(imagePath);
      print('📂 File path: $imagePath');

      // Check file exists and is readable
      if (!await file.exists()) {
        throw Exception('File not found at path: $imagePath');
      }
      
      final fileSize = await file.length();
      print('📁 File size: $fileSize bytes');
      
      if (fileSize == 0) {
        throw Exception('File is empty');
      }

      // Generate filename with user ID and timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = imagePath.split('.').last.toLowerCase();
      fileName = 'profile-images/$userId/profile_$timestamp.$ext';
      print('📝 Generated filename: $fileName');

      // Read file as bytes with error handling
      print('📦 Reading file bytes...');
      final bytes = await file.readAsBytes().catchError((error) {
        print('❌ Error reading file: $error');
        throw Exception('Failed to read image file');
      });

      print('⬆️ Starting upload to Supabase Storage...');
      
      // Check and create bucket if needed
      try {
        await supabase.storage.getBucket('profile_pictures');
      } catch (e) {
        print('ℹ️ Profile pictures bucket not found, creating...');
        await supabase.storage.createBucket(
          'profile_pictures',
          const BucketOptions(
            public: true,
            fileSizeLimit: '50MB',
            allowedMimeTypes: ['image/*'],
          ),
        );
        print('✅ Created profile_pictures bucket');
      }

      // Upload the file
      print('📤 Uploading file...');
      await supabase.storage
          .from('profile_pictures')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$ext',
              upsert: true,
              cacheControl: '3600',
            ),
          )
          .timeout(const Duration(seconds: 30));

      print('✅ File uploaded successfully');

      // Get public URL
      final publicUrl = supabase.storage
          .from('profile_pictures')
          .getPublicUrl(fileName);
      print('🔗 Public URL: $publicUrl');

      if (publicUrl.isEmpty) {
        throw Exception('Failed to get public URL for uploaded image');
      }

      // Update user profile with new image URL
      print('💾 Updating user profile in database...');
      final updateResponse = await supabase
          .from('users')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      if (updateResponse.error != null) {
        throw Exception('Database update failed: ${updateResponse.error!.message}');
      }

      print('✅ Database updated successfully');

      // Update local state
      currentUser.value = currentUser.value!.copyWith(
        profileImage: publicUrl,
      );
      currentUser.refresh();

      print('🎉 Profile image updated successfully!');

      Get.snackbar(
        'Success',
        'Profile picture updated!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } on TimeoutException {
      Get.snackbar(
        'Upload Timeout',
        'The upload took too long. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      rethrow;
    } on Exception catch (e) {
      print('❌ Error in uploadAndUpdateProfileImage: $e');
      rethrow;

      Get.snackbar(
        'Upload Failed',
        'Failed to upload image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      print('🔄 Resetting upload state');
      // Ensure we always reset the loading state, even if an error occurs
      if (isUploadingImage.value) {
        isUploadingImage.value = false;
        print('✅ Upload state reset');
      }
    }
  }

  // ============================================================
  // 🗑️ REMOVE PROFILE IMAGE
  // ============================================================
  Future<void> removeProfileImage() async {
    if (currentUser.value == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Remove Profile Picture'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();

              if (isUploadingImage.value) return;
              isUploadingImage.value = true;

              try {
                final userId = currentUser.value!.id;

                await supabase.from('users').update({
                  'avatar_url': null,
                }).eq('id', userId);

                currentUser.value = currentUser.value!.copyWith(
                  profileImage: null,
                );
                currentUser.refresh();

                Get.snackbar(
                  'Success',
                  'Profile picture removed',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                print('❌ Error: $e');
                Get.snackbar(
                  'Error',
                  'Failed to remove picture',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } finally {
                isUploadingImage.value = false;
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📹 SHOW IMAGE PICKER DIALOG
  // ============================================================
  void showImagePickerDialog() {
    if (isUploadingImage.value) {
      Get.snackbar(
        'Please wait',
        'Upload in progress',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Update Profile Picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B9EB3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library, color: Color(0xFF6B9EB3)),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B9EB3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: Color(0xFF6B9EB3)),
              ),
              title: const Text('Take a Photo'),
              onTap: () {
                Get.back();
                takePhoto();
              },
            ),
            if (currentUser.value?.profileImage != null) ...[
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  removeProfileImage();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📹 LOAD STATISTICS
  // ============================================================
  Future<void> loadStatistics() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return;

      final total = await supabase
          .from('tasks')
          .select()
          .eq('user_id', authUser.id);

      final completed = await supabase
          .from('tasks')
          .select()
          .eq('user_id', authUser.id)
          .eq('is_completed', true);

      totalTasks.value = total.length;
      completedTasks.value = completed.length;

      print('📊 Stats: ${totalTasks.value} total, ${completedTasks.value} done');
    } catch (e) {
      print('❌ Error stats: $e');
      totalTasks.value = 0;
      completedTasks.value = 0;
    }
  }

  double getCompletionPercentage() {
    if (totalTasks.value == 0) return 0;
    return (completedTasks.value / totalTasks.value) * 100;
  }

  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      usernameController.text = currentUser.value!.username;
      emailController.text = currentUser.value!.email;
      socialMediaController.text = currentUser.value!.socialMedia ?? '';
    }
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
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