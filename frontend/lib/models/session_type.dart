import 'package:json/json.dart';

@JsonCodable()
class SessionType {
  final String id;
  final String name;
  final int duration;

  SessionType({
    required this.id,
    required this.name,
    required this.duration,
  });
}
