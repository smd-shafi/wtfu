import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wtfu/core/theme/app_theme.dart';
import 'package:wtfu/features/alarm/data/models/alarm_history_model.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_bloc.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_event.dart';

class AlarmHistoryWidget extends StatelessWidget {
  final List<AlarmHistoryModel> history;

  const AlarmHistoryWidget({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_outlined,
                color: theme.brightness == Brightness.dark ? Colors.white24 : Colors.black26,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'No alarm logs recorded yet',
                style: TextStyle(
                  color: theme.brightness == Brightness.dark ? Colors.white38 : Colors.black38,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activity History',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                context.read<AlarmBloc>().add(ClearHistoryEvent());
              },
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: const Text('Clear Log', style: TextStyle(fontSize: 13)),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.alarmRed.withOpacity(0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final entry = history[index];
            final isTriggered = entry.eventType == 'triggered';
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  // Event indicator
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isTriggered 
                          ? AppTheme.alarmRed.withOpacity(0.1) 
                          : AppTheme.accentCyan.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isTriggered ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                      color: isTriggered ? AppTheme.alarmRed : AppTheme.accentCyan,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  
                  // Text fields
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.alarmTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isTriggered ? 'Alarm rang' : 'Alarm stopped',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.brightness == Brightness.dark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Timestamp
                  Text(
                    _formatDateTime(entry.eventTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.brightness == Brightness.dark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    
    final timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    
    if (isToday) {
      return "Today, $timeStr";
    } else {
      return "${dt.day}/${dt.month} $timeStr";
    }
  }
}
