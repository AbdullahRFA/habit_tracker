import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

class Habit {
  String name;
  Map<String, bool> completionLog;

  Habit({required this.name, Map<String, bool>? completionLog})
      : completionLog = completionLog ?? {};

  bool isCompletedToday() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return completionLog[today] ?? false;
  }

  void toggleToday() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    completionLog[today] = !(completionLog[today] ?? false);
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'completionLog': completionLog,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    name: json['name'],
    completionLog: Map<String, bool>.from(json['completionLog'] ?? {}),
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyTick',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
        ),
      ),
      home: const HabitTrackerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _habitController = TextEditingController();
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsString = prefs.getString('habits');

    if (habitsString != null) {
      final List<dynamic> habitsJson = jsonDecode(habitsString);
      _habits = habitsJson.map((json) => Habit.fromJson(json)).toList();
    }

    setState(() {});
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String habitsString =
    jsonEncode(_habits.map((habit) => habit.toJson()).toList());
    await prefs.setString('habits', habitsString);
  }

  void _addHabit(String name) {
    final newHabit = Habit(name: name);
    setState(() {
      _habits.insert(0, newHabit);
      _listKey.currentState?.insertItem(0);
    });
    _saveHabits();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Habit added!')),
    );
  }

  void _deleteHabit(int index) {
    final removedHabit = _habits[index];
    setState(() {
      _habits.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
            (context, animation) =>
            _buildHabitTile(removedHabit, index, animation),
      );
    });
    _saveHabits();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Habit removed')),
    );
  }

  void _toggleHabit(int index) {
    setState(() {
      _habits[index].toggleToday();
    });
    _saveHabits();
  }

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Habit'),
          content: TextField(
            controller: _habitController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g., Read a book'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_habitController.text.isNotEmpty) {
                  _addHabit(_habitController.text);
                  _habitController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _generateWeeklyStats() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: i));
      final dateKey = date.toIso8601String().substring(0, 10);
      final dayName = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
      final completed = _habits.where((h) => h.completionLog[dateKey] == true).length;
      return {
        'day': dayName,
        'completed': completed,
      };
    }).reversed.toList();
  }

  Widget _buildHabitTile(Habit habit, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () => _toggleHabit(index),
          borderRadius: BorderRadius.circular(8),
          child: ListTile(
            title: Text(
              habit.name,
              style: TextStyle(
                decoration: habit.isCompletedToday()
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: habit.isCompletedToday() ? Colors.grey : Colors.white,
              ),
            ),
            leading: Checkbox(
              value: habit.isCompletedToday(),
              onChanged: (_) => _toggleHabit(index),
              activeColor: Colors.teal,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _deleteHabit(index),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DailyTick 🌱'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              final stats = _generateWeeklyStats();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(
                    weeklyStats: stats,
                    habits: _habits,
                  ),
                ),
              );
            },
          ),

        ],
      ),
      body: _habits.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.hourglass_empty, size: 64, color: Colors.tealAccent),
            SizedBox(height: 20),
            Text(
              'No habits yet.\nTap "+" to add one!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontFamily: 'Poppins', color: Colors.grey),
            ),
          ],
        ),
      )
          : AnimatedList(
        key: _listKey,
        initialItemCount: _habits.length,
        itemBuilder: (context, index, animation) {
          return _buildHabitTile(_habits[index], index, animation);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }
}
