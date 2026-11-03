import 'dart:io';

import 'package:birthday_buddy/data/birthday_database.dart';
import 'package:birthday_buddy/models/birthday.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('birthdays and reminder settings survive reopening SQLite', () async {
    final directory = await Directory.systemTemp.createTemp('birthday-buddy-');
    final databasePath = path.join(directory.path, 'test.db');
    final birthday = Birthday(
      name: 'Avery',
      date: DateTime(1998, 7, 12),
      relationship: 'Friend',
      notes: 'Loves lemon cake',
    );

    final firstOpen = BirthdayDatabase(
      factory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    await firstOpen.open();
    await firstOpen.insertBirthday(birthday);
    await firstOpen.savePreferences(
      const ReminderPreferences(enabled: true, daysBefore: [1, 7]),
    );
    await firstOpen.close();

    final reopened = BirthdayDatabase(
      factory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    await reopened.open();
    final records = await reopened.getBirthdays();
    final preferences = await reopened.getPreferences();

    expect(records, hasLength(1));
    expect(records.single.name, 'Avery');
    expect(records.single.notes, 'Loves lemon cake');
    expect(preferences.enabled, isTrue);
    expect(preferences.daysBefore, [1, 7]);

    await reopened.close();
    await directory.delete(recursive: true);
  });
}