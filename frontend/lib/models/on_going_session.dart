import 'package:json/json.dart';

@JsonCodable()
class OngoingSession {
  final String id;
  final String sessionTypeId;
  final String startTime;
  final String? endTime;

  OngoingSession({
    required this.id,
    required this.sessionTypeId,
    required this.startTime,
    this.endTime,
  });
}
