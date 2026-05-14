import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../../books/data/services/browse_service.dart';
import '../../../books/domain/models/book.dart';
import '../../data/services/swap_service.dart';
import '../../domain/models/swap_request.dart';

class ExchangeHistoryScreen extends StatelessWidget {
  const ExchangeHistoryScreen({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context) {
    final swapService = SwapService();
    final browseService = BrowseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange History'),
      ),
      body: StreamBuilder<List<SwapRequest>>(
        stream: swapService.exchangeHistory(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final swaps = snapshot.data ?? [];

          if (swaps.isEmpty) {
            return const Center(child: Text('No exchanges yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: swaps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final swap = swaps[index];
              final isRequester = swap.requesterId == uid;

              final partnerId =
                  isRequester ? swap.ownerId : swap.requesterId;

              final bookOwnerId =
                  isRequester ? swap.ownerId : swap.requesterId;

              final bookId =
                  isRequester ? swap.bookWantedId : swap.bookOfferedId;

              return FutureBuilder<Book?>(
                future: browseService.fetchBook(bookOwnerId, bookId),
                builder: (context, bookSnap) {
                  final book = bookSnap.data;

                  return FutureBuilder<String?>(
                    future: browseService.fetchDisplayName(partnerId),
                    builder: (context, userSnap) {
                      final partnerName = userSnap.data ?? 'Unknown user';

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: book?.coverUrl != null
                                  ? Image.network(
                                      book!.coverUrl!,
                                      width: 60,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 90,
                                      color: Colors.grey,
                                      child: const Icon(Icons.book),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book?.title ?? 'Unknown book',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Exchanged with $partnerName'),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${swap.createdAt.day}/${swap.createdAt.month}/${swap.createdAt.year}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}