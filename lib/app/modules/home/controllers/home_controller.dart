import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/task_models.dart';

class HomeController extends GetxController {
  final supabase = Supabase.instance.client;
  final Rx<Map<String, dynamic>?> userProfile = Rx<Map<String, dynamic>?>(null);
  final RxList<Task> allTasks = <Task>[].obs;

  final RxString selectedFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadTasks();
  }

  // Memuat profil pengguna yang sedang login
  Future<void> loadUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .single();
        
        if (response != null) {
          userProfile.value = response;
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // ============================================================
  // 📹 LOAD TASKS from Supabase
  // ============================================================
  Future<void> loadTasks() async {
    try {
      isLoading.value = true;
      final authUser = supabase.auth.currentUser;
      
      if (authUser == null) {
        Get.offAllNamed('/login');
        return;
      }

      final response = await supabase
          .from('tasks')
          .select()
          .eq('user_id', authUser.id)
          .order('created_at', ascending: false);

      allTasks.value = (response as List)
          .map((json) => Task.fromSupabase(json))
          .toList();

      print('Loaded ${allTasks.length} tasks from Supabase');
    } catch (e) {
      print('Error loading tasks: $e');
      // Jika error, tetap tampilkan UI kosong
      allTasks.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // 📹 GET FILTERED TASKS
  // ============================================================
  List<Task> get filteredTasks {
    List<Task> tasks = allTasks;

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      tasks = tasks.where((task) {
        return task.title
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            task.description
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply time filter
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (selectedFilter.value) {
      case 'Today':
        tasks = tasks.where((task) {
          final taskDate = DateTime(
              task.dateTime.year, task.dateTime.month, task.dateTime.day);
          return taskDate.isAtSameMomentAs(today);
        }).toList();
        break;
      case 'Upcoming':
        tasks = tasks.where((task) {
          final taskDate = DateTime(
              task.dateTime.year, task.dateTime.month, task.dateTime.day);
          return taskDate.isAfter(today);
        }).toList();
        break;
    }

    return tasks;
  }

  // ============================================================
  // 📹 GET TODAY'S TASKS COUNT
  // ============================================================
  int get todayTasksCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return allTasks.where((task) {
      final taskDate =
          DateTime(task.dateTime.year, task.dateTime.month, task.dateTime.day);
      return taskDate.isAtSameMomentAs(today) && !task.isCompleted;
    }).length;
  }

  // ============================================================
  // 📹 CHANGE FILTER
  // ============================================================
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  // ============================================================
  // 📹 SEARCH TASKS
  // ============================================================
  void searchTasks(String query) {
    searchQuery.value = query;
  }

  // ============================================================
  // 📹 ADD NEW TASK to Supabase
  // ============================================================
  Future<void> addTask(Task task) async {
    try {
      isLoading.value = true;
      final authUser = supabase.auth.currentUser;
      
      if (authUser == null) {
        Get.offAllNamed('/login');
        return;
      }

      // Konversi warna ke format yang lebih kecil (hanya menyimpan nilai RGB, tanpa alpha)
      final colorValue = task.color & 0xFFFFFF; // Hanya ambil nilai RGB saja

      await supabase.from('tasks').insert({
        'user_id': authUser.id,
        'title': task.title,
        'description': task.description,
        'is_completed': task.isCompleted,
        'due_date': task.dateTime.toIso8601String(),
        'color': colorValue, // Gunakan nilai warna yang sudah dikonversi
      });

      await loadTasks();
      print('Task added successfully');
    } catch (e) {
      print('Error adding task: $e');
      Get.snackbar(
        'Error',
        'Gagal menambahkan task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // 📹 UPDATE TASK in Supabase
  // ============================================================
  Future<void> updateTask(String id, Task updatedTask) async {
    try {
      isLoading.value = true;

      // Konversi warna ke format yang lebih kecil (hanya menyimpan nilai RGB, tanpa alpha)
      final colorValue = updatedTask.color & 0xFFFFFF;

      await supabase.from('tasks').update({
        'title': updatedTask.title,
        'description': updatedTask.description,
        'is_completed': updatedTask.isCompleted,
        'due_date': updatedTask.dateTime.toIso8601String(),
        'color': colorValue, // Gunakan nilai warna yang sudah dikonversi
      }).eq('id', int.parse(id));

      await loadTasks();
      print('Task updated successfully');
    } catch (e) {
      print('Error updating task: $e');
      Get.snackbar(
        'Error',
        'Gagal memperbarui task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // 📹 TOGGLE TASK COMPLETION
  // ============================================================
  Future<void> toggleTaskCompletion(String id) async {
    try {
      final task = allTasks.firstWhere((t) => t.id == id);
      final newStatus = !task.isCompleted;

      await supabase.from('tasks').update({
        'is_completed': newStatus,
      }).eq('id', int.parse(id));

      // Update lokal
      task.isCompleted = newStatus;
      allTasks.refresh();
      
      print('Task completion toggled');
    } catch (e) {
      print('Error toggling task: $e');
      Get.snackbar(
        'Error',
        'Failed to update task status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // 📹 DELETE TASK from Supabase
  // ============================================================
  Future<void> deleteTask(String id) async {
    try {
      await supabase.from('tasks').delete().eq('id', int.parse(id));

      // Remove dari list lokal
      allTasks.removeWhere((task) => task.id == id);
      
      print('Task deleted successfully');
    } catch (e) {
      print('Error deleting task: $e');
      Get.snackbar(
        'Error',
        'Failed to delete task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // 📹 CLEAR ALL TASKS
  // ============================================================
  Future<void> clearAllTasks() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return;

      await supabase
          .from('tasks')
          .delete()
          .eq('user_id', authUser.id);

      allTasks.clear();
      
      Get.snackbar(
        'Success',
        'All tasks cleared',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error clearing tasks: $e');
      Get.snackbar(
        'Error',
        'Failed to clear tasks',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}