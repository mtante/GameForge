import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen>
    with SingleTickerProviderStateMixin {
  Department _selected = Department.dev;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectDept(Department dept) {
    setState(() => _selected = dept);
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final info = AppData.departments[_selected]!;

    return Consumer<TaskProvider>(builder: (context, provider, _) {
      final tasks = provider.getTasksByDepartment(_selected);
      final done = tasks.where((t) => t.status == TaskStatus.done).length;
      final inProgress =
          tasks.where((t) => t.status == TaskStatus.inProgress).length;
      final review = tasks.where((t) => t.status == TaskStatus.review).length;
      final todo = tasks.where((t) => t.status == TaskStatus.todo).length;

      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'DEPARTMANLAR',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),

            // Department selector - horizontal scroll
            SizedBox(
              height: 80,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: Department.values.length,
                itemBuilder: (context, index) {
                  final dept = Department.values[index];
                  final dInfo = AppData.departments[dept]!;
                  final isSelected = dept == _selected;

                  return GestureDetector(
                    onTap: () => _selectDept(dept),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? dInfo.color.withOpacity(0.15)
                            : AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? dInfo.color
                              : AppTheme.borderGlow,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: dInfo.color.withOpacity(0.2),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(dInfo.emoji,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            dInfo.name.split(' ').first.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Rajdhani',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: isSelected
                                  ? dInfo.color
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Department detail header
            FadeTransition(
              opacity: _animController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: info.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: info.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: info.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(info.icon, color: info.color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info.name.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: info.color,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              info.description,
                              style: TextStyle(
                                fontFamily: 'Rajdhani',
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${tasks.length}',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: info.color,
                            ),
                          ),
                          Text(
                            'GÖREV',
                            style: TextStyle(
                              fontFamily: 'Rajdhani',
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Status chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _miniChip('$todo', 'YAPILACAK', AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  _miniChip('$inProgress', 'AKTİF', AppTheme.accentCyan),
                  const SizedBox(width: 8),
                  _miniChip('$review', 'İNCELEME', AppTheme.accentGold),
                  const SizedBox(width: 8),
                  _miniChip('$done', 'TAMAM', AppTheme.accentGreen),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Task list
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(info.emoji,
                              style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 12),
                          Text(
                            'Bu departmanda görev yok',
                            style: TextStyle(
                              fontFamily: 'Rajdhani',
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : FadeTransition(
                      opacity: _animController,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TaskCard(task: tasks[index]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _miniChip(String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 8,
                letterSpacing: 1,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
