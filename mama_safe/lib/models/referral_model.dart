enum ReferralStatus {
  pending,
  accepted,
  treated,
  closed;

  String get displayName {
    switch (this) {
      case ReferralStatus.pending:
        return 'Pending';
      case ReferralStatus.accepted:
        return 'Accepted';
      case ReferralStatus.treated:
        return 'Treated';
      case ReferralStatus.closed:
        return 'Closed';
    }
  }

  static ReferralStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ReferralStatus.pending;
      case 'accepted':
        return ReferralStatus.accepted;
      case 'treated':
        return ReferralStatus.treated;
      case 'closed':
        return ReferralStatus.closed;
      default:
        return ReferralStatus.pending;
    }
  }
}

class Referral {
  final int id;
  final int motherId;
  final int chwId;
  final int? healthcareProId;
  final String hospital;
  final String? notes;
  final String? diagnosis;
  final String? treatmentNotes;
  final ReferralStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  Referral({
    required this.id,
    required this.motherId,
    required this.chwId,
    this.healthcareProId,
    required this.hospital,
    this.notes,
    this.diagnosis,
    this.treatmentNotes,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'],
      motherId: json['mother_id'],
      chwId: json['chw_id'],
      healthcareProId: json['healthcare_pro_id'],
      hospital: json['hospital'],
      notes: json['notes'],
      diagnosis: json['diagnosis'],
      treatmentNotes: json['treatment_notes'],
      status: ReferralStatus.fromString(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mother_id': motherId,
      'hospital': hospital,
      'notes': notes,
    };
  }
}
