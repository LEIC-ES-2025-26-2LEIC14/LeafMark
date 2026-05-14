import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_theme.dart';
import '../../../books/domain/models/book.dart';
import '../../../books/presentation/screens/book_detail_screen.dart';
import '../../../ratings/domain/models/rating.dart';
import '../../../ratings/presentation/providers/rating_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../reports/domain/models/report.dart';
import '../../../reports/data/services/report_service.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  final String displayName;

  const PublicProfileScreen({
    super.key,
    required this.userId,
    required this.displayName,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  late final Future<Map<String, dynamic>?> _profileFuture;
  late final Future<int> _shelfCountFuture;

  final _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
    _shelfCountFuture = _fetchShelfCount();
  }

  Future<Map<String, dynamic>?> _fetchProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    return doc.data();
  }

  Future<int> _fetchShelfCount() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('shelf')
        .count()
        .get();
    return snap.count ?? 0;
  }

  void _openReportSheet(String reportedUid) {
    String selectedReason = 'Spam';
    final TextEditingController descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Report Profile',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  ...['Spam', 'Inappropriate behavior', 'Fake account', 'Other']
                      .map((reason) => RadioListTile(
                            title: Text(reason),
                            value: reason,
                            groupValue: selectedReason,
                            onChanged: (val) {
                              setState(() => selectedReason = val!);
                            },
                          )),

                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () async {
                      final uid = context.read<AuthProvider>().user!.uid;

                      final report = Report(
                        id: '',
                        reporterId: uid,
                        reportedUid: reportedUid,
                        reason: selectedReason,
                        description: descController.text,
                        createdAt: DateTime.now(),
                      );

                      await _reportService.submitReport(report);

                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Submit Report'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: Text(widget.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => _openReportSheet(widget.userId),
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data;
          final username = data?['username'] as String? ?? '';
          final bio = data?['bio'];
          final profilePicUrl = data?['profilePictureUrl'];
          final bannerPicUrl = data?['bannerPictureUrl'];
          final favoriteAuthors =
              List<String>.from(data?['favoriteAuthors'] ?? []);
          final favBookTitle = data?['favoriteBookTitle'];

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(widget.displayName,
                        style: textTheme.titleLarge,
                        textAlign: TextAlign.center),
                    if (username.isNotEmpty)
                      Text('@$username',
                          style: textTheme.bodySmall,
                          textAlign: TextAlign.center),
                    if (bio != null) ...[
                      const SizedBox(height: 12),
                      Text(bio, textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 24),

                    FutureBuilder<int>(
                      future: _shelfCountFuture,
                      builder: (context, shelfSnap) {
                        final count = shelfSnap.data ?? 0;

                        return Row(
                          children: [
                            Expanded(child: _stat('Books', '$count')),
                            const SizedBox(width: 8),
                            Expanded(child: _stat('Swaps', '—')),

                            StreamBuilder<List<Rating>>(
                              stream: context
                                  .read<RatingProvider>()
                                  .getRatingsForUser(widget.userId),
                              builder: (context, snapshot) {
                                String rating = '—';

                                if (snapshot.hasData &&
                                    snapshot.data!.isNotEmpty) {
                                  final list = snapshot.data!;
                                  final avg = list
                                          .map((e) => e.rating)
                                          .reduce((a, b) => a + b) /
                                      list.length;

                                  rating = avg.toStringAsFixed(1);
                                }

                                return Expanded(
                                    child: _stat('Rating', rating));
                              },
                            ),
                          ],
                        );
                      },
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

  Widget _stat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value),
          Text(label),
        ],
      ),
    );
  }
}