import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'models/birthday.dart';
import 'providers/birthday_provider.dart';

const _ink = Color(0xFF173B38);
const _coral = Color(0xFFE77962);
const _gold = Color(0xFFF0B856);
const _paper = Color(0xFFF7F6F1);
const _muted = Color(0xFF7C8782);

class BirthdayBuddyApp extends StatelessWidget {
  const BirthdayBuddyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Birthday Buddy',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _ink,
        primary: _ink,
        secondary: _coral,
        surface: _paper,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    ),
    home: const BirthdayHome(),
  );
}

class BirthdayHome extends StatefulWidget {
  const BirthdayHome({super.key});

  @override
  State<BirthdayHome> createState() => _BirthdayHomeState();
}

class _BirthdayHomeState extends State<BirthdayHome> {
  int _tab = 0;

  Future<void> _openForm([Birthday? birthday]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _paper,
      builder: (sheetContext) => BirthdayForm(
        birthday: birthday,
        onSave: (value) async {
          final provider = context.read<BirthdayProvider>();
          if (birthday == null) {
            await provider.addBirthday(value);
          } else {
            await provider.updateBirthday(value);
          }
          if (sheetContext.mounted) Navigator.pop(sheetContext);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(
        onAdd: () => _openForm(),
        onViewAll: () => setState(() => _tab = 1),
        onCalendar: () => setState(() => _tab = 2),
        onEdit: _openForm,
      ),
      BirthdayListScreen(onEdit: _openForm, onAdd: () => _openForm()),
      const BirthdayCalendarScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      floatingActionButton: _tab == 3
          ? null
          : FloatingActionButton(
              onPressed: () => _openForm(),
              backgroundColor: _coral,
              foregroundColor: Colors.white,
              tooltip: 'Add birthday',
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE7EEEA),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people_alt_outlined), label: 'People'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.tune_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.onAdd,
    required this.onViewAll,
    required this.onCalendar,
    required this.onEdit,
    super.key,
  });

  final VoidCallback onAdd;
  final VoidCallback onViewAll;
  final VoidCallback onCalendar;
  final ValueChanged<Birthday> onEdit;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BirthdayProvider>();
    final upcoming = provider.upcomingBirthdays;
    final next = upcoming.isEmpty ? null : upcoming.first;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 96),
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('YOUR LITTLE CIRCLE', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.6)),
                    SizedBox(height: 8),
                    Text('Make their day\nfeel special.', style: TextStyle(color: _ink, fontSize: 32, height: 1.06, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: _ink, borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.cake_rounded, color: _gold, size: 27),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _NextBirthdayCard(birthday: next, onAdd: onAdd),
          const SizedBox(height: 22),
          Row(
            children: [
              _StatBlock(value: '${provider.birthdays.length}', label: 'PEOPLE', color: const Color(0xFFE7EEEA)),
              const SizedBox(width: 12),
              _StatBlock(value: '${upcoming.where((b) => b.daysUntil == 0).length}', label: 'TODAY', color: const Color(0xFFF6E7D2)),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: onCalendar,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 76,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFF0E3E0), borderRadius: BorderRadius.circular(16)),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Icon(Icons.calendar_month_outlined, color: _coral), Text('CALENDAR', style: TextStyle(color: _ink, fontSize: 10, fontWeight: FontWeight.w700))],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Expanded(child: Text('Coming up', style: TextStyle(color: _ink, fontSize: 21, fontWeight: FontWeight.w800))),
              TextButton(onPressed: onViewAll, child: const Text('See all')),
            ],
          ),
          if (upcoming.isEmpty)
            _EmptyState(
              icon: Icons.cake_outlined,
              title: 'Your calendar is wide open',
              message: 'Add someone special and we’ll keep their day in view.',
              actionLabel: 'Add a birthday',
              onAction: onAdd,
            )
          else
            ...upcoming.take(4).map((birthday) => BirthdayTile(birthday: birthday, onTap: () => onEdit(birthday))),
        ],
      ),
    );
  }
}

class _NextBirthdayCard extends StatelessWidget {
  const _NextBirthdayCard({required this.birthday, required this.onAdd});
  final Birthday? birthday;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final item = birthday;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(color: _ink, borderRadius: BorderRadius.circular(22)),
      child: item == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('A LITTLE REMINDER, RIGHT ON TIME', style: TextStyle(color: Color(0xFFB8CDC5), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.3)),
                const SizedBox(height: 17),
                const Text('The best celebrations start with remembering.', style: TextStyle(color: Colors.white, fontSize: 20, height: 1.2, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                TextButton.icon(onPressed: onAdd, style: TextButton.styleFrom(foregroundColor: _gold), icon: const Icon(Icons.add), label: const Text('Add the first birthday')),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('UP NEXT', style: TextStyle(color: Color(0xFFB8CDC5), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
                      const SizedBox(height: 10),
                      Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(DateFormat('EEEE, MMMM d').format(item.nextBirthday), style: const TextStyle(color: Color(0xFFD8E2DD), fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 74,
                  height: 78,
                  decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(19)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.daysUntil == 0 ? '🎉' : '${item.daysUntil}', style: const TextStyle(color: _ink, fontSize: 27, fontWeight: FontWeight.w800)),
                      Text(item.daysUntil == 0 ? 'TODAY' : item.daysUntil == 1 ? 'DAY LEFT' : 'DAYS LEFT', style: const TextStyle(color: _ink, fontSize: 9, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 76,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(color: _ink, fontSize: 21, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}

class BirthdayListScreen extends StatefulWidget {
  const BirthdayListScreen({required this.onEdit, required this.onAdd, super.key});
  final ValueChanged<Birthday> onEdit;
  final VoidCallback onAdd;

  @override
  State<BirthdayListScreen> createState() => _BirthdayListScreenState();
}

class _BirthdayListScreenState extends State<BirthdayListScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _delete(Birthday birthday) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete birthday?'),
        content: Text('Remove ${birthday.name} from your list?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && mounted) await context.read<BirthdayProvider>().deleteBirthday(birthday.id!);
  }

  @override
  Widget build(BuildContext context) {
    final birthdays = context.watch<BirthdayProvider>().upcomingBirthdays;
    final query = _query.trim().toLowerCase();
    final filtered = birthdays.where((birthday) => birthday.name.toLowerCase().contains(query) || birthday.relationship.toLowerCase().contains(query)).toList();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.fromLTRB(22, 26, 22, 16), child: Text('Your people', style: TextStyle(color: _ink, fontSize: 29, fontWeight: FontWeight.w800))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: TextField(
              controller: _search,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search name or relationship',
                prefixIcon: const Icon(Icons.search, color: _muted),
                suffixIcon: _query.isEmpty ? null : IconButton(tooltip: 'Clear search', onPressed: () { _search.clear(); setState(() => _query = ''); }, icon: const Icon(Icons.close)),
              ),
            ),
          ),
          const SizedBox(height: 13),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(
                    icon: query.isEmpty ? Icons.people_outline : Icons.search_off_outlined,
                    title: query.isEmpty ? 'No birthdays yet' : 'No matches',
                    message: query.isEmpty ? 'Add birthdays to keep your favorite people close.' : 'Try another name or relationship.',
                    actionLabel: query.isEmpty ? 'Add a birthday' : null,
                    onAction: query.isEmpty ? widget.onAdd : null,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 96),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => BirthdayTile(
                      birthday: filtered[index],
                      onTap: () => widget.onEdit(filtered[index]),
                      onEdit: () => widget.onEdit(filtered[index]),
                      onDelete: () => _delete(filtered[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class BirthdayTile extends StatelessWidget {
  const BirthdayTile({required this.birthday, required this.onTap, this.onEdit, this.onDelete, super.key});
  final Birthday birthday;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: birthday.avatarColor, shape: BoxShape.circle),
                child: Text(birthday.name.isEmpty ? '?' : birthday.name[0].toUpperCase(), style: const TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(birthday.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('${birthday.relationship} · turns ${birthday.ageOn(birthday.nextBirthday)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(birthday.daysUntil == 0 ? 'Today' : birthday.daysUntil == 1 ? 'Tomorrow' : 'In ${birthday.daysUntil}d', style: TextStyle(color: birthday.daysUntil == 0 ? _coral : _ink, fontSize: 12, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(DateFormat('MMM d').format(birthday.nextBirthday), style: const TextStyle(color: _muted, fontSize: 11)),
                ],
              ),
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  tooltip: 'Birthday options',
                  onSelected: (action) { if (action == 'edit') onEdit?.call(); if (action == 'delete') onDelete?.call(); },
                  itemBuilder: (context) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))],
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class BirthdayCalendarScreen extends StatefulWidget {
  const BirthdayCalendarScreen({super.key});
  @override
  State<BirthdayCalendarScreen> createState() => _BirthdayCalendarScreenState();
}

class _BirthdayCalendarScreenState extends State<BirthdayCalendarScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = DateTime.now();

  void _changeMonth(int amount) {
    setState(() {
      _month = DateTime(_month.year, _month.month + amount);
      _selected = DateTime(_month.year, _month.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final birthdays = context.watch<BirthdayProvider>().birthdays;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final firstOffset = DateTime(_month.year, _month.month, 1).weekday - 1;
    final byDay = <int, List<Birthday>>{};
    for (final birthday in birthdays) {
      if (birthday.date.month == _month.month) byDay.putIfAbsent(birthday.date.day, () => []).add(birthday);
    }
    final selectedBirthdays = byDay[_selected.day] ?? const <Birthday>[];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 25, 22, 100),
        children: [
          const Text('Birthday calendar', style: TextStyle(color: _ink, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 22),
          Row(
            children: [
              IconButton(tooltip: 'Previous month', onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left)),
              Expanded(child: Center(child: Text(DateFormat('MMMM yyyy').format(_month), style: const TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w800)))),
              IconButton(tooltip: 'Next month', onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right)),
            ],
          ),
          const SizedBox(height: 6),
          const Row(children: [Expanded(child: _WeekdayLabel('M')), Expanded(child: _WeekdayLabel('T')), Expanded(child: _WeekdayLabel('W')), Expanded(child: _WeekdayLabel('T')), Expanded(child: _WeekdayLabel('F')), Expanded(child: _WeekdayLabel('S')), Expanded(child: _WeekdayLabel('S'))]),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.9),
            itemBuilder: (context, index) {
              final day = index - firstOffset + 1;
              if (day < 1 || day > daysInMonth) return const SizedBox.shrink();
              final date = DateTime(_month.year, _month.month, day);
              final selected = DateUtils.isSameDay(_selected, date);
              final today = DateUtils.isSameDay(DateTime.now(), date);
              final hasBirthday = byDay.containsKey(day);
              return InkWell(
                onTap: () => setState(() => _selected = date),
                borderRadius: BorderRadius.circular(13),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: selected ? _ink : Colors.transparent, borderRadius: BorderRadius.circular(12), border: today && !selected ? Border.all(color: _coral, width: 1.5) : null),
                      child: Text('$day', style: TextStyle(color: selected ? Colors.white : _ink, fontWeight: hasBirthday || today ? FontWeight.w800 : FontWeight.w500)),
                    ),
                    const SizedBox(height: 2),
                    Container(width: 4, height: 4, decoration: BoxDecoration(color: hasBirthday ? _coral : Colors.transparent, shape: BoxShape.circle)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 23),
          Text(DateFormat('EEEE, MMMM d').format(_selected), style: const TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 11),
          if (selectedBirthdays.isEmpty)
            const Text('No birthdays on this day.', style: TextStyle(color: _muted, fontSize: 14))
          else
            ...selectedBirthdays.map((birthday) => BirthdayTile(birthday: birthday, onTap: () {})),
        ],
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Center(child: Text(text, style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700))),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _toggleNotifications(BuildContext context, bool enabled) async {
    final provider = context.read<BirthdayProvider>();
    if (enabled && !await provider.requestNotificationPermission()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Allow notifications in Android settings to turn on reminders.')));
      }
      return;
    }
    await provider.setNotificationsEnabled(enabled);
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<BirthdayProvider>().preferences;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 100),
        children: [
          const Text('Settings', style: TextStyle(color: _ink, fontSize: 29, fontWeight: FontWeight.w800)),
          const SizedBox(height: 22),
          const _SectionLabel('REMINDERS'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              value: preferences.enabled,
              onChanged: (value) => _toggleNotifications(context, value),
              activeTrackColor: _ink,
              title: const Text('Birthday notifications', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Get a gentle heads-up before the day'),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('REMIND ME'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                for (final days in const [1, 3, 7])
                  CheckboxListTile(
                    value: preferences.daysBefore.contains(days),
                    onChanged: preferences.enabled ? (checked) {
                      final selected = [...preferences.daysBefore];
                      if (checked == true) { selected.add(days); } else { selected.remove(days); }
                      context.read<BirthdayProvider>().setReminderDays(selected);
                    } : null,
                    activeColor: _ink,
                    title: Text('$days ${days == 1 ? 'day' : 'days'} before'),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const _SectionLabel('ABOUT'),
          const SizedBox(height: 10),
          const Row(children: [Icon(Icons.cake_outlined, color: _coral), SizedBox(width: 10), Text('Birthday Buddy', style: TextStyle(color: _ink, fontWeight: FontWeight.w700)), Spacer(), Text('Version 1.0.0', style: TextStyle(color: _muted))]),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4));
}

class BirthdayForm extends StatefulWidget {
  const BirthdayForm({required this.onSave, this.birthday, super.key});
  final Birthday? birthday;
  final Future<void> Function(Birthday birthday) onSave;
  @override
  State<BirthdayForm> createState() => _BirthdayFormState();
}

class _BirthdayFormState extends State<BirthdayForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _notes;
  late DateTime _date;
  late String _relationship;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.birthday?.name ?? '');
    _notes = TextEditingController(text: widget.birthday?.notes ?? '');
    _date = widget.birthday?.date ?? DateTime(2000, 1, 1);
    _relationship = widget.birthday?.relationship ?? 'Friend';
  }

  @override
  void dispose() { _name.dispose(); _notes.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(1900), lastDate: DateTime.now(), helpText: 'Choose their birthday');
    if (selected != null) setState(() => _date = selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final birthday = Birthday(id: widget.birthday?.id, name: _name.text.trim(), date: _date, relationship: _relationship, notes: _notes.text.trim());
    try { await widget.onSave(birthday); } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.birthday != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(22, 12, 22, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: const Color(0xFFD7DCD8), borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 23),
              Text(editing ? 'Edit birthday' : 'Add someone special', style: const TextStyle(color: _ink, fontSize: 25, fontWeight: FontWeight.w800)),
              const SizedBox(height: 19),
              TextFormField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Birthday', suffixIcon: Icon(Icons.calendar_today_outlined)),
                  child: Text(DateFormat('MMMM d, y').format(_date)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _relationship,
                decoration: const InputDecoration(labelText: 'Relationship'),
                items: const ['Family', 'Friend', 'Partner', 'Colleague', 'Other'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                onChanged: (value) { if (value != null) setState(() => _relationship = value); },
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _notes, textCapitalization: TextCapitalization.sentences, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Notes (optional)', alignLabelWithHint: true)),
              const SizedBox(height: 19),
              FilledButton(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(backgroundColor: _ink, minimumSize: const Size.fromHeight(52)),
                child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(editing ? 'Save changes' : 'Save birthday'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.message, this.actionLabel, this.onAction});
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 10),
    child: Column(
      children: [
        Icon(icon, size: 33, color: _coral),
        const SizedBox(height: 11),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 13, height: 1.4)),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 12),
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    ),
  );
}