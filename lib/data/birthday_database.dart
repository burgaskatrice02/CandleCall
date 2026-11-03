import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/birthday.dart';

class BirthdayDatabase {
  BirthdayDatabase({DatabaseFactory? factory, this._databasePath})
    : _factory = factory ?? databaseFactory;

  final DatabaseFactory _factory;
  final String? _databasePath;
  Database? _database;

  Future<void> open() async {
    final file = _databasePath ??
        path.join(await getDatabasesPath(), 'birthday_buddy.db');
    _database = await _factory.openDatabase(
      file,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE birthdays (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            date TEXT NOT NULL,
            relationship TEXT NOT NULL,
            notes TEXT NOT NULL DEFAULT ''
          )
        ''');
          await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
          ''');
        },
      ),
    );
  }

  Database get _db {
    final database = _database;
    if (database == null) throw StateError('Database has not been opened');
    return database;
  }

  Future<List<Birthday>> getBirthdays() async {
    final rows = await _db.query('birthdays', orderBy: 'name COLLATE NOCASE');
    return rows.map((row) => Birthday.fromMap(row)).toList();
  }

  Future<int> insertBirthday(Birthday birthday) =>
      _db.insert('birthdays', birthday.toMap());

  Future<int> updateBirthday(Birthday birthday) => _db.update(
    'birthdays',
    birthday.toMap()..remove('id'),
    where: 'id = ?',
    whereArgs: [birthday.id],
  );

  Future<int> deleteBirthday(int id) =>
      _db.delete('birthdays', where: 'id = ?', whereArgs: [id]);

  Future<ReminderPreferences> getPreferences() async {
    final rows = await _db.query('settings');
    final values = {for (final row in rows) row['key']: row['value']};
    final encodedDays = values['reminderDays'] as String? ?? '1,3,7';
    final days = encodedDays
        .split(',')
        .map(int.tryParse)
        .whereType<int>()
        .where((day) => const [1, 3, 7].contains(day))
        .toSet()
        .toList()
      ..sort();
    return ReminderPreferences(
      enabled: values['notificationsEnabled'] == '1',
      daysBefore: days,
    );
  }

  Future<void> savePreferences(ReminderPreferences preferences) async {
    final batch = _db.batch();
    batch.insert(
      'settings',
      {'key': 'notificationsEnabled', 'value': preferences.enabled ? '1' : '0'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    batch.insert(
      'settings',
      {'key': 'reminderDays', 'value': preferences.daysBefore.join(',')},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}