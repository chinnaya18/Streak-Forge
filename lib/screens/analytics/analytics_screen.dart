import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../models/completion_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<CompletionModel> _weeklyData = [];
  List<CompletionModel> _monthlyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final userId =
        Provider.of<AuthProvider>(context, listen: false).userId;
    final habitProvider =
        Provider.of<HabitProvider>(context, listen: false);

    if (userId == null) return;

    try {
      final now = DateTime.now();
      final weekStart = now.subtract(const Duration(days: 7));
      final monthStart = now.subtract(const Duration(days: 30));

      _weeklyData = await habitProvider.getCompletionsInRange(
        userId: userId,
        startDate: weekStart,
        endDate: now,
      );

      _monthlyData = await habitProvider.getCompletionsInRange(
        userId: userId,
        startDate: monthStart,
        endDate: now,
      );
    } catch (e) {
      print('Error loading analytics: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weekly Overview
                    Text(
                      'Weekly Overview',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildWeeklyChart(),
                    const SizedBox(height: 32),

                    // Monthly Consistency
                    Text(
                      'Monthly Consistency',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildMonthlyGrid(),
                    const SizedBox(height: 32),

                    // Quick Stats
                    Text(
                      'Quick Stats',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickStats(user?.currentStreak ?? 0),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWeeklyChart() {
    final now = DateTime.now();
    final dayFormat = DateFormat('EEE');

    // Calculate completions per day for the last 7 days
    final List<double> dailyCounts = List.generate(7, (index) {
      final day =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
      return _weeklyData
          .where((c) =>
              c.date.year == day.year &&
              c.date.month == day.month &&
              c.date.day == day.day &&
              c.isCompleted)
          .length
          .toDouble();
    });

    final maxY = dailyCounts.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY > 0 ? maxY + 1 : 5,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()} completed',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final day = now.subtract(Duration(days: 6 - value.toInt()));
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          dayFormat.format(day),
                          style: const TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(7, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: dailyCounts[index],
                      color: AppColors.primary,
                      width: 28,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyGrid() {
    final now = DateTime.now();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Day labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map((d) => SizedBox(
                        width: 36,
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),

            // Grid of days
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(30, (index) {
                final day = now.subtract(Duration(days: 29 - index));
                final hasCompletion = _monthlyData.any((c) =>
                    c.date.year == day.year &&
                    c.date.month == day.month &&
                    c.date.day == day.day &&
                    c.isCompleted);

                final isToday = day.year == now.year &&
                    day.month == now.month &&
                    day.day == now.day;

                return Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: hasCompletion
                        ? AppColors.success.withOpacity(0.8)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                        color: hasCompletion
                            ? Colors.white
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Completed',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondaryLight)),
                const SizedBox(width: 16),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Missed',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondaryLight)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(int currentStreak) {
    final weeklyCompleted =
        _weeklyData.where((c) => c.isCompleted).length;
    final totalWeeklyPossible = _weeklyData.length > 0 ? _weeklyData.length : 1;
    final weeklyPercentage =
        ((weeklyCompleted / totalWeeklyPossible) * 100).clamp(0, 100);

    final monthlyCompleted =
        _monthlyData.where((c) => c.isCompleted).length;
    final totalMonthlyPossible =
        _monthlyData.length > 0 ? _monthlyData.length : 1;
    final monthlyPercentage =
        ((monthlyCompleted / totalMonthlyPossible) * 100).clamp(0, 100);

    return Column(
      children: [
        Row(
          children: [
            _buildQuickStatCard(
              '📊',
              'Weekly Rate',
              '${weeklyPercentage.toInt()}%',
              AppColors.info,
            ),
            const SizedBox(width: 12),
            _buildQuickStatCard(
              '📈',
              'Monthly Rate',
              '${monthlyPercentage.toInt()}%',
              AppColors.accent,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildQuickStatCard(
              '✅',
              'This Week',
              '$weeklyCompleted done',
              AppColors.success,
            ),
            const SizedBox(width: 12),
            _buildQuickStatCard(
              '📅',
              'This Month',
              '$monthlyCompleted done',
              AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
      String emoji, String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
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
                  fontSize: 18,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
