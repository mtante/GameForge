import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../screens/task_detail_screen.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final info = AppData.departments[task.department]!;
    final daysLeft = task.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0 && task.status != TaskStatus.done;
    final isUrgent = daysLeft <= 2 && daysLeft >= 0 && task.status != TaskStatus.done;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: Provider.of<TaskProvider>(context, listen: false),
              child: TaskDetailScreen(task: task),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isOverdue
                ? AppTheme.accentPink.withOpacity(0.5)
                : info.color.withOpacity(0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isOverdue ? AppTheme.accentPink : info.color).withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
                      // Priority
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: task.priority.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: task.priority.color.withOpacity(0.3)),
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
                      // Status
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
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: task.progress / 100,
                            backgroundColor: AppTheme.bgDeep,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(info.color),
                            minHeight: 4,
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
                      // Assignee
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: info.color.withOpacity(0.15),
                          shape: BoxShape.circle,
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
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      // Due date
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: isOverdue
                            ? AppTheme.accentPink
                            : isUrgent
                                ? AppTheme.accentGold
                                : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOverdue
                            ? 'OVERDUE'
                            : task.status == TaskStatus.done
                                ? 'DONE'
                                : daysLeft == 0
                                    ? 'TODAY'
                                    : '$daysLeft days',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 9,
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
                                  border: Border.all(color: AppTheme.borderGlow.withOpacity(0.5)),
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
    );
  }
}
