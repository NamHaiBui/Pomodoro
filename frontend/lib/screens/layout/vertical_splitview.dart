import 'package:flutter/material.dart';

class VerticalSplitView extends StatefulWidget {
  final Widget left;
  final Widget middle;
  final Widget right;
  final List<double> ratios;

  const VerticalSplitView({
    super.key,
    required this.left,
    required this.middle,
    required this.right,
    this.ratios = const [0.33, 0.33, 0.34],
  });

  @override
  State<VerticalSplitView> createState() => _VerticalSplitViewState();
}

class _VerticalSplitViewState extends State<VerticalSplitView> {
  final _dividerWidth = 16.0;
  late List<double> _ratios;
  late double _maxWidth;

  @override
  void initState() {
    super.initState();
    assert(
        widget.ratios.length == 3 && widget.ratios.reduce((a, b) => a + b) == 1,
        'Ratios must be 3 values that sum to 1');
    _ratios = List.from(widget.ratios);
    _maxWidth = 0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _maxWidth = constraints.maxWidth - _dividerWidth * 2;
        return Row(
          children: [
            _buildSection(widget.left, 0),
            _buildDivider(0),
            _buildSection(widget.middle, 1),
            _buildDivider(1),
            _buildSection(widget.right, 2),
          ],
        );
      },
    );
  }

  Widget _buildSection(Widget child, int index) {
    return SizedBox(
      width: _ratios[index] * _maxWidth,
      child: child,
    );
  }

  Widget _buildDivider(int index) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: _dividerWidth,
        child: const RotationTransition(
          turns: AlwaysStoppedAnimation(0.25),
          child: Icon(Icons.drag_handle),
        ),
      ),
      onPanUpdate: (details) => _handlePanUpdate(details, index),
    );
  }

  void _handlePanUpdate(DragUpdateDetails details, int dividerIndex) {
    setState(() {
      double delta = details.delta.dx / _maxWidth;
      _ratios[dividerIndex] += delta;
      _ratios[dividerIndex + 1] -= delta;
      _ratios = _ratios.map((r) => r.clamp(0.1, 0.8)).toList();
      double sum = _ratios.reduce((a, b) => a + b);
      _ratios = _ratios.map((r) => r / sum).toList();
    });
  }
}
