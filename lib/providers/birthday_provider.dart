import 'package:flutter/foundation.dart';

import '../data/birthday_database.dart';
import '../models/birthday.dart';
import '../services/reminder_service.dart';

class BirthdayProvider extends ChangeNotifier {
  BirthdayProvider(this._database, this._reminders);

  final BirthdayDatabase _database;
  final ReminderService _reminders;
  List<Birthday> _birthdays = [];
  ReminderPreferences _preferences = const ReminderPreferences();

  List<Birthday> get birthdays => List.unmodifiable(_birthdays);
  ReminderPreferences get preferences => _preferences;

  List<Birthday> get upcomingBirthdays {
    final result = [..._birthdays]..sort((a, b) {
      final byDate = a.daysUntil.compareTo(b.daysUntil);
      return byDate != 0 ? byDate : a.name.compareTo(b.name);
    });
    return result;
  }

  Future<void> load() async {
    _birthdays = await _database.getBirthdays();
    _preferences = await _database.getPreferences();
    await _reminders.schedule(_birthdays, _preferences);
  }

  Future<void> addBirthday(Birthday birthday) async {
    await _database.insertBirthday(birthday);
    await _refresh();
  }

  Future<void> updateBirthday(Birthday birthday) async {
    await _database.updateBirthday(birthday);
    await _refresh();
  }

  Future<void> deleteBirthday(int id) async {
    await _database.deleteBirthday(id);
    await _refresh();
  }

  Future<bool> requestNotificationPermission() =>
      _reminders.requestPermission();

  Future<void> setNotificationsEnabled(bool enabled) async {
    _preferences = _preferences.copyWith(enabled: enabled);
    await _database.savePreferences(_preferences);
    await _reminders.schedule(_birthdays, _preferences);
    notifyListeners();
  }

  Future<void> setReminderDays(List<int> days) async {
    final unique = days.toSet().toList()..sort();
    _preferences = _preferences.copyWith(daysBefore: unique);
    await _database.savePreferences(_preferences);
    await _reminders.schedule(_birthdays, _preferences);
    notifyListeners();
  }

  Future<void> _refresh() async {
    _birthdays = await _database.getBirthdays();
    await _reminders.schedule(_birthdays, _preferences);
    notifyListeners();
  }
}