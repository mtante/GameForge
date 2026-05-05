import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../widgets/glowing_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'GECE NÖBETI';
    if (hour < 12) return 'GÜNAYDИН';
    if (hour < 17) return 'İYİ GÜNLER';
    if (hour < 21) return 'İYİ AKŞAMLAR';
    return 'İYİ GECELER';
  }

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
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentCyan.withOpacity(0.4),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('⚡', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: const TextStyle(
                              fontFamily: 'Rajdhani',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
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
                        AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (context, child) =>
                              _buildCriticalBadge(provider.criticalTasks),
                        ),
                    ],
                  ),
                ),
              ),

              // Date chip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderGlow),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 11, color: AppTheme.accentCyan),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(DateTime.now()),
                              style: const TextStyle(
                                fontFamily: 'Rajdhani',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                              const Text(
                                'PROJE İLERLEME DURUMU',
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 11,
                                  letterSpacing: 2,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    AppTheme.primaryGradient
                                        .createShader(bounds),
                                child: Text(
                                  '${provider.overallProgress.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Gradient progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                Container(
                                  height: 10,
                                  color: AppTheme.bgDeep,
                                ),
                                FractionallySizedBox(
                                  widthFactor: provider.overallProgress / 100,
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.accentCyan
                                              .withOpacity(0.5),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              _statChip('${provider.totalTasks}', 'TOPLAM',
                                  AppTheme.textSecondary),
                              const SizedBox(width: 10),
                              _statChip(
                                  '${provider.statusCounts[TaskStatus.inProgress] ?? 0}',
                                  'AKTİF',
                                  AppTheme.accentCyan),
                              const SizedBox(width: 10),
                              _statChip(
                                  '${provider.statusCounts[TaskStatus.review] ?? 0}',
                                  'İNCELEME',
                                  AppTheme.accentGold),
                              const SizedBox(width: 10),
                              _statChip('${provider.completedTasks}', 'TAMAM',
                                  AppTheme.accentGreen),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Departments
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
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
                  height: 126,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: Department.values.length,
                    itemBuilder: (context, index) {
                      final dept = Department.values[index];
                      final info = AppData.departments[dept]!;
                      final tasks = provider.getTasksByDepartment(dept);
                      final done = tasks
                          .where((t) => t.status == TaskStatus.done)
                          .length;
                      final progress =
                          tasks.isEmpty ? 0.0 : done / tasks.length;

                      return Container(
                        width: 116,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: info.color.withOpacity(0.25),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: info.color.withOpacity(0.05),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(info.emoji,
                                    style: const TextStyle(fontSize: 18)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: info.color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${tasks.length}',
                                    style: TextStyle(
                                      fontFamily: 'Orbitron',
                                      fontSize: 9,
                                      color: info.color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                            // Gradient progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Stack(
                                children: [
                                  Container(height: 4, color: AppTheme.bgDeep),
                                  FractionallySizedBox(
                                    widthFactor: progress,
                                    child: Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            info.color.withOpacity(0.6),
                                            info.color,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: info.color.withOpacity(0.4),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '$done/${tasks.length} tamam',
                              style: const TextStyle(
                                fontFamily: 'Rajdhani',
                                fontSize: 10,
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
                        AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (context, child) => Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.accentPink
                                  .withOpacity(_pulseAnim.value),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentPink
                                      .withOpacity(_pulseAnim.value * 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'KRİTİK GÖREVLER',
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

              // In-progress tasks
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
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

  String _formatDate(DateTime d) {
    const months = [
      'OCA', 'ŞUB', 'MAR', 'NİS', 'MAY', 'HAZ',
      'TEM', 'AĞU', 'EYL', 'EKİ', 'KAS', 'ARA'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Widget _buildCriticalBadge(int count) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.accentPink.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppTheme.accentPink.withOpacity(_pulseAnim.value * 0.6)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentPink.withOpacity(_pulseAnim.value * 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentPink.withOpacity(_pulseAnim.value),
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
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 8,
                letterSpacing: 1,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
