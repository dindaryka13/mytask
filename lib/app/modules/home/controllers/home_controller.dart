import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/task_models.dart';

class HomeController extends GetxController {
  final storage = GetStorage();

  final RxList<Task> allTasks = <Task>[].obs;
  final RxString selectedFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  // Load tasks from storage
  void loadTasks() {
    final tasksJson = storage.read<List>('tasks');
    if (tasksJson != null) {
      allTasks.value = tasksJson
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      // Add sample tasks
      addSampleTasks();
    }
  }

  // Save tasks to storage
  void saveTasks() {
    final tasksJson = allTasks.map((task) => task.toJson()).toList();
    storage.write('tasks', tasksJson);
  }

  // Add sample tasks
  void addSampleTasks() {
    final now = DateTime.now();
    allTasks.addAll([
      Task(
        id: '1',
        title: 'Sample Task 1',
        description: 'Design new homepage for landing site',
        dateTime: DateTime(now.year, now.month, now.day, 10, 0),
        color: 0xFFE8C4D8,
        category: '',
      ),
      Task(
        id: '2',
        title: 'Sample Task 2',
        description: 'Design new homepage for landing site',
        dateTime: DateTime(now.year, now.month, now.day, 10, 0),
        color: 0xFFC4E8D8,
        category: '',
      ),
      Task(
        id: '3',
        title: 'Sample Task 3',
        description: 'Design new homepage for landing site',
        dateTime: DateTime(now.year, now.month, now.day, 10, 0),
        color: 0xFFE8C4D8,
        category: '',
      ),
    ]);
    saveTasks();
  }

  // Get filtered tasks
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

  // Get tasks count for today
  int get todayTasksCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return allTasks.where((task) {
      final taskDate =
          DateTime(task.dateTime.year, task.dateTime.month, task.dateTime.day);
      return taskDate.isAtSameMomentAs(today) && !task.isCompleted;
    }).length;
  }

  // Change filter
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  // Search tasks
  void searchTasks(String query) {
    searchQuery.value = query;
  }

  // Add new task
  void addTask(Task task) {
    allTasks.add(task);
    saveTasks();
  }

  // Update task
  void updateTask(String id, Task updatedTask) {
    final index = allTasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      allTasks[index] = updatedTask;
      saveTasks();
    }
  }

  // Toggle task completion
  void toggleTaskCompletion(String id) {
    final index = allTasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      allTasks[index].isCompleted = !allTasks[index].isCompleted;
      allTasks.refresh();
      saveTasks();
    }
  }

  // Delete task
  void deleteTask(String id) {
    allTasks.removeWhere((task) => task.id == id);
    saveTasks();
  }

  // Clear all tasks
  void clearAllTasks() {
    allTasks.clear();
    saveTasks();
  }
}
