import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit_model.dart';
import '../../services/habit_service.dart';
import 'package:intl/intl.dart';

class HabitDetailScreen extends StatelessWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final habit = habitProvider.habits.where((h) => h.id == habitId).firstOrNull;

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Habit Details')),
        body: const Center(child: Text('Habit not found')),
      );
    }

    final isCompletedToday = habitProvider.isHabitCompletedToday(habitId);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.habitName),
        actions: [
          if (habit.status == HabitStatus.active)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Habit'),
                      content: const Text(
                          'Are you sure you want to delete this habit? This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.error),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await habitProvider.deleteHabit(
                      habitId,
                      authProvider.userId!,
                    );
                    Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon & Name
            Text(habit.icon ?? '🎯', style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              habit.habitName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            if (habit.description != null) ...[
              const SizedBox(height: 8),
              Text(
                habit.description!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),

            // Progress Circle
            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 12.0,
              percent: habit.progressPercentage.clamp(0.0, 1.0),
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(habit.progressPercentage * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Complete',
                    style: TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              progressColor: habit.status == HabitStatus.completed
                  ? AppColors.success
                  : AppColors.primary,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
            ),
            const SizedBox(height: 32),

            // Stats Grid
            Row(
              children: [
                _buildStatCard(
                  context,
                  'Completed',
                  '${habit.completedDays}',
                  'days',
                  Icons.check_circle_outline,
                  AppColors.success,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  'Remaining',
                  '${habit.durationDays - habit.completedDays}',
                  'days',
                  Icons.timer_outlined,
                  AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard(
                  context,
                  'Started',
                  dateFormat.format(habit.startDate),
                  '',
                  Icons.calendar_today_outlined,
                  AppColors.info,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  'Ends',
                  dateFormat.format(habit.endDate),
                  '',
                  Icons.flag_outlined,
                  AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _getStatusColor(habit.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusText(habit.status),
                style: TextStyle(
                  color: _getStatusColor(habit.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Button
            if (habit.status == HabitStatus.active) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isCompletedToday
                      ? null
                      : () async {
                          await habitProvider.completeHabit(
                            userId: authProvider.userId!,
                            habitId: habitId,
                          );
                        },
                  icon: Icon(
                    isCompletedToday ? Icons.check : Icons.done_all,
                  ),
                  label: Text(
                    isCompletedToday
                        ? 'Completed for Today ✅'
                        : 'Mark as Done',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isCompletedToday ? AppColors.success : null,
                  ),
                ),
              ),
            ],

            if (habit.status == HabitStatus.completed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showRenewDialog(context, habitProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Renew Habit'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: unit.isNotEmpty ? 20 : 14,
                  color: color,
                ),
              ),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(HabitStatus status) {
    switch (status) {
      case HabitStatus.active:
        return AppColors.primary;
      case HabitStatus.completed:
        return AppColors.success;
      case HabitStatus.paused:
        return AppColors.warning;
    }
  }

  String _getStatusText(HabitStatus status) {
    switch (status) {
      case HabitStatus.active:
        return '🟢 Active';
      case HabitStatus.completed:
        return '🏆 Completed';
      case HabitStatus.paused:
        return '⏸ Paused';
    }
  }

  void _showRenewDialog(BuildContext context, HabitProvider habitProvider) {
    int selectedDuration = 30;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Renew Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose duration for the renewed habit:'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [30, 60, 90].map((days) {
                  return ChoiceChip(
                    label: Text('$days'),
                    selected: selectedDuration == days,
                    onSelected: (v) {
                      if (v) setDialogState(() => selectedDuration = days);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final habitService = HabitService();
                await habitService.renewHabit(
                  habitId: habitId,
                  durationDays: selectedDuration,
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Habit renewed! 🔄'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Renew'),
            ),
          ],
        ),
      ),
    );
  }
}
