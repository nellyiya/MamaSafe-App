class Visit {
  final int id;
  final int motherId;
  final int chwId;
  final DateTime visitDate;
  final DateTime? nextVisitDate;
  final String? notes;
  final bool completed;
  final DateTime createdAt;

  Visit({
    required this.id,
    required this.motherId,
    required this.chwId,
    required this.visitDate,
    this.nextVisitDate,
    this.notes,
    required this.completed,
    required this.createdAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      motherId: json['mother_id'],
      chwId: json['chw_id'],
      visitDate: DateTime.parse(json['visit_date']),
      nextVisitDate: json['next_visit_date'] != null ? DateTime.parse(json['next_visit_date']) : null,
      notes: json['notes'],
      completed: json['completed'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mother_id': motherId,
      'next_visit_date': nextVisitDate?.toIso8601String(),
      'notes': notes,
    };
  }
}
