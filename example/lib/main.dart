import 'package:flutter/material.dart';
import 'package:smooth_infinite_tab_bar/smooth_infinite_tab_bar.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'smooth_infinite_tab_bar example',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  // ── Example 1: Month selector (same as Cashew) ──────────────────

  int _monthIndex = 0;

  DateTime _monthAt(int i) {
    final now = DateTime.now();
    // Handle month overflow correctly via DateTime constructor
    return DateTime(now.year, now.month + i, 1);
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _monthLabel(int i) => _months[_monthAt(i).month - 1];

  String? _yearLabel(int i) {
    final d = _monthAt(i);
    return d.year != DateTime.now().year ? '${d.year}' : null;
  }

  // ── Example 2: Week selector ────────────────────────────────────

  int _weekIndex = 0;

  DateTime _weekStart(int i) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return monday.add(Duration(days: 7 * i));
  }

  String _weekLabel(int i) => 'W${_isoWeek(_weekStart(i))}';

  String? _weekSubLabel(int i) {
    final d = _weekStart(i);
    return '${_months[d.month - 1]} ${d.day}';
  }

  static int _isoWeek(DateTime date) {
    final doy = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return ((doy - date.weekday + 10) / 7).floor();
  }

  // ── Example 3: Generic category tab (finite) ───────────────────

  int _catIndex = 0;
  static const _cats = [
    'All', 'Food', 'Rent', 'Transport', 'Health', 'Leisure', 'Savings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('smooth_infinite_tab_bar')),
      body: ListView(
        children: [
          const SizedBox(height: 24),

          // ── Month selector (truly infinite) ───────────────
          _SectionLabel('Month selector (infinite)'),
          InfiniteTabBar(
            selectedIndex: _monthIndex,
            labelBuilder: _monthLabel,
            sublabelBuilder: _yearLabel,
            isHighlighted: (i) => i == 0,
            onSelected: (i) => setState(() => _monthIndex = i),
            // No hard limit — scroll infinitely in both directions
            shouldAddBottom: (_) => true,
            shouldAddTop: (_) => true,
          ),
          _SectionContent(
            'Selected: ${_monthLabel(_monthIndex)}'
            ' ${_monthAt(_monthIndex).year}',
          ),

          const SizedBox(height: 32),

          // ── Week selector ──────────────────────────────────
          _SectionLabel('Week selector'),
          InfiniteTabBar(
            selectedIndex: _weekIndex,
            labelBuilder: _weekLabel,
            sublabelBuilder: _weekSubLabel,
            isHighlighted: (i) => i == 0,
            itemWidth: 80,
            onSelected: (i) => setState(() => _weekIndex = i),
            shouldAddBottom: (_) => true,
            shouldAddTop: (_) => true,
          ),
          _SectionContent(
            'Week of ${_weekStart(_weekIndex).day}/'
            '${_weekStart(_weekIndex).month}/'
            '${_weekStart(_weekIndex).year}',
          ),

          const SizedBox(height: 32),

          // ── Category tabs (finite bounded list) ───────────
          _SectionLabel('Category tabs (finite)'),
          InfiniteTabBar(
            selectedIndex: _catIndex,
            labelBuilder: (i) =>
                i >= 0 && i < _cats.length ? _cats[i] : '',
            itemWidth: 110,
            onSelected: (i) => setState(() => _catIndex = i),
            shouldAddBottom: (i) => i < _cats.length,
            shouldAddTop: (_) => false,
          ),
          _SectionContent('Category: ${_cats[_catIndex]}'),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
      );
}

class _SectionContent extends StatelessWidget {
  const _SectionContent(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 16, top: 8),
        child: Text(text,
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary)),
      );
}
