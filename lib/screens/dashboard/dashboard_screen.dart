import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit_model.dart';
import '../../models/work_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ConfettiController _confettiController;
  bool _celebrationShown = false;
  bool _birthdayDialogShown = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showCelebration() {
    if (!_celebrationShown) {
      _celebrationShown = true;
      _confettiController.play();

      final random = Random();
      final message =
          AppConstants.motivationalMessages[random.nextInt(
            AppConstants.motivationalMessages.length,
          )];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context);
    final user = authProvider.user;

    if (user == null) return const SizedBox.shrink();

    // Check for birthday
    if (user.isBirthdayToday && !_birthdayDialogShown) {
      _birthdayDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBirthdayDialog();
      });
    }

    // Check for all tasks completed
    if (habitProvider.allCompletedToday &&
        habitProvider.totalActiveHabits > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCelebration();
      });
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await authProvider.refreshUser();
            await habitProvider.loadTodayCompletions(user.uid);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                _buildGreeting(user.name),
                const SizedBox(height: 24),

                // Streak Card
                _buildStreakCard(user.currentStreak, user.maxStreak),
                const SizedBox(height: 20),

                // Progress Overview
                _buildProgressOverview(habitProvider),
                const SizedBox(height: 24),

                // Today's Habits
                _buildTodaysHabitsHeader(habitProvider),
                const SizedBox(height: 12),

                // Habit List
                _buildHabitList(habitProvider, user.uid),
              ],
            ),
          ),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.primary,
              AppColors.accent,
              AppColors.streakGold,
              AppColors.success,
              Colors.purple,
              Colors.pink,
            ],
            numberOfParticles: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(String name) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;

    if (hour < 12) {
      greeting = 'Good Morning';
      emoji = '☀️';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      emoji = '🌤️';
    } else {
      greeting = 'Good Evening';
      emoji = '🌙';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting $emoji',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStreakCard(int currentStreak, int maxStreak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔥 Current Streak',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '$currentStreak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentStreak == 1 ? 'day' : 'days',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('👑', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(
                  '$maxStreak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Best',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(HabitProvider habitProvider) {
    final total = habitProvider.totalActiveHabits;
    final completed = habitProvider.completedTodayCount;
    final progress = total > 0 ? completed / total : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 8.0,
              percent: progress,
              center: Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              progressColor: AppColors.primary,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1000,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completed of $total habits completed',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  if (habitProvider.allCompletedToday && total > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '✅ All done!',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
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

  Widget _buildTodaysHabitsHeader(HabitProvider habitProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Today\'s Habits',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.createHabit);
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildHabitList(HabitProvider habitProvider, String userId) {
    final activeHabits = habitProvider.activeHabits;

    if (activeHabits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'No active habits yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first habit to start building your streak!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.createHabit);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Habit'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeHabits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final habit = activeHabits[index];
        final isCompleted = habitProvider.isHabitCompletedToday(habit.id);

        return _HabitCard(
          habit: habit,
          isCompleted: isCompleted,
          onComplete: () async {
            await habitProvider.completeHabit(
              userId: userId,
              habitId: habit.id,
            );
          },
          onTap: () {},
        );
      },
    );
  }

  void _showBirthdayDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎂', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Happy Birthday!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Here\'s a free streak freeze as our gift to you! 🎁',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Thank you! 🙏'),
          ),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final HabitModel habit;
  final bool isCompleted;
  final VoidCallback onComplete;
  final VoidCallback onTap;

  const _HabitCard({
    required this.habit,
    required this.isCompleted,
    required this.onComplete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Completion checkbox
                  GestureDetector(
                    onTap: isCompleted ? null : onComplete,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: isCompleted
                            ? null
                            : Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 2,
                              ),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.circle_outlined,
                        color: isCompleted ? Colors.white : AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Habit info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.habitName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? AppColors.textSecondaryLight
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${habit.completedDays}/${habit.durationDays} days',
                              style: const TextStyle(
                                color: AppColors.textSecondaryLight,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: habit.progressPercentage,
                                  backgroundColor: AppColors.primary.withOpacity(
                                    0.1,
                                  ),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondaryLight,
                  ),
                ],
              ),
              // Show work/task summary
              StreamBuilder<List<WorkModel>>(
                stream: habitProvider.getWorksForHabit(habit.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final works = snapshot.data!;
                  final completedCount = works.where((w) => w.isCompleted).length;
                  final totalCount = works.length;
                  return Padding(
                    padding: const EdgeInsets.only(top: 10, left: 64),
                    child: Row(
                      children: [
                        Icon(Icons.task_alt, size: 16, color: completedCount == totalCount ? AppColors.success : AppColors.textSecondaryLight),
                        const SizedBox(width: 6),
                        Text(
                          '$completedCount/$totalCount tasks',
                          style: TextStyle(
                            fontSize: 12,
                            color: completedCount == totalCount
                                ? AppColors.success
                                : AppColors.textSecondaryLight,
                            fontWeight: completedCount == totalCount
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: totalCount > 0 ? completedCount / totalCount : 0,
                              backgroundColor: AppColors.success.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                              minHeight: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
