import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/report.dart';

class ReportService {
  final FirebaseFirestore _firestore;

  ReportService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> submitReport(Report report) async {
    final doc = _firestore.collection('reports').doc();

    await doc.set({
      ...report.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}