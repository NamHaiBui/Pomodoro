import 'package:flutter/material.dart';
import 'package:pomodoro/models/to_do_task.dart';

class TodoTaskItem extends StatelessWidget {
  final TodoTask task;
  final void Function(bool) onToggleCompletion;

  const TodoTaskItem({
    Key? key,
    required this.task,
    required this.onToggleCompletion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(task.title),
      subtitle: Text(task.description ?? "No description provided"),
      value: task.completed,
      onChanged: (bool? value) {
        if (value != null) {
          onToggleCompletion(value);
        }
      },
    );
  }
}
