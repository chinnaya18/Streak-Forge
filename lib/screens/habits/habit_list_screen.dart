import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit_model.dart';

class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context);
    final userId = authProvider.userId;

    if (userId == null) return const SizedBox.shrink();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Habits'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.createHabit);
          },
          icon: const Icon(Icons.add),
          label: const Text('New Habit'),
        ),
        body: TabBarView(
          children: [
            // Active Habits
            _buildHabitList(
              context,
              habitProvider.habits
                  .where((h) => h.status == HabitStatus.active)
                  .toList(),
              'No active habits',
              '🎯',
            ),
            // Completed Habits
            _buildHabitList(
              context,
              habitProvider.habits
                  .where((h) => h.status == HabitStatus.completed)
                  .toList(),
              'No completed habits yet',
              '🏆',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitList(
    BuildContext context,
    List<HabitModel> habits,
    String emptyMessage,
    String emptyEmoji,
  ) {
    if (habits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emptyEmoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: habit.status == HabitStatus.completed
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  habit.icon ?? '🎯',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            title: Text(
              habit.habitName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${habit.completedDays}/${habit.durationDays} days • ${habit.remainingDays} days left',
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: habit.progressPercentage,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      habit.status == HabitStatus.completed
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              habit.status == HabitStatus.completed
                  ? Icons.emoji_events
                  : Icons.chevron_right,
              color: habit.status == HabitStatus.completed
                  ? AppColors.streakGold
                  : AppColors.textSecondaryLight,
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}
