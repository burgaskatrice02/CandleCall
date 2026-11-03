import 'package:flutter/material.dart';

class Birthday {
  const Birthday({
    this.id,
    required this.name,
    required this.date,
    required this.relationship,
    this.notes = '',
  });

  final int? id;
  final String name;
  final DateTime date;
  final String relationship;
  final String notes;

  static const _avatarColors = [
    Color(0xFFF2DDD7),
    Color(0xFFE7EDDE),
    Color(0xFFF5E9CE),
    Color(0xFFDCEAE6),
  ];

  Color get avatarColor => _avatarColors[(name.hashCode & 0x7fffffff) % 4];

  int ageOn(DateTime day) {
    var age = day.year - date.year;
    final lastDay = DateTime(day.year, date.month + 1, 0).day;
    final anniversary = DateTime(day.year, date.month, date.day.clamp(1, lastDay));
    final currentDay = DateTime(day.year, day.month, day.day);
    if (anniversary.isAfter(currentDay)) age--;
    return age;
  }

  DateTime get nextBirthday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var next = _anniversary(now.year);
    if (next.isBefore(today)) next = _anniversary(now.year + 1);
    return next;
  }

  DateTime birthdayInYear(int year) => _anniversary(year);

  int get daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return nextBirthday.difference(today).inDays;
  }

  DateTime _anniversary(int year) {
    final lastDay = DateTime(year, date.month + 1, 0).day;
    return DateTime(year, date.month, date.day.clamp(1, lastDay));
  }

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'date': DateTime(date.year, date.month, date.day).toIso8601String(),
    'relationship': relationship,
    'notes': notes,
  };

  factory Birthday.fromMap(Map<String, Object?> map) => Birthday(
    id: map['id'] as int,
    name: map['name'] as String,
    date: DateTime.parse(map['date'] as String),
    relationship: map['relationship'] as String,
    notes: map['notes'] as String? ?? '',
  );
}

class ReminderPreferences {
  const ReminderPreferences({
    this.enabled = false,
    this.daysBefore = const [1, 3, 7],
  });

  final bool enabled;
  final List<int> daysBefore;

  ReminderPreferences copyWith({bool? enabled, List<int>? daysBefore}) =>
      ReminderPreferences(
        enabled: enabled ?? this.enabled,
        daysBefore: daysBefore ?? this.daysBefore,
      );
}