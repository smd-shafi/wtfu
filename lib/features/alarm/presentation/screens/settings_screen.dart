import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_bloc.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_event.dart';
import 'package:wtfu/features/alarm/presentation/bloc/alarm_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPreviewPlaying = false;
  String? _playingPath;

  final List<Map<String, String>> _sounds = [
    {'name': 'Classic Beep', 'path': 'assets/sounds/alarm_beep.wav'},
    {'name': 'Digital Alert', 'path': 'assets/sounds/alarm_digital.wav'},
    {'name': 'Gentle Pulsing', 'path': 'assets/sounds/alarm_gentle.wav'},
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        setState(() {
          _isPreviewPlaying = false;
          _playingPath = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudioPreview(String ringtonePath) async {
    if (_isPreviewPlaying && _playingPath == ringtonePath) {
      await _audioPlayer.stop();
    } else {
      await _audioPlayer.stop();
      // AudioPlayers expects paths relative to 'assets/' for AssetSource
      final relativePath = ringtonePath.replaceFirst('assets/', '');
      try {
        await _audioPlayer.play(AssetSource(relativePath));
        setState(() {
          _isPreviewPlaying = true;
          _playingPath = ringtonePath;
        });
      } catch (e) {
        debugPrint('Failed to play preview: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<AlarmBloc, AlarmState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Visual styling & preferences card
              _buildSectionHeader('Appearance & Display'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Enable starry space visuals'),
                      secondary: const Icon(Icons.dark_mode_outlined),
                      value: state.darkMode,
                      onChanged: (val) {
                        context.read<AlarmBloc>().add(UpdateSettingsEvent(
                          darkMode: val,
                          use24HourFormat: state.use24HourFormat,
                          defaultRingtone: state.defaultRingtone,
                          defaultVibration: state.defaultVibration,
                        ));
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      title: const Text('24-Hour Format'),
                      subtitle: const Text('Use military-style 24 hour clock'),
                      secondary: const Icon(Icons.schedule_outlined),
                      value: state.use24HourFormat,
                      onChanged: (val) {
                        context.read<AlarmBloc>().add(UpdateSettingsEvent(
                          darkMode: state.darkMode,
                          use24HourFormat: val,
                          defaultRingtone: state.defaultRingtone,
                          defaultVibration: state.defaultVibration,
                        ));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Default alarm attributes card
              _buildSectionHeader('Default Alarm Configurations'),
              Card(
                child: Column(
                  children: [
                    // Vibration setting
                    SwitchListTile.adaptive(
                      title: const Text('Continuous Vibration'),
                      subtitle: const Text('Vibrate phone continuously during alerts'),
                      secondary: const Icon(Icons.vibration_outlined),
                      value: state.defaultVibration,
                      onChanged: (val) {
                        context.read<AlarmBloc>().add(UpdateSettingsEvent(
                          darkMode: state.darkMode,
                          use24HourFormat: state.use24HourFormat,
                          defaultRingtone: state.defaultRingtone,
                          defaultVibration: val,
                        ));
                      },
                    ),
                    const Divider(height: 1),
                    // Ringtone setting with nested options list
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.music_note_outlined, color: Colors.grey),
                              SizedBox(width: 16),
                              Text(
                                'Default Ringtone',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._sounds.map((sound) {
                            final isSelected = state.defaultRingtone == sound['path'];
                            final isCurrentPreview = _isPreviewPlaying && _playingPath == sound['path'];
                            
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                sound['name']!,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? theme.colorScheme.primary : null,
                                ),
                              ),
                              leading: Radio<String>(
                                value: sound['path']!,
                                groupValue: state.defaultRingtone,
                                onChanged: (val) {
                                  if (val != null) {
                                    context.read<AlarmBloc>().add(UpdateSettingsEvent(
                                      darkMode: state.darkMode,
                                      use24HourFormat: state.use24HourFormat,
                                      defaultRingtone: val,
                                      defaultVibration: state.defaultVibration,
                                    ));
                                  }
                                },
                              ),
                              trailing: IconButton(
                                icon: Icon(isCurrentPreview ? Icons.stop_circle : Icons.play_circle_outline),
                                color: theme.colorScheme.primary,
                                onPressed: () => _toggleAudioPreview(sound['path']!),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
