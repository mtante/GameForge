import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../widgets/glowing_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final urgentTasks = provider.allTasks
            .where((t) =>
                t.priority == Priority.critical &&
                t.status != TaskStatus.done)
            .toList();

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentCyan.withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('⚡', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GÖREV KONTROL MERKEZİ',
                            style: TextStyle(
                              fontFamily: 'Rajdhani',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 4,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'KOMUTAN',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (provider.criticalTasks > 0)
                        _buildCriticalBadge(provider.criticalTasks),
                    ],
                  ),
                ),
              ),

              // Overall Progress Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GlowingCard(
                    glowColor: AppTheme.accentCyan,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PROJE İLERLEME DURUMU',
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 11,
                                  letterSpacing: 2,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '${provider.overallProgress.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.accentCyan,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: provider.overallProgress / 100,
                              backgroundColor: AppTheme.bgDeep,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.accentCyan,
                              ),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _statChip(
                                  '${provider.totalTasks}', 'TOPLAM', AppTheme.textSecondary),
                              const SizedBox(width: 12),
                              _statChip(
                                  '${provider.statusCounts[TaskStatus.inProgress] ?? 0}',
                                  'AKTİF',
                                  AppTheme.accentCyan),
                              const SizedBox(width: 12),
                              _statChip(
                                  '${provider.statusCounts[TaskStatus.review] ?? 0}',
                                  'İNCELEME',
                                  AppTheme.accentGold),
                              const SizedBox(width: 12),
                              _statChip(
                                  '${provider.completedTasks}',
                                  'TAMAM',
                                  AppTheme.accentGreen),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Department bars
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'DEPARTMANLAR',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      letterSpacing: 3,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 120,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: Department.values.length,
                    itemBuilder: (context, index) {
                      final dept = Department.values[index];
                      final info = AppData.departments[dept]!;
                      final tasks = provider.getTasksByDepartment(dept);
                      final done = tasks.where((t) => t.status == TaskStatus.done).length;
                      final progress = tasks.isEmpty ? 0.0 : done / tasks.length;

                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: info.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(info.emoji, style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 6),
                            Text(
                              info.name.split(' ').first.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 9,
                                letterSpacing: 1,
                                color: info.color,
                              ),
                            ),
                            const Spacer(),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: AppTheme.bgDeep,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(info.color),
                                minHeight: 4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$done/${tasks.length}',
                              style: TextStyle(
                                fontFamily: 'Rajdhani',
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Critical tasks
              if (urgentTasks.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Row(
                      children: [
                        Text(
                          '🔴  KRİTİK GÖREVLER',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 11,
                            letterSpacing: 3,
                            color: AppTheme.accentPink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: TaskCard(task: urgentTasks[index]),
                    ),
                    childCount: urgentTasks.length,
                  ),
                ),
              ],

              // Recent tasks
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text(
                    'DEVAM EDEN GÖREVLER',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      letterSpacing: 3,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final inProgressTasks = provider.allTasks
                        .where((t) => t.status == TaskStatus.inProgress)
                        .toList();
                    if (index >= inProgressTasks.length) return null;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: TaskCard(task: inProgressTasks[index]),
                    );
                  },
                  childCount: provider.allTasks
                      .where((t) => t.status == TaskStatus.inProgress)
                      .length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCriticalBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentPink.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentPink,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count KRİTİK',
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
              color: AppTheme.accentPink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 9,
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
