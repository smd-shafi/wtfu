import 'package:flutter/material.dart';
import 'package:wtfu/core/theme/app_theme.dart';
import 'package:wtfu/features/alarm/data/models/alarm_model.dart';

class AlarmItemWidget extends StatelessWidget {
  final AlarmModel alarm;
  final bool use24Hour;
  final Function(bool) onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const AlarmItemWidget({
    super.key,
    required this.alarm,
    required this.use24Hour,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  String _formatTime(BuildContext context) {
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

  String _getRepeatText() {
    if (alarm.repeatDays.isEmpty) return 'Once';
    if (alarm.repeatDays.length == 7) return 'Everyday';
    
    // Check if Weekdays (1-5)
    final containsWeekdays = [1, 2, 3, 4, 5].every((d) => alarm.repeatDays.contains(d)) && alarm.repeatDays.length == 5;
    if (containsWeekdays) return 'Weekdays';
    
    // Check if Weekends (6, 7)
    final containsWeekends = [6, 7].every((d) => alarm.repeatDays.contains(d)) && alarm.repeatDays.length == 2;
    if (containsWeekends) return 'Weekends';

    // Custom days
    final dayNames = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};
    final sortedDays = List<int>.from(alarm.repeatDays)..sort();
    return sortedDays.map((d) => dayNames[d]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = alarm.isEnabled;
    final timeStr = _formatTime(context);
    final repeatStr = _getRepeatText();

    return Dismissible(
      key: Key('alarm-${alarm.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.alarmRed.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isEnabled ? 1.0 : 0.55,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                  ? AppTheme.darkCard 
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isEnabled 
                    ? theme.colorScheme.primary.withOpacity(0.15) 
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isEnabled 
                      ? theme.colorScheme.primary.withOpacity(0.04) 
                      : Colors.transparent,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                // Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time display
                      Text(
                        timeStr,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.textTheme.titleLarge?.color,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Title / Label and Days
                      Row(
                        children: [
                          if (alarm.title.isNotEmpty) ...[
                            Icon(
                              Icons.label_outline_rounded,
                              size: 14,
                              color: isEnabled 
                                  ? theme.colorScheme.primary 
                                  : theme.textTheme.bodyMedium?.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              alarm.title,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              repeatStr,
                              style: TextStyle(
                                fontSize: 13,
                                color: isEnabled 
                                    ? theme.colorScheme.secondary 
                                    : theme.textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Toggle Switch
                Switch.adaptive(
                  value: isEnabled,
                  activeColor: theme.colorScheme.primary,
                  onChanged: onToggle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
