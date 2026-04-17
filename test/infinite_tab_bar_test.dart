import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_infinite_tab_bar/smooth_infinite_tab_bar.dart';

void main() {
  testWidgets('renders label for selected index', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InfiniteTabBar(
            selectedIndex: 0,
            labelBuilder: (i) => 'Item $i',
            onSelected: (_) {},
            shouldAddBottom: (i) => i < 5,
            shouldAddTop: (_) => false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Item 0'), findsOneWidget);
  });

  testWidgets('calls onSelected on tap', (tester) async {
    int? tapped;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InfiniteTabBar(
            selectedIndex: 0,
            labelBuilder: (i) => 'Tab $i',
            onSelected: (i) => tapped = i,
            shouldAddBottom: (i) => i < 5,
            shouldAddTop: (_) => false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Tab 0'));
    await tester.pumpAndSettle();

    expect(tapped, 0);
  });

  testWidgets('shows sublabel when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InfiniteTabBar(
            selectedIndex: 0,
            labelBuilder: (i) => 'Jan',
            sublabelBuilder: (i) => '2025',
            onSelected: (_) {},
            shouldAddBottom: (i) => i < 3,
            shouldAddTop: (_) => false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('2025'), findsWidgets);
  });

  testWidgets('MultiDirectionalInfiniteScroll renders initial items',
      (tester) async {
    final rendered = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiDirectionalInfiniteScroll(
            itemBuilder: (index, isFirst, isLast) {
              rendered.add(index);
              return SizedBox(
                width: 100,
                child: Text('$index'),
              );
            },
            shouldAddBottom: (i) => i < 5,
            shouldAddTop: (_) => false,
            initialItems: 3,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(rendered.isNotEmpty, true);
  });
}
