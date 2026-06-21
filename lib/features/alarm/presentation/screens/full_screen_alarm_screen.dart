import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wtfu/core/theme/app_theme.dart';
import 'package:wtfu/features/alarm/data/models/alarm_model.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_bloc.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_event.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_state.dart';
import 'package:wtfu/features/alarm/presentation/widgets/long_press_button.dart';

class FullScreenAlarmScreen extends StatefulWidget {
  final AlarmModel alarm;

  const FullScreenAlarmScreen({
    super.key,
    required this.alarm,
  });

  @override
  State<FullScreenAlarmScreen> createState() => _FullScreenAlarmScreenState();
}

class _FullScreenAlarmScreenState extends State<FullScreenAlarmScreen> {
  @override
  void initState() {
    super.initState();
    // Keep the screen awake during the ringing duration
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    // Release screen wake lock when dismissed
    WakelockPlus.disable();
    super.dispose();
  }

  String _formatClockTime(DateTime time, bool use24Hour) {
    if (use24Hour) {
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else {
      final period = time.hour >= 12 ? 'PM' : 'AM';
      final h = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
      final m = time.minute.toString().padLeft(2, '0');
      return '$h:$m $period';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<AlarmBloc, AlarmState>(
      builder: (context, state) {
        final use24h = state.use24HourFormat;
        
        return PopScope(
          canPop: false, // Prevents Android back button from dismissing overlay
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1B0B24), // Ultra deep space purple
                    Color(0xFF0F0E17),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Alarm label
                    Column(
                      children: [
                        Text(
                          widget.alarm.title.isNotEmpty ? widget.alarm.title : 'ALARM',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: AppTheme.textLight,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'WAKE THE FUCK UP',
                          style: TextStyle(
                            color: AppTheme.alarmRed,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.0,
                          ),
                        ),
                      ],
                    ),

                    // Running clock
                    StreamBuilder<DateTime>(
                      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                      builder: (context, snapshot) {
                        final now = snapshot.data ?? DateTime.now();
                        return Text(
                          _formatClockTime(now, use24h),
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                          ),
                        );
                      },
                    ),

                    // Breathing/ringing bell graphic
                    const AnimatedBellIcon(),

                    // Interactive slider stop
                    Column(
                      children: [
                        LongPressButton(
                          onCompleted: () {
                            context.read<AlarmBloc>().add(StopAlarmEvent(widget.alarm.id));
                          },
                          text: 'HOLD TO STOP',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Press and hold to dismiss alarm',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedBellIcon extends StatefulWidget {
  const AnimatedBellIcon({super.key});

  @override
  State<AnimatedBellIcon> createState() => _AnimatedBellIconState();
}

class _AnimatedBellIconState extends State<AnimatedBellIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _angleAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);

    _angleAnimation = Tween<double>(begin: -0.25, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _angleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.neonAmber.withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonAmber.withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 10,
                  )
                ],
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                size: 96,
                color: AppTheme.neonAmber,
              ),
            ),
          ),
        );
      },
    );
  }
}
