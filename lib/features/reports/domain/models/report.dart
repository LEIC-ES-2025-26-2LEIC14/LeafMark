import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String reporterId;
  final String reportedUid;
  final String reason;
  final String? description;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.reporterId,
    required this.reportedUid,
    required this.reason,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'reportedUid': reportedUid,
      'reason': reason,
      'description': description,
    };
  }

  factory Report.fromMap(String id, Map<String, dynamic> map) {
    return Report(
      id: id,
      reporterId: map['reporterId'],
      reportedUid: map['reportedUid'],
      reason: map['reason'],
      description: map['description'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}