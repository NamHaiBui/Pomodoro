import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pomodoro/models/session_type.dart';
import 'package:pomodoro/models/to_do_task.dart';
import 'package:pomodoro/models/on_going_session.dart';
import 'package:pomodoro/screens/widgets/session_type_item.dart';
import 'package:pomodoro/screens/widgets/timer_item.dart';
import 'package:pomodoro/screens/widgets/todo_task_item.dart';
import 'package:pomodoro/utils/date_time_util.dart';
import 'package:pomodoro/utils/todotask_extension.dart';

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _ReplicatedHomePageState();
}

class _ReplicatedHomePageState extends State<DemoHomePage> {
  // Sample data for the offline demo
  List<SessionType> sessionTypes = [
    SessionType(id: '1', name: 'Pomodoro', duration: 25),
    SessionType(id: '2', name: 'Short Break', duration: 5),
    SessionType(id: '3', name: 'Long Break', duration: 15),
  ];
  List<TodoTask> todoTasks = [
    TodoTask(
        id: '1',
        title: 'Task 1',
        description: 'Description 1',
        completed: false),
    TodoTask(
        id: '2',
        title: 'Task 2',
        description: 'Description 2',
        completed: true),
  ];
  OngoingSession? ongoingSession; // Initially null
  bool isLoading = false; // No loading in the demo
  String errorMessage = '';

  // Functions to simulate API calls (no actual network requests)
  Future<void> fetchData() async {
    // In a real app, You would fetch data from an API here
    // For this demo, we'll just keep the sample data
    setState(() {}); // Trigger a rebuild to reflect any changes
  }

  Future<void> addTask(String title, String description) async {
    // Simulate adding a task
    final newTask = TodoTask(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Simple ID generation
      title: title,
      description: description,
      completed: false,
    );
    setState(() {
      todoTasks.add(newTask);
    });
  }

  Future<void> toggleTaskCompletion(String id, bool completed) async {
    // Simulate toggling task completion
    setState(() {
      todoTasks = todoTasks.map((task) {
        if (task.id == id) {
          return task.copyWith(completed: completed);
        }
        return task;
      }).toList();
    });
  }

  Future<void> startSession(String sessionTypeId) async {
    // Simulate starting a session
    final selectedSessionType =
        sessionTypes.firstWhere((type) => type.id == sessionTypeId);
    setState(() {
      ongoingSession = OngoingSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionTypeId: sessionTypeId,
        startTime: DateTime.now().toIso8601String(),
      );
    });

    // TODO: You might want to add logic here to start a timer based on selectedSessionType.duration
  }

  Future<void> endSession(String id) async {
    // Simulate ending a session
    setState(() {
      ongoingSession = null;
    });

    // TODO: You might want to add logic here to stop the timer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : Row(
                  children: [
                    // Left side with Todo Tasks
                    Expanded(
                      child: _buildTodoTasks(),
                    ),
                    // Middle section with Timer and Session Types
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Session Type buttons on top
                          _buildSessionTypes(),
                          const SizedBox(height: 16),
                          // Timer in the middle
                          if (ongoingSession != null)
                            TimerWidget(
                              initialDurationInSeconds: sessionTypes
                                      .firstWhere((type) =>
                                          type.id ==
                                          ongoingSession!.sessionTypeId)
                                      .duration *
                                  60,
                              onStart: () {
                                // Handle timer start in the parent if needed
                              },
                              onStop: () {
                                setState(() {
                                  ongoingSession = null; // End the session
                                });
                                // Handle timer stop in the parent if needed
                              },
                              onSkip: () {
                                setState(() {
                                  ongoingSession = null; // End the session
                                });
                                // Handle timer skip in the parent if needed
                              },
                            ),
                          if (ongoingSession == null)
                            _buildOngoingSession(), // Show "No ongoing session" message
                        ],
                      ),
                    ),
                    // Right side for future video player (blank for now)
                    Expanded(
                      child: Container(), // Placeholder for video player
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSessionTypes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: sessionTypes
          .map((sessionType) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => startSession(sessionType.id),
                  child: Text(sessionType.name),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTodoTasks() {
    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text('Todo Tasks',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...todoTasks.map((task) => TodoTaskItem(
                task: task,
                onToggleCompletion: (completed) =>
                    toggleTaskCompletion(task.id, completed),
              )),
        ],
      ),
    );
  }

  Widget _buildOngoingSession() {
    if (ongoingSession == null) {
      return const Card(
        child: ListTile(
          title: Text('No ongoing session'),
          subtitle: Text('Start a new session from the list below'),
        ),
      );
    }

    return Card(
      child: ListTile(
        title: const Text('Ongoing Session'),
        subtitle: Text(
            'Started at: ${DateTimeUtils.fromString(ongoingSession!.startTime)?.toLocal()}'),
        trailing: ElevatedButton(
          child: const Text('End Session'),
          onPressed: () => endSession(ongoingSession!.id),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Task Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Task Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                addTask(titleController.text, descriptionController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
