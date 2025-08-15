import 'package:flutter/material.dart';
import 'main.dart'; // Import Habit model

class DashboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyStats;
  final List<Habit> habits;

  const DashboardScreen({
    super.key,
    required this.weeklyStats,
    required this.habits,
  });

  int _calculateCurrentStreak(Habit habit) {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final key = date.toIso8601String().substring(0, 10);
      if (habit.completionLog[key] == true) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int _calculateLongestStreak(Habit habit) {
    int longest = 0;
    int current = 0;
    final dates = habit.completionLog.keys.toList()..sort();
    for (final date in dates) {
      if (habit.completionLog[date] == true) {
        current++;
        longest = current > longest ? current : longest;
      } else {
        current = 0;
      }
    }
    return longest;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Progress 📈')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Weekly Completion',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  ...weeklyStats.map((day) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(day['day'][0]),
                    ),
                    title: Text(
                      day['day'],
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    trailing: Text(
                      '${day['completed']} habits',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.tealAccent,
                      ),
                    ),
                  )),
                  const Divider(height: 32),
                  const Text(
                    'Streaks 🔥',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...habits.map((habit) {
                    final current = _calculateCurrentStreak(habit);
                    final longest = _calculateLongestStreak(habit);
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                          habit.name,
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                        subtitle: Text(
                          'Current: $current days • Longest: $longest days',
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
