import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wtfu/core/theme/app_theme.dart';
import 'package:wtfu/features/alarm/data/models/alarm_model.dart';

class AddEditAlarmBottomSheet extends StatefulWidget {
  final AlarmModel? alarm;
  final Function({
    required String title,
    required int hour,
    required int minute,
    required List<int> repeatDays,
    required String ringtonePath,
    required bool vibrationEnabled,
  }) onSave;

  const AddEditAlarmBottomSheet({
    super.key,
    this.alarm,
    required this.onSave,
  });

  @override
  State<AddEditAlarmBottomSheet> createState() => _AddEditAlarmBottomSheetState();
}

class _AddEditAlarmBottomSheetState extends State<AddEditAlarmBottomSheet> {
  late TextEditingController _titleController;
  late TimeOfDay _selectedTime;
  late List<int> _repeatDays;
  late String _ringtonePath;
  late bool _vibrationEnabled;

  late AudioPlayer _audioPlayer;
  bool _isPreviewPlaying = false;

  final List<Map<String, String>> _sounds = [
    {'name': 'Classic Beep', 'path': 'assets/sounds/alarm_beep.wav'},
    {'name': 'Digital Alert', 'path': 'assets/sounds/alarm_digital.wav'},
    {'name': 'Gentle Pulsing', 'path': 'assets/sounds/alarm_gentle.wav'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.alarm?.title ?? '');
    
    if (widget.alarm != null) {
      _selectedTime = TimeOfDay(hour: widget.alarm!.hour, minute: widget.alarm!.minute);
      _repeatDays = List<int>.from(widget.alarm!.repeatDays);
      _ringtonePath = widget.alarm!.ringtonePath;
      _vibrationEnabled = widget.alarm!.vibrationEnabled;
    } else {
      _selectedTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 5)));
      _repeatDays = [];
      _ringtonePath = 'assets/sounds/alarm_beep.wav';
      _vibrationEnabled = true;
    }

    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        setState(() {
          _isPreviewPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _toggleDay(int dayIndex) {
    setState(() {
      if (_repeatDays.contains(dayIndex)) {
        _repeatDays.remove(dayIndex);
      } else {
        _repeatDays.add(dayIndex);
      }
    });
  }

  void _selectPreset(String preset) {
    setState(() {
      if (preset == 'daily') {
        _repeatDays = [1, 2, 3, 4, 5, 6, 7];
      } else if (preset == 'weekdays') {
        _repeatDays = [1, 2, 3, 4, 5];
      } else if (preset == 'weekends') {
        _repeatDays = [6, 7];
      } else {
        _repeatDays = [];
      }
    });
  }

  Future<void> _toggleAudioPreview() async {
    if (_isPreviewPlaying) {
      await _audioPlayer.stop();
    } else {
      // AudioPlayers package expects paths relative to 'assets/' for AssetSource
      final relativePath = _ringtonePath.replaceFirst('assets/', '');
      try {
        await _audioPlayer.play(AssetSource(relativePath));
        setState(() {
          _isPreviewPlaying = true;
        });
      } catch (e) {
        debugPrint('Failed to play preview: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.alarm == null ? 'New Alarm' : 'Edit Alarm',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Time Selector
            Center(
              child: GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    _selectedTime.format(context),
                    style: textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Alarm Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Label Name',
                hintText: 'e.g., Wake Up, Gym, Study',
                prefixIcon: const Icon(Icons.label_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),

            // Repeat Days Presets
            Text(
              'Repeat Schedule',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPresetButton('Once', 'once'),
                _buildPresetButton('Daily', 'daily'),
                _buildPresetButton('Weekdays', 'weekdays'),
                _buildPresetButton('Weekends', 'weekends'),
              ],
            ),
            const SizedBox(height: 12),

            // Weekday picker chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final dayNum = index + 1; // 1 = Mon, 7 = Sun
                final isSelected = _repeatDays.contains(dayNum);
                final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                
                return GestureDetector(
                  onTap: () => _toggleDay(dayNum),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.transparent : theme.dividerColor,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dayNames[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Ringtone selector dropdown + preview play button
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _ringtonePath,
                    decoration: InputDecoration(
                      labelText: 'Alarm Ringtone',
                      prefixIcon: const Icon(Icons.music_note_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    items: _sounds.map((sound) {
                      return DropdownMenuItem<String>(
                        value: sound['path'],
                        child: Text(sound['name']!),
                      );
                    }).toList(),
                    onChanged: (val) async {
                      if (val != null) {
                        await _audioPlayer.stop();
                        setState(() {
                          _ringtonePath = val;
                          _isPreviewPlaying = false;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _toggleAudioPreview,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _isPreviewPlaying ? Icons.stop : Icons.play_arrow,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Vibration switch
            SwitchListTile(
              title: const Text('Vibrate continuously'),
              secondary: const Icon(Icons.vibration),
              value: _vibrationEnabled,
              onChanged: (val) {
                setState(() {
                  _vibrationEnabled = val;
                });
              },
            ),
            const SizedBox(height: 24),

            // Save & Cancel buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(
                        title: _titleController.text.trim(),
                        hour: _selectedTime.hour,
                        minute: _selectedTime.minute,
                        repeatDays: _repeatDays,
                        ringtonePath: _ringtonePath,
                        vibrationEnabled: _vibrationEnabled,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Alarm'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(String text, String preset) {
    final theme = Theme.of(context);
    final isSelected = (preset == 'once' && _repeatDays.isEmpty) ||
        (preset == 'daily' && _repeatDays.length == 7) ||
        (preset == 'weekdays' && _repeatDays.length == 5 && !_repeatDays.contains(6) && !_repeatDays.contains(7)) ||
        (preset == 'weekends' && _repeatDays.length == 2 && _repeatDays.contains(6) && _repeatDays.contains(7));

    return ChoiceChip(
      label: Text(text),
      selected: isSelected,
      onSelected: (_) => _selectPreset(preset),
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
