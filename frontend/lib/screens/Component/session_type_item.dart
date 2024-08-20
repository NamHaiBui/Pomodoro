import 'package:flutter/material.dart';
import 'package:pomodoro/models/session_type.dart';

class SessionTypeItem extends StatelessWidget {
  final SessionType sessionType;
  final VoidCallback onStartSession;
  final bool isSessionRunning;

  const SessionTypeItem({
    Key? key,
    required this.sessionType,
    required this.onStartSession,
    required this.isSessionRunning,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(sessionType.name),
      subtitle: Text('${sessionType.duration} minutes'),
      trailing: ElevatedButton(
        child: Text('Start'),
        onPressed: isSessionRunning ? null : onStartSession,
      ),
    );
  }
}
