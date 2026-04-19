import 'package:flutter_test/flutter_test.dart';
import 'package:leafmark/features/auth/domain/models/app_user.dart';

void main() {
  group('AppUser', () {
    test('cria user corretamente', () {
      final user = AppUser(
        uid: 'abc123',
        email: 'test@leafmark.com',
        username: 'leitor42',
        displayName: 'Leitor 42',
      );

      expect(user.uid, 'abc123');
      expect(user.email, 'test@leafmark.com');
      expect(user.username, 'leitor42');
      expect(user.displayName, 'Leitor 42');
    });

    test('uid existe', () {
      final user = AppUser(
        uid: '1',
        email: 'a',
        username: 'x',
        displayName: 'A',
      );

      expect(user.uid, '1');
    });
  });
}