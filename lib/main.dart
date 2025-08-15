import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A simple data class to represent a single habit.
class Habit {
  String name;
  bool isCompleted;

  Habit({required this.name, this.isCompleted = false});

  // Helper methods to convert Habit object to/from a Map, which is needed for JSON encoding.
  Map<String, dynamic> toJson() => {
    'name': name,
    'isCompleted': isCompleted,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    name: json['name'],
    isCompleted: json['isCompleted'],
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
  List<Habit> _habits = [];
  final TextEditingController _habitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  // Load habits from the device's local storage.
  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsString = prefs.getString('habits');
    final String? lastOpenedDate = prefs.getString('lastOpenedDate');
    final String today = DateTime.now().toIso8601String().substring(0, 10);

    if (habitsString != null) {
      final List<dynamic> habitsJson = jsonDecode(habitsString);
      setState(() {
        _habits = habitsJson.map((json) => Habit.fromJson(json)).toList();
        // If the app was last opened on a different day, reset all habits.
        if (lastOpenedDate != today) {
          for (var habit in _habits) {
            habit.isCompleted = false;
          }
        }
      });
    }
    // Save the current date as the last opened date.
    await prefs.setString('lastOpenedDate', today);
    _saveHabits(); // Save the potentially reset habits
  }

  // Save the current list of habits to local storage.
  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String habitsString =
    jsonEncode(_habits.map((habit) => habit.toJson()).toList());
    await prefs.setString('habits', habitsString);
  }

  // Toggles the completion status of a habit.
  void _toggleHabit(int index) {
    setState(() {
      _habits[index].isCompleted = !_habits[index].isCompleted;
    });
    _saveHabits();
  }

  // Deletes a habit from the list.
  void _deleteHabit(int index) {
    setState(() {
      _habits.removeAt(index);
    });
    _saveHabits();
  }

  // Shows a dialog to add a new habit.
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
                  setState(() {
                    _habits.add(Habit(name: _habitController.text));
                  });
                  _habitController.clear();
                  _saveHabits();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DailyTick 🌱'),
      ),
      body: _habits.isEmpty
          ? const Center(
        child: Text(
          'No habits yet.\nTap "+" to add one!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          final habit = _habits[index];
          return ListTile(
            title: Text(
              habit.name,
              style: TextStyle(
                decoration: habit.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: habit.isCompleted ? Colors.grey : Colors.white,
              ),
            ),
            leading: Checkbox(
              value: habit.isCompleted,
              onChanged: (bool? value) {
                _toggleHabit(index);
              },
              activeColor: Colors.teal,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _deleteHabit(index),
            ),
          );
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