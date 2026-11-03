import 'package:birthday_buddy/models/birthday.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Birthday age calculation', () {
    test('increments age on the birthday, not before it', () {
      final birthday = Birthday(
        name: 'Avery',
        date: DateTime(2000, 7, 12),
        relationship: 'Friend',
      );

      expect(birthday.ageOn(DateTime(2026, 7, 11)), 25);
      expect(birthday.ageOn(DateTime(2026, 7, 12)), 26);
    });

    test('uses February 28 for a leap-day birthday in non-leap years', () {
      final birthday = Birthday(
        name: 'Sam',
        date: DateTime(2000, 2, 29),
        relationship: 'Family',
      );

      expect(birthday.ageOn(DateTime(2025, 2, 28)), 25);
      expect(birthday.ageOn(DateTime(2025, 3, 1)), 25);
    });
  });
}