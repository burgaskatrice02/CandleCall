import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/birthday_database.dart';
import 'providers/birthday_provider.dart';
import 'services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = BirthdayDatabase();
  await database.open();
  final reminders = ReminderService();
  await reminders.initialize();
  final provider = BirthdayProvider(database, reminders);
  await provider.load();
  runApp(ChangeNotifierProvider.value(value: provider, child: const BirthdayBuddyApp()));
}