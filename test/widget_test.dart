import 'package:birthday_buddy/app.dart';
import 'package:birthday_buddy/models/birthday.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('birthday form saves the entered details', (tester) async {
    Birthday? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BirthdayForm(onSave: (birthday) async => saved = birthday),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'Avery');
    await tester.ensureVisible(find.text('Save birthday'));
    await tester.tap(find.text('Save birthday'));
    await tester.pumpAndSettle();

    expect(saved?.name, 'Avery');
    expect(saved?.relationship, 'Friend');
    expect(saved?.notes, isEmpty);
  });
}