import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = List.from(AppData.sampleTasks);
  Department? _selectedDepartment;
  TaskStatus? _selectedStatus;
  String _searchQuery = '';

  List<TaskModel> get allTasks => _tasks;

  Department? get selectedDepartment => _selectedDepartment;
  TaskStatus? get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;

  List<TaskModel> get filteredTasks {
    return _tasks.where((task) {
      final deptMatch = _selectedDepartment == null ||
          task.department == _selectedDepartment;
      final statusMatch =
          _selectedStatus == null || task.status == _selectedStatus;
      final searchMatch = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.assignee.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      return deptMatch && statusMatch && searchMatch;
    }).toList();
  }

  List<TaskModel> getTasksByDepartment(Department dept) {
    return _tasks.where((t) => t.department == dept).toList();
  }

  Map<TaskStatus, int> get statusCounts {
    final map = <TaskStatus, int>{};
    for (final status in TaskStatus.values) {
      map[status] = _tasks.where((t) => t.status == status).length;
    }
    return map;
  }

  Map<Department, int> get departmentTaskCounts {
    final map = <Department, int>{};
    for (final dept in Department.values) {
      map[dept] = _tasks.where((t) => t.department == dept).length;
    }
    return map;
  }

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.status == TaskStatus.done).length;
  int get criticalTasks =>
      _tasks.where((t) => t.priority == Priority.critical && t.status != TaskStatus.done).length;

  double get overallProgress {
    if (_tasks.isEmpty) return 0;
    final sum = _tasks.fold<int>(0, (acc, t) => acc + t.progress);
    return sum / _tasks.length;
  }

  void setDepartmentFilter(Department? dept) {
    _selectedDepartment = dept;
    notifyListeners();
  }

  void setStatusFilter(TaskStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void updateTask(TaskModel task) {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task;
      notifyListeners();
    }
  }

  void addTask(TaskModel task) {
    _tasks.add(task);
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void updateTaskProgress(String id, int progress) {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _tasks[idx].progress = progress;
      if (progress == 100) {
        _tasks[idx].status = TaskStatus.done;
      }
      notifyListeners();
    }
  }

  void updateTaskStatus(String id, TaskStatus status) {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _tasks[idx].status = status;
      if (status == TaskStatus.done) {
        _tasks[idx].progress = 100;
      }
      notifyListeners();
    }
  }
}
