import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../screens/task_detail_screen.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnim = Tween<double>(begin: 0.2, end: 0.7).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    final isCriticalActive = widget.task.priority == Priority.critical &&
        widget.task.status != TaskStatus.done;
    if (isCriticalActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TaskCard old) {
    super.didUpdateWidget(old);
    final isCriticalActive = widget.task.priority == Priority.critical &&
        widget.task.status != TaskStatus.done;
    if (isCriticalActive && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isCriticalActive && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final info = AppData.departments[task.department]!;
    final daysLeft = task.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0 && task.status != TaskStatus.done;
    final isUrgent = daysLeft <= 2 && daysLeft >= 0 && task.status != TaskStatus.done;
    final isCriticalActive = task.priority == Priority.critical &&
        task.status != TaskStatus.done;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.975),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ChangeNotifierProvider.value(
              value: Provider.of<TaskProvider>(context, listen: false),
              child: TaskDetailScreen(task: task),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 280),
          ),
        );
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            final borderColor = isCriticalActive
                ? AppTheme.accentPink.withOpacity(_pulseAnim.value)
                : isOverdue
                    ? AppTheme.accentPink.withOpacity(0.5)
                    : info.color.withOpacity(0.18);

            final glowColor = isCriticalActive
                ? AppTheme.accentPink.withOpacity(_pulseAnim.value * 0.12)
                : (isOverdue ? AppTheme.accentPink : info.color)
                    .withOpacity(0.05);

            return Container(
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: glowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top accent bar
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [info.color, info.color.withOpacity(0.0)],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Department badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: info.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(info.emoji,
                                  style: const TextStyle(fontSize: 10)),
                              const SizedBox(width: 4),
                              Text(
                                info.name.split(' ').first.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 8,
                                  color: info.color,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Priority badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: task.priority.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: task.priority.color.withOpacity(0.35)),
                          ),
                          child: Text(
                            task.priority.label,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 8,
                              color: task.priority.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: task.status.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            task.status.label,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 8,
                              color: task.status.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      task.title,
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: task.status == TaskStatus.done
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Progress bar with gradient
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Stack(
                              children: [
                                Container(
                                  height: 5,
                                  color: AppTheme.bgDeep,
                                ),
                                FractionallySizedBox(
                                  widthFactor: task.progress / 100,
                                  child: Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          info.color.withOpacity(0.7),
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
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${task.progress}%',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 10,
                            color: info.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        // Assignee avatar
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                info.color.withOpacity(0.3),
                                info.color.withOpacity(0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: info.color.withOpacity(0.4), width: 1),
                          ),
                          child: Center(
                            child: Text(
                              task.assignee.isNotEmpty
                                  ? task.assignee[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 10,
                                color: info.color,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          task.assignee,
                          style: const TextStyle(
                            fontFamily: 'Rajdhani',
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        // Due date
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isOverdue
                                    ? AppTheme.accentPink
                                    : isUrgent
                                        ? AppTheme.accentGold
                                        : task.status == TaskStatus.done
                                            ? AppTheme.accentGreen
                                            : AppTheme.textSecondary)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 10,
                                color: isOverdue
                                    ? AppTheme.accentPink
                                    : isUrgent
                                        ? AppTheme.accentGold
                                        : task.status == TaskStatus.done
                                            ? AppTheme.accentGreen
                                            : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOverdue
                                    ? 'GECİKMİŞ'
                                    : task.status == TaskStatus.done
                                        ? 'TAMAM'
                                        : daysLeft == 0
                                            ? 'BUGÜN'
                                            : '$daysLeft gün',
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 8,
                                  color: isOverdue
                                      ? AppTheme.accentPink
                                      : isUrgent
                                          ? AppTheme.accentGold
                                          : task.status == TaskStatus.done
                                              ? AppTheme.accentGreen
                                              : AppTheme.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Tags
                    if (task.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: task.tags
                            .take(3)
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgDeep,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: AppTheme.borderGlow
                                            .withOpacity(0.6)),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: const TextStyle(
                                      fontFamily: 'Rajdhani',
                                      fontSize: 10,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
