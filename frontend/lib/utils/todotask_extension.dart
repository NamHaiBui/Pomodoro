import 'package:pomodoro/models/to_do_task.dart';

extension TodoTaskCopyWith on TodoTask {
  TodoTask copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
  }) {
    return TodoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }
}
