import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pomodoro/models/session_type.dart';
import 'package:pomodoro/models/to_do_task.dart';
import 'package:pomodoro/models/on_going_session.dart';
import 'package:pomodoro/screens/widgets/session_type_item.dart';
import 'package:pomodoro/screens/widgets/todo_task_item.dart';
import 'package:pomodoro/utils/date_time_util.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Data models for better type safety
  List<SessionType> sessionTypes = [];
  List<TodoTask> todoTasks = [];
  OngoingSession? ongoingSession;
  bool isLoading = true;
  String errorMessage = '';

  // API Endpoints
  final String sessionTypesEndpoint = 'http://localhost:3000/session_types';
  final String todoTasksEndpoint = 'http://localhost:3000/todo_tasks';
  final String ongoingSessionEndpoint = 'http://localhost:3000/ongoing_session';

  // Single function to fetch all data
  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final sessionTypesResponse =
          await http.get(Uri.parse(sessionTypesEndpoint));
      final todoTasksResponse = await http.get(Uri.parse(todoTasksEndpoint));
      final ongoingSessionResponse =
          await http.get(Uri.parse(ongoingSessionEndpoint));

      if (sessionTypesResponse.statusCode == 200 &&
          todoTasksResponse.statusCode == 200) {
        setState(() {
          sessionTypes = (json.decode(sessionTypesResponse.body) as List)
              .map((sessionType) => SessionType.fromJson(sessionType))
              .toList();
          todoTasks = (json.decode(todoTasksResponse.body) as List)
              .map((task) => TodoTask.fromJson(task))
              .toList();
          if (ongoingSessionResponse.statusCode == 200) {
            ongoingSession = OngoingSession.fromJson(
                json.decode(ongoingSessionResponse.body));
          } else {
            ongoingSession = null;
          }
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addTask(String title, String description) async {
    try {
      final response = await http.post(
        Uri.parse(todoTasksEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title, 'description': description}),
      );

      if (response.statusCode == 201) {
        fetchData();
      } else {
        throw Exception('Failed to add task');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> toggleTaskCompletion(String id, bool completed) async {
    try {
      final response = await http.put(
        Uri.parse('$todoTasksEndpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'completed': completed}),
      );

      if (response.statusCode == 200) {
        fetchData();
      } else {
        throw Exception('Failed to update task');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> startSession(String sessionTypeId) async {
    try {
      final response = await http.post(
        Uri.parse(ongoingSessionEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'sessionTypeId': sessionTypeId}),
      );

      if (response.statusCode == 201) {
        fetchData();
      } else {
        throw Exception('Failed to start session');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> endSession(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$ongoingSessionEndpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        fetchData();
      } else {
        throw Exception('Failed to end session');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pomodoro App'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchData,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(errorMessage, style: TextStyle(color: Colors.red)))
              : ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    _buildOngoingSession(),
                    SizedBox(height: 16),
                    _buildSessionTypes(),
                    SizedBox(height: 16),
                    _buildTodoTasks(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSessionTypes() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('Session Types',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...sessionTypes.map((sessionType) => SessionTypeItem(
                sessionType: sessionType,
                onStartSession: () => startSession(sessionType.id),
                isSessionRunning: ongoingSession != null,
              )),
        ],
      ),
    );
  }

  Widget _buildTodoTasks() {
    return Card(
      child: Column(
        children: [
          ListTile(
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
      return Card(
        child: ListTile(
          title: Text('No ongoing session'),
          subtitle: Text('Start a new session from the list below'),
        ),
      );
    }

    return Card(
      child: ListTile(
        title: Text('Ongoing Session'),
        subtitle: Text(
            'Started at: ${DateTimeUtils.fromString(ongoingSession!.startTime)?.toLocal()}'),
        trailing: ElevatedButton(
          child: Text('End Session'),
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
          title: Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(hintText: 'Task Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: 'Task Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Add'),
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
