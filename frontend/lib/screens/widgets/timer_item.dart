import 'package:flutter/material.dart';
import 'dart:async';

class TimerWidget extends StatefulWidget {
  final int initialDurationInSeconds;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onSkip;

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
  late Timer? _timer;
  late int _remainingSeconds;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialDurationInSeconds;
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          _formatTime(_remainingSeconds),
          style: const TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconButton(
              icon: _isTimerRunning ? Icons.pause : Icons.play_arrow,
              onPressed: _toggleTimer,
            ),
            _buildIconButton(
              icon: Icons.stop,
              onPressed: _stopTimer,
            ),
            _buildIconButton(
              icon: Icons.skip_next,
              onPressed: _skipTimer,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      iconSize: 32,
      color: Theme.of(context).primaryColor,
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    if (_isTimerRunning || _timer != null) return;

    setState(() {
      _isTimerRunning = true;
    });
    widget.onStart();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _stopTimer();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds = widget.initialDurationInSeconds;
    });
    widget.onStop();
  }

  void _skipTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds = widget.initialDurationInSeconds;
    });
    widget.onSkip();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
