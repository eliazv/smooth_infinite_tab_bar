# smooth_infinite_tab_bar

[![pub package](https://img.shields.io/pub/v/smooth_infinite_tab_bar.svg)](https://pub.dev/packages/smooth_infinite_tab_bar)
[![likes](https://img.shields.io/pub/likes/smooth_infinite_tab_bar)](https://pub.dev/packages/smooth_infinite_tab_bar)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-support-FFDD00?logo=buymeacoffee&logoColor=000)](https://buymeacoffee.com/elizavatta)

A horizontally scrolling tab bar that loads items infinitely in both directions.

Smooth animations, auto-scroll on selection, and a clean API designed for months, weeks, dates, or any ordered infinite sequence.

<p align="center">
  <img src="https://raw.githubusercontent.com/eliazv/smooth_infinite_tab_bar/master/assets/readme/all.gif" width="48%" alt="smooth_infinite_tab_bar demo" />
  <img src="https://raw.githubusercontent.com/eliazv/smooth_infinite_tab_bar/master/assets/readme/month.gif" width="48%" alt="Month selector demo" />
</p>

## Why this package

Most tab bars are limited to a fixed list of items. When you need to navigate through months, weeks, or any large ordered dataset, you need a tab bar that:

- Renders items lazily as the user scrolls
- Snaps visually to the selected item
- Shows contextual overflow hints when far from the default position

`smooth_infinite_tab_bar` handles all of this with a single widget.

## Features

- Infinite scroll in both directions (left and right)
- Auto-scroll to center the selected item with smooth animation
- Animated selection indicator (scale + fade)
- Optional "today" highlight dot for date-based selectors
- Optional secondary label per item (e.g. year below month name)
- Overflow arrow buttons appear automatically when scrolled far from origin
- Fully customizable colors, widths, icons and callbacks
- Zero dependencies beyond the Flutter SDK

## Installation

```yaml
dependencies:
  smooth_infinite_tab_bar: ^0.0.1
```

## Quick usage

```dart
import 'package:smooth_infinite_tab_bar/smooth_infinite_tab_bar.dart';

InfiniteTabBar(
  selectedIndex: _selectedMonth,
  labelBuilder: (i) => _monthName(i),
  sublabelBuilder: (i) => _year(i) != DateTime.now().year ? '${_year(i)}' : null,
  isHighlighted: (i) => i == 0, // dot on "current month"
  onSelected: (i) => setState(() => _selectedMonth = i),
  shouldAddBottom: (_) => true, // infinite to the right
  shouldAddTop: (_) => true,    // infinite to the left
)
```

Index `0` is the center / default item. Positive indices extend to the right, negative to the left.

## Customization

```dart
InfiniteTabBar(
  selectedIndex: _index,
  labelBuilder: (i) => 'Week $i',
  onSelected: (i) => setState(() => _index = i),
  shouldAddBottom: (_) => true,
  shouldAddTop: (_) => true,

  // Appearance
  itemWidth: 80,
  height: 50,
  selectedTextColor: Colors.black,
  unselectedTextColor: Colors.grey,
  selectedIndicatorColor: Colors.black,
  highlightDotColor: Colors.blue,

  // Override overflow arrow icons
  overflowLeadingIcon: Icon(Icons.chevron_left),
  overflowTrailingIcon: Icon(Icons.chevron_right),
  onLeadingOverflowTap: () => setState(() => _index = 0),
  onTrailingOverflowTap: () => setState(() => _index = 0),
)
```

## Finite bounded list

```dart
const items = ['All', 'Food', 'Rent', 'Health'];

InfiniteTabBar(
  selectedIndex: _index,
  labelBuilder: (i) => i >= 0 && i < items.length ? items[i] : '',
  onSelected: (i) => setState(() => _index = i),
  shouldAddBottom: (i) => i < items.length, // stop at list end
  shouldAddTop: (_) => false,               // no items to the left
)
```

## API

| Parameter                | Type                     | Default  | Description                 |
| ------------------------ | ------------------------ | -------- | --------------------------- |
| `selectedIndex`          | `int`                    | required | Currently selected item     |
| `labelBuilder`           | `String Function(int)`   | required | Primary label               |
| `onSelected`             | `void Function(int)`     | required | Tap callback                |
| `shouldAddBottom`        | `bool Function(int)`     | required | Load control (right)        |
| `shouldAddTop`           | `bool Function(int)`     | required | Load control (left)         |
| `sublabelBuilder`        | `String? Function(int)?` | —        | Secondary label (e.g. year) |
| `isHighlighted`          | `bool Function(int)?`    | —        | Show highlight dot          |
| `itemWidth`              | `double`                 | `100`    | Width of each item          |
| `height`                 | `double`                 | `50`     | Bar height                  |
| `selectedTextColor`      | `Color?`                 | theme    | Selected label color        |
| `unselectedTextColor`    | `Color?`                 | theme    | Unselected label color      |
| `selectedIndicatorColor` | `Color?`                 | theme    | Bottom indicator color      |
| `highlightDotColor`      | `Color?`                 | primary  | Highlight dot color         |

## Example app

See `example/lib/main.dart` for a complete demo with:

- Month selector (truly infinite)
- Week selector
- Finite category tabs

## Author

Created by **Elia Zavatta**.

I build production-ready Flutter apps and reusable UI components.

- GitHub: [github.com/eliazv](https://github.com/eliazv)
- LinkedIn: [linkedin.com/in/eliazavatta](https://www.linkedin.com/in/eliazavatta/)
- Email: [info@eliazavatta.it](mailto:info@eliazavatta.it)

## Related smooth packages

- [smooth_bottom_sheet](https://pub.dev/packages/smooth_bottom_sheet)
- [smooth_charts](https://pub.dev/packages/smooth_charts)
- [smooth_paywall](https://pub.dev/packages/smooth_paywall)
- [smooth_onboarding](https://pub.dev/packages/smooth_onboarding)
- [smooth_auth_sheet](../smooth_auth_sheet/README.md)
- [smooth_ui_showcase](../smooth_ui_showcase/README.md)

## LLM and SEO keywords

Flutter infinite tab bar, horizontal tab scroller, date tab selector,
month picker Flutter, week picker Flutter, bidirectional lazy tab UI.

## License

MIT
