import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wtfu/core/theme/app_theme.dart';
import 'package:wtfu/dependency_injection/injection.dart';
import 'package:wtfu/features/alarm/data/models/alarm_model.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_bloc.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_event.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_state.dart';
import 'package:wtfu/features/alarm/presentation/widgets/add_edit_alarm_bottom_sheet.dart';
import 'package:wtfu/features/alarm/presentation/widgets/alarm_history_widget.dart';
import 'package:wtfu/features/alarm/presentation/widgets/alarm_item_widget.dart';
import 'package:wtfu/features/alarm/services/alarm_scheduler_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _countdownTimer;
  final AlarmSchedulerService _scheduler = sl<AlarmSchedulerService>();

  @override
  void initState() {
    super.initState();
    // Refresh countdown remaining string every 15 seconds
    _countdownTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  AlarmModel? _getNextAlarm(List<AlarmModel> alarms) {
    final enabled = alarms.where((a) => a.isEnabled).toList();
    if (enabled.isEmpty) return null;

    AlarmModel? nextAlarm;
    DateTime? nextTime;

    for (final alarm in enabled) {
      final time = _scheduler.calculateNextAlarmTime(alarm.hour, alarm.minute, alarm.repeatDays);
      if (nextTime == null || time.isBefore(nextTime)) {
        nextTime = time;
        nextAlarm = alarm;
      }
    }
    return nextAlarm;
  }

  String _getRemainingText(AlarmModel? nextAlarm) {
    if (nextAlarm == null) return 'No active alarms';

    final target = _scheduler.calculateNextAlarmTime(nextAlarm.hour, nextAlarm.minute, nextAlarm.repeatDays);
    final now = DateTime.now();
    final diff = target.difference(now);

    if (diff.isNegative) return 'Rings now';

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    final List<String> parts = [];
    if (days > 0) parts.add('$days day${days > 1 ? 's' : ''}');
    if (hours > 0) parts.add('$hours hr${hours > 1 ? 's' : ''}');
    if (minutes > 0) parts.add('$minutes min${minutes > 1 ? 's' : ''}');
    
    if (parts.isEmpty) return 'Rings in less than a minute';
    return 'Rings in ${parts.join(', ')}';
  }

  String _formatAlarmTime(AlarmModel alarm, bool use24Hour) {
    if (use24Hour) {
      final h = alarm.hour.toString().padLeft(2, '0');
      final m = alarm.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else {
      final period = alarm.hour >= 12 ? 'PM' : 'AM';
      final h = alarm.hour == 0 ? 12 : (alarm.hour > 12 ? alarm.hour - 12 : alarm.hour);
      final m = alarm.minute.toString().padLeft(2, '0');
      return '$h:$m $period';
    }
  }

  void _showAddEditSheet(BuildContext context, [AlarmModel? alarm]) {
    final bloc = context.read<AlarmBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddEditAlarmBottomSheet(
          alarm: alarm,
          onSave: ({
            required String title,
            required int hour,
            required int minute,
            required List<int> repeatDays,
            required String ringtonePath,
            required bool vibrationEnabled,
          }) {
            if (alarm == null) {
              bloc.add(AddAlarmEvent(
                title: title,
                hour: hour,
                minute: minute,
                repeatDays: repeatDays,
                ringtonePath: ringtonePath,
                vibrationEnabled: vibrationEnabled,
              ));
            } else {
              final updated = alarm.copyWith(
                title: title,
                hour: hour,
                minute: minute,
                repeatDays: repeatDays,
                ringtonePath: ringtonePath,
                vibrationEnabled: vibrationEnabled,
                isEnabled: true, // Auto-enable when editing
              );
              bloc.add(UpdateAlarmEvent(updated));
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('WTFU'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: BlocConsumer<AlarmBloc, AlarmState>(
        listener: (context, state) {
          if (state.status == AlarmStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final nextAlarm = _getNextAlarm(state.alarms);
          final remainingText = _getRemainingText(nextAlarm);

          if (state.status == AlarmStatus.loading && state.alarms.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          return RefreshIndicator.adaptive(
            onRefresh: () async {
              context.read<AlarmBloc>().add(LoadAlarmsEvent());
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Next alarm banner card
                _buildNextAlarmBanner(context, nextAlarm, remainingText, state.use24HourFormat),
                const SizedBox(height: 24),

                // Alarms section header
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
                  child: Text(
                    'Alarms',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                // Alarms list
                if (state.alarms.isEmpty)
                  _buildEmptyState(context)
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.alarms.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final alarm = state.alarms[index];
                      return AlarmItemWidget(
                        alarm: alarm,
                        use24Hour: state.use24HourFormat,
                        onToggle: (enabled) {
                          context.read<AlarmBloc>().add(ToggleAlarmEvent(alarm.id, enabled));
                        },
                        onDelete: () {
                          context.read<AlarmBloc>().add(DeleteAlarmEvent(alarm.id));
                        },
                        onTap: () => _showAddEditSheet(context, alarm),
                      );
                    },
                  ),
                
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 16),

                // Activity logs
                AlarmHistoryWidget(history: state.history),
                const SizedBox(height: 80), // Spacer for FAB overlay
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Alarm', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildNextAlarmBanner(BuildContext context, AlarmModel? nextAlarm, String remainingText, bool use24h) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.primaryPurple.withOpacity(0.15), AppTheme.accentCyan.withOpacity(0.05)]
              : [AppTheme.primaryPurple.withOpacity(0.10), AppTheme.accentCyan.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.12),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next Alarm',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nextAlarm != null ? _formatAlarmTime(nextAlarm, use24h) : '--:--',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: theme.textTheme.titleLarge?.color,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
              // Breathing Alarm Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: nextAlarm != null 
                      ? AppTheme.neonAmber.withOpacity(0.12)
                      : Colors.grey.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.alarm_rounded,
                  color: nextAlarm != null ? AppTheme.neonAmber : Colors.grey,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.hourglass_empty_rounded,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  remainingText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.alarm_off_rounded,
            size: 64,
            color: theme.brightness == Brightness.dark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No alarms set',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the button below to add your first alarm',
            style: TextStyle(
              fontSize: 13,
              color: theme.brightness == Brightness.dark ? Colors.white24 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}
