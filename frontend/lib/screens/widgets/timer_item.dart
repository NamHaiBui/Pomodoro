import 'package:flutter/material.dart';
import 'dart:async';

class TimerWidget extends StatefulWidget {
  final int initialDurationInSeconds; // Duration in seconds
  final VoidCallback onStart; // Callback when the timer starts
  final VoidCallback onStop; // Callback when the timer stops
  final VoidCallback onSkip; // Callback when the timer is skipped

  const TimerWidget({
    super.key,
    required this.initialDurationInSeconds,
    required this.onStart,
    required this.onStop,
    required this.onSkip,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialDurationInSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Display the remaining time in minutes and seconds
        Text(
          '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 16),
        // Buttons for start, stop, skip
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _startTimer,
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopTimer,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: _skipTimer,
            ),
          ],
        ),
      ],
    );
  }

  void _startTimer() {
    if (_isTimerRunning) return;
    //TODO: Add stop logic
    setState(() {
      _isTimerRunning = true;
    });
    widget.onStart(); // Notify the parent widget

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer.cancel();
          _isTimerRunning = false;
          widget.onStop(); // Notify the parent widget
        }
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds =
          widget.initialDurationInSeconds; // Reset to initial duration
    });
    widget.onStop(); // Notify the parent widget
  }

  void _skipTimer() {
    _timer.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds =
          widget.initialDurationInSeconds; // Reset to initial duration
    });
    widget.onSkip(); // Notify the parent widget
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }
}
