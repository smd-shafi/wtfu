import 'package:wtfu/features/alarm/domain/entities/alarm_entity.dart';

class AlarmModel extends AlarmEntity {
  const AlarmModel({
    required super.id,
    required super.title,
    required super.hour,
    required super.minute,
    required super.repeatDays,
    required super.ringtonePath,
    required super.vibrationEnabled,
    required super.isEnabled,
    required super.createdAt,
    super.lastTriggeredAt,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as int,
      title: json['title'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      repeatDays: List<int>.from(json['repeatDays'] as List? ?? []),
      ringtonePath: json['ringtonePath'] as String,
      vibrationEnabled: json['vibrationEnabled'] as bool,
      isEnabled: json['isEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastTriggeredAt: json['lastTriggeredAt'] != null
          ? DateTime.parse(json['lastTriggeredAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hour': hour,
      'minute': minute,
      'repeatDays': repeatDays,
      'ringtonePath': ringtonePath,
      'vibrationEnabled': vibrationEnabled,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggeredAt': lastTriggeredAt?.toIso8601String(),
    };
  }

  AlarmModel copyWith({
    int? id,
    String? title,
    int? hour,
    int? minute,
    List<int>? repeatDays,
    String? ringtonePath,
    bool? vibrationEnabled,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? lastTriggeredAt,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      title: title ?? this.title,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeatDays: repeatDays ?? this.repeatDays,
      ringtonePath: ringtonePath ?? this.ringtonePath,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastTriggeredAt: lastTriggeredAt ?? this.lastTriggeredAt,
    );
  }
}
