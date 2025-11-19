class MapleTask {
  MapleTask({
    required this.id,
    required this.summary,
    required this.start,
    this.end,
    this.notes = '',
    this.status = 'needsAction',
  });

  final String id;
  final String summary;
  final String start;
  final String? end;
  final String notes;
  final String status;

  MapleTask copyWith({
    String? id,
    String? summary,
    String? start,
    String? end,
    String? notes,
    String? status,
  }) {
    return MapleTask(
      id: id ?? this.id,
      summary: summary ?? this.summary,
      start: start ?? this.start,
      end: end ?? this.end,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  factory MapleTask.fromJson(Map<String, dynamic> json) {
    return MapleTask(
      id: json['id'] as String,
      summary: json['summary'] as String,
      start: json['start'] as String,
      end: json['end'] as String?,
      notes: json['notes'] as String? ?? '',
      status: json['status'] as String? ?? 'needsAction',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'summary': summary,
        'start': start,
        'end': end,
        'notes': notes,
        'status': status,
      };
}
