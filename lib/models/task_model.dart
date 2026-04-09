import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum TaskStatus { todo, inProgress, review, done }

enum Priority { low, medium, high, critical }

enum Department { dev, art, design, audio, qa, pm }

class TaskModel {
  final String id;
  String title;
  String description;
  Department department;
  TaskStatus status;
  Priority priority;
  String assignee;
  DateTime dueDate;
  List<String> tags;
  int progress; // 0-100
  DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.department,
    this.status = TaskStatus.todo,
    this.priority = Priority.medium,
    required this.assignee,
    required this.dueDate,
    this.tags = const [],
    this.progress = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class DepartmentInfo {
  final String name;
  final String emoji;
  final Color color;
  final String description;
  final IconData icon;

  const DepartmentInfo({
    required this.name,
    required this.emoji,
    required this.color,
    required this.description,
    required this.icon,
  });
}

class AppData {
  static final Map<Department, DepartmentInfo> departments = {
    Department.dev: DepartmentInfo(
      name: 'Yazılım',
      emoji: '⚙️',
      color: AppTheme.accentCyan,
      description: 'Oyun motoru, mekanikler, sistemler',
      icon: Icons.code_rounded,
    ),
    Department.art: DepartmentInfo(
      name: 'Görsel Tasarım',
      emoji: '🎨',
      color: AppTheme.accentPink,
      description: 'Konsept, 3D, Karakterler',
      icon: Icons.palette_rounded,
    ),
    Department.design: DepartmentInfo(
      name: 'Oyun Tasarımı',
      emoji: '🎮',
      color: AppTheme.accentPurple,
      description: 'Mekanik dengesi, bölüm tasarımı',
      icon: Icons.gamepad_rounded,
    ),
    Department.audio: DepartmentInfo(
      name: 'Ses & Müzik',
      emoji: '🎵',
      color: AppTheme.accentGold,
      description: 'Efektler, müzik, dublaj',
      icon: Icons.music_note_rounded,
    ),
    Department.qa: DepartmentInfo(
      name: 'Test & QA',
      emoji: '🛡️',
      color: AppTheme.accentGreen,
      description: 'Hata ayıklama, performans',
      icon: Icons.bug_report_rounded,
    ),
    Department.pm: DepartmentInfo(
      name: 'Üretim',
      emoji: '📋',
      color: const Color(0xFFFF8C42), // Burnt Orange
      description: 'Yol haritası, kilometre taşları',
      icon: Icons.dashboard_rounded,
    ),
  };


  static final List<TaskModel> sampleTasks = [
    TaskModel(
      id: '1',
      title: 'Ana karakter hareket mekaniği',
      description: 'Hızlanma eğrileri ile pürüzsüz karakter hareketi uygulayın',
      department: Department.dev,
      status: TaskStatus.inProgress,
      priority: Priority.critical,
      assignee: 'Ahmet K.',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      tags: ['oynanış', 'temel'],
      progress: 65,
    ),
    TaskModel(
      id: '2',
      title: 'Ana karakter konsept çizimi',
      description: 'Karakter tasarımı için 3 konsept varyasyonu',
      department: Department.art,
      status: TaskStatus.review,
      priority: Priority.high,
      assignee: 'Selin Y.',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      tags: ['karakter', 'konsept'],
      progress: 90,
    ),
    TaskModel(
      id: '3',
      title: 'Bölüm 1 harita tasarımı',
      description: 'Bulmaca akışı ile eğitim bölümü için tam GDD',
      department: Department.design,
      status: TaskStatus.done,
      priority: Priority.high,
      assignee: 'Mert A.',
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['bölüm-tasarımı', 'eğitim'],
      progress: 100,
    ),
    TaskModel(
      id: '4',
      title: 'Ortam müziği - Orman',
      description: 'Dinamik katmanlara sahip 3 dakikalık döngüsel ortam parçası',
      department: Department.audio,
      status: TaskStatus.todo,
      priority: Priority.medium,
      assignee: 'Deniz Ö.',
      dueDate: DateTime.now().add(const Duration(days: 10)),
      tags: ['müzik', 'ortam'],
      progress: 0,
    ),
    TaskModel(
      id: '5',
      title: 'Sprint 3 regresyon testi',
      description: 'Android/iOS derlemelerinde tam oynanış testi',
      department: Department.qa,
      status: TaskStatus.inProgress,
      priority: Priority.high,
      assignee: 'Zeynep B.',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      tags: ['regresyon', 'mobil'],
      progress: 40,
    ),
    TaskModel(
      id: '6',
      title: 'Alfa sürüm planlaması',
      description: 'Alfa kapsamını, risklerini ve kaynak dağılımını belirleme',
      department: Department.pm,
      status: TaskStatus.inProgress,
      priority: Priority.critical,
      assignee: 'Kemal S.',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      tags: ['sürüm', 'alfa'],
      progress: 55,
    ),
    TaskModel(
      id: '7',
      title: 'Envanter sistemi arayüzü',
      description: 'Sürükle bırak destekli ızgara tabanlı envanter',
      department: Department.dev,
      status: TaskStatus.todo,
      priority: Priority.medium,
      assignee: 'Ahmet K.',
      dueDate: DateTime.now().add(const Duration(days: 14)),
      tags: ['arayüz', 'envanter'],
      progress: 0,
    ),
    TaskModel(
      id: '8',
      title: 'Düşman yapay zeka sistemi',
      description: 'Devriye, kovalama, saldırı ve geri çekilme için state machine',
      department: Department.dev,
      status: TaskStatus.todo,
      priority: Priority.high,
      assignee: 'Emre T.',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      tags: ['yz', 'düşman'],
      progress: 10,
    ),
    TaskModel(
      id: '9',
      title: 'Arayüz ses tasarımı',
      description: 'Düğme tıklamaları, geçişler, bildirimler',
      department: Department.audio,
      status: TaskStatus.done,
      priority: Priority.low,
      assignee: 'Deniz Ö.',
      dueDate: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['ses', 'arayüz'],
      progress: 100,
    ),
    TaskModel(
      id: '10',
      title: 'Performans izleme - GPU',
      description: 'Draw call darboğazlarını belirle ve çöz',
      department: Department.qa,
      status: TaskStatus.todo,
      priority: Priority.critical,
      assignee: 'Zeynep B.',
      dueDate: DateTime.now().add(const Duration(days: 4)),
      tags: ['performans', 'gpu'],
      progress: 0,
    ),
  ];
}

extension TaskStatusExtension on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'YAPILACAK';
      case TaskStatus.inProgress:
        return 'DEVAM EDİYOR';
      case TaskStatus.review:
        return 'İNCELEME';
      case TaskStatus.done:
        return 'TAMAMLANDI';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.todo:
        return AppTheme.textSecondary;
      case TaskStatus.inProgress:
        return AppTheme.accentCyan;
      case TaskStatus.review:
        return AppTheme.accentGold;
      case TaskStatus.done:
        return AppTheme.accentGreen;
    }
  }
}

extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.low:
        return 'DÜŞÜK';
      case Priority.medium:
        return 'ORTA';
      case Priority.high:
        return 'YÜKSEK';
      case Priority.critical:
        return 'KRİTİK';
    }
  }

  Color get color {
    switch (this) {
      case Priority.low:
        return AppTheme.accentGreen;
      case Priority.medium:
        return AppTheme.accentGold;
      case Priority.high:
        return AppTheme.accentPink;
      case Priority.critical:
        return const Color(0xFFFF0000);
    }
  }
}
