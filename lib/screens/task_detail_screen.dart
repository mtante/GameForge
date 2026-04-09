import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskModel _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    final info = AppData.departments[_task.department]!;
    final daysLeft = _task.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0 && _task.status != TaskStatus.done;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(info.emoji + ' ' + info.name.toUpperCase()),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: AppTheme.accentPink.withOpacity(0.7)),
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false)
                  .deleteTask(_task.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Priority
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _task.title,
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _task.priority.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: _task.priority.color.withOpacity(0.5)),
                  ),
                  child: Text(
                    _task.priority.label,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      color: _task.priority.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (_task.description.isNotEmpty) ...[
              Text(
                _task.description,
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: info.color.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PROGRESS',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10,
                          letterSpacing: 2,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${_task.progress}%',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: info.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _task.progress / 100,
                      backgroundColor: AppTheme.bgDeep,
                      valueColor: AlwaysStoppedAnimation<Color>(info.color),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _task.progress.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: info.color,
                    inactiveColor: AppTheme.bgDeep,
                    onChanged: (v) {
                      setState(() => _task.progress = v.toInt());
                      Provider.of<TaskProvider>(context, listen: false)
                          .updateTaskProgress(_task.id, v.toInt());
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status selector
            Text(
              'STATUS',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
                letterSpacing: 2,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: TaskStatus.values.map((s) {
                final isSelected = _task.status == s;
                return Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(right: s == TaskStatus.done ? 0 : 6),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _task.status = s);
                        Provider.of<TaskProvider>(context, listen: false)
                            .updateTaskStatus(_task.id, s);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? s.color.withOpacity(0.15)
                              : AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? s.color : AppTheme.borderGlow,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            s.label,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 7,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? s.color
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Meta info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderGlow),
              ),
              child: Column(
                children: [
                  _metaRow(Icons.person_rounded, 'ASSIGNEE', _task.assignee,
                      AppTheme.textPrimary),
                  const Divider(color: AppTheme.borderGlow, height: 20),
                  _metaRow(
                    Icons.calendar_today_rounded,
                    'DUE DATE',
                    '${_task.dueDate.day}/${_task.dueDate.month}/${_task.dueDate.year}',
                    isOverdue ? AppTheme.accentPink : AppTheme.textPrimary,
                    suffix: isOverdue
                        ? Text(
                            '  OVERDUE',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 9,
                              color: AppTheme.accentPink,
                            ),
                          )
                        : _task.status == TaskStatus.done
                            ? null
                            : Text(
                                '  $daysLeft days left',
                                style: TextStyle(
                                  fontFamily: 'Rajdhani',
                                  fontSize: 12,
                                  color: daysLeft <= 2
                                      ? AppTheme.accentGold
                                      : AppTheme.textSecondary,
                                ),
                              ),
                  ),
                  if (_task.tags.isNotEmpty) ...[
                    const Divider(color: AppTheme.borderGlow, height: 20),
                    Row(
                      children: [
                        Icon(Icons.tag_rounded,
                            color: AppTheme.textSecondary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: _task.tags
                                .map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: info.color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color:
                                                info.color.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        '#$tag',
                                        style: TextStyle(
                                          fontFamily: 'Rajdhani',
                                          fontSize: 11,
                                          color: info.color,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(IconData icon, String label, String value, Color valueColor,
      {Widget? suffix}) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 16),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 9,
            letterSpacing: 1,
            color: AppTheme.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
        if (suffix != null) suffix,
      ],
    );
  }
}
