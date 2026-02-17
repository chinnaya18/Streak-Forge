import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/work_model.dart';
import '../providers/habit_provider.dart';

class WorkListWidget extends StatefulWidget {
  final String habitId;
  final String userId;
  final VoidCallback onAllCompleted;

  const WorkListWidget({
    super.key,
    required this.habitId,
    required this.userId,
    required this.onAllCompleted,
  });

  @override
  State<WorkListWidget> createState() => _WorkListWidgetState();
}

class _WorkListWidgetState extends State<WorkListWidget> {
  final TextEditingController _workController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _workController.dispose();
    super.dispose();
  }

  void _addWork() async {
    if (_workController.text.trim().isEmpty) return;

    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    await habitProvider.addWork(
      habitId: widget.habitId,
      userId: widget.userId,
      workName: _workController.text.trim(),
    );

    _workController.clear();
    setState(() => _isAdding = false);
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);

    return StreamBuilder<List<WorkModel>>(
      stream: habitProvider.getWorksForHabit(widget.habitId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final works = snapshot.data ?? [];
        final completedCount = works.where((w) => w.isCompleted).length;
        final allCompleted = works.isNotEmpty && completedCount == works.length;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.task_alt, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Tasks ($completedCount/${works.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (works.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: allCompleted
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          allCompleted ? 'Done!' : '$completedCount/${ works.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: allCompleted ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (works.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: works.length,
                  itemBuilder: (context, index) {
                    final work = works[index];
                    return WorkItemTile(
                      work: work,
                      habitId: widget.habitId,
                      onToggle: (isCompleted) async {
                        await habitProvider.updateWorkCompletion(
                          habitId: widget.habitId,
                          workId: work.id,
                          isCompleted: isCompleted,
                        );
                        // Check after toggling if all are now completed
                        final updatedWorks = works.map((w) {
                          if (w.id == work.id) return w.copyWith(isCompleted: isCompleted);
                          return w;
                        }).toList();
                        if (updatedWorks.every((w) => w.isCompleted) && updatedWorks.isNotEmpty) {
                          // Add a small delay to ensure Firestore is synced
                          await Future.delayed(const Duration(milliseconds: 200));
                          widget.onAllCompleted();
                        }
                      },
                      onDelete: () async {
                        await habitProvider.deleteWork(
                          habitId: widget.habitId,
                          workId: work.id,
                        );
                      },
                    );
                  },
                ),
              if (_isAdding)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _workController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Enter task name...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onSubmitted: (_) => _addWork(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: AppColors.success),
                        onPressed: _addWork,
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: AppColors.error),
                        onPressed: () => setState(() {
                          _isAdding = false;
                          _workController.clear();
                        }),
                      ),
                    ],
                  ),
                ),
              if (!_isAdding)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Task'),
                    onPressed: () => setState(() => _isAdding = true),
                  ),
                ),
              if (allCompleted && works.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'All tasks completed! Habit marked as done for today.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class WorkItemTile extends StatelessWidget {
  final WorkModel work;
  final String habitId;
  final Function(bool) onToggle;
  final VoidCallback onDelete;

  const WorkItemTile({
    super.key,
    required this.work,
    required this.habitId,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(work.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: () => onToggle(!work.isCompleted),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: work.isCompleted
                  ? AppColors.success
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: work.isCompleted ? AppColors.success : AppColors.textSecondaryLight,
                width: 2,
              ),
            ),
            child: work.isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        ),
        title: Text(
          work.workName,
          style: TextStyle(
            decoration: work.isCompleted ? TextDecoration.lineThrough : null,
            color: work.isCompleted ? AppColors.textSecondaryLight : AppColors.textPrimaryLight,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.close, size: 18, color: AppColors.textSecondaryLight),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
