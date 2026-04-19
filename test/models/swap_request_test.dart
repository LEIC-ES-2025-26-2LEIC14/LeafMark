import 'package:flutter_test/flutter_test.dart';
import 'package:leafmark/features/swaps/domain/models/swap_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('SwapRequest', () {
    test('cria instancia', () {
      final now = DateTime.now();
      final ts = Timestamp.fromDate(now);

      final swap = SwapRequest(
        id: '1',
        requesterId: 'A',
        ownerId: 'B',
        bookOfferedId: 'book_1',
        bookWantedId: 'book_2',
        status: SwapStatus.pending,
        createdAt: now,
      );

      expect(swap.id, '1');
      expect(swap.requesterId, 'A');
      expect(swap.bookOfferedId, 'book_1');
      expect(swap.bookWantedId, 'book_2');
      expect(swap.status, SwapStatus.pending);
    });

    test('fromMap funciona', () {
      final now = DateTime.now();

      final map = {
        'requesterId': 'A',
        'ownerId': 'B',
        'bookOfferedId': 'book_1',
        'bookWantedId': 'book_2',
        'status': 'pending',
        'createdAt': Timestamp.fromDate(now),
      };

      final swap = SwapRequest.fromMap(map, '1');

      expect(swap.requesterId, 'A');
      expect(swap.bookOfferedId, 'book_1');
      expect(swap.bookWantedId, 'book_2');
      expect(swap.status, SwapStatus.pending);
    });
  });
}