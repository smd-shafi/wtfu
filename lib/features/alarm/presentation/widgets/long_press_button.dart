import 'package:flutter/material.dart';
import 'package:wtfu/core/theme/app_theme.dart';

class LongPressButton extends StatefulWidget {
  final VoidCallback onCompleted;
  final String text;
  final double size;

  const LongPressButton({
    super.key,
    required this.onCompleted,
    required this.text,
    this.size = 140.0,
  });

  @override
  State<LongPressButton> createState() => _LongPressButtonState();
}

class _LongPressButtonState extends State<LongPressButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted();
        _controller.reset();
        setState(() {
          _isPressing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressStart() {
    setState(() {
      _isPressing = true;
    });
    _controller.forward();
  }

  void _onPressEnd() {
    setState(() {
      _isPressing = false;
    });
    if (_controller.status != AnimationStatus.completed) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTapDown: (_) => _onPressStart(),
      onTapUp: (_) => _onPressEnd(),
      onTapCancel: () => _onPressEnd(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Circular Progress Track
          SizedBox(
            width: widget.size + 20,
            height: widget.size + 20,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CircularProgressIndicator(
                  value: _controller.value,
                  strokeWidth: 6,
                  backgroundColor: theme.brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.alarmRed),
                );
              },
            ),
          ),
          
          // Inner Button Body
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: _isPressing ? widget.size - 10 : widget.size,
            height: _isPressing ? widget.size - 10 : widget.size,
            decoration: BoxDecoration(
              color: _isPressing ? AppTheme.alarmRed : AppTheme.alarmRed.withOpacity(0.85),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.alarmRed.withOpacity(_isPressing ? 0.6 : 0.3),
                  blurRadius: _isPressing ? 24 : 12,
                  spreadRadius: _isPressing ? 4 : 2,
                )
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.power_settings_new,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
