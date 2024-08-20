import 'package:json/json.dart';

@JsonCodable()
class TodoTask {
  final String id;
  final String title;
  final String? description;
  final bool completed;

  TodoTask({
    required this.id,
    required this.title,
    this.description,
    this.completed = false,
  });
}
