class AlarmHistoryModel {
  final String id;
  final int alarmId;
  final String alarmTitle;
  final DateTime eventTime;
  final String eventType; // 'triggered' or 'stopped'

  AlarmHistoryModel({
    required this.id,
    required this.alarmId,
    required this.alarmTitle,
    required this.eventTime,
    required this.eventType,
  });

  factory AlarmHistoryModel.fromJson(Map<String, dynamic> json) {
    return AlarmHistoryModel(
      id: json['id'] as String,
      alarmId: json['alarmId'] as int,
      alarmTitle: json['alarmTitle'] as String,
      eventTime: DateTime.parse(json['eventTime'] as String),
      eventType: json['eventType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alarmId': alarmId,
      'alarmTitle': alarmTitle,
      'eventTime': eventTime.toIso8601String(),
      'eventType': eventType,
    };
  }
}
