import 'package:flutter/material.dart';
import 'multi_directional_infinite_scroll.dart';

/// A horizontally scrolling tab bar with infinite items in both
/// directions.
///
/// Index 0 is the "center" / default item (e.g. current month,
/// current week, today). Positive indices extend to the right;
/// negative indices extend to the left.
///
/// ```dart
/// InfiniteTabBar(
///   selectedIndex: _selectedIndex,
///   labelBuilder: (i) {
///     final date = DateTime.now().add(Duration(days: 30 * i));
///     return DateFormat('MMM').format(date);
///   },
///   sublabelBuilder: (i) {
///     final date = DateTime.now().add(Duration(days: 30 * i));
///     return DateTime.now().year != date.year ? '${date.year}' : null;
///   },
///   isHighlighted: (i) => i == 0, // "today" dot
///   onSelected: (i) => setState(() => _selectedIndex = i),
///   shouldAddBottom: (i) => i <= 60,
///   shouldAddTop: (i) => i >= -60,
/// )
/// ```
class InfiniteTabBar extends StatefulWidget {
  const InfiniteTabBar({
    super.key,
    required this.selectedIndex,
    required this.labelBuilder,
    required this.onSelected,
    required this.shouldAddBottom,
    required this.shouldAddTop,
    this.sublabelBuilder,
    this.isHighlighted,
    this.itemWidth = 100,
    this.height = 50,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.selectedIndicatorColor,
    this.highlightDotColor,
    this.trackColor,
    this.overflowLeadingIcon,
    this.overflowTrailingIcon,
    this.onLeadingOverflowTap,
    this.onTrailingOverflowTap,
    this.initialItems = 10,
    this.width,
  });

  /// The currently selected item index.
  final int selectedIndex;

  /// Primary label for item at [index].
  final String Function(int index) labelBuilder;

  /// Optional secondary label (e.g. year). Return null to hide.
  final String? Function(int index)? sublabelBuilder;

  /// Return true to show a small "today" dot under the item.
  final bool Function(int index)? isHighlighted;

  /// Called when the user taps an item.
  final void Function(int index) onSelected;

  /// Return false to stop adding items in the positive direction.
  final bool Function(int index) shouldAddBottom;

  /// Return false to stop adding items in the negative direction.
  final bool Function(int index) shouldAddTop;

  final double itemWidth;
  final double height;

  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final Color? selectedIndicatorColor;

  /// Color of the small dot marking "highlighted" (e.g. today) items.
  final Color? highlightDotColor;

  /// Background track color (thin line under all items).
  final Color? trackColor;

  // ── Overflow buttons ──────────────────────────────────────────────
  /// Icon shown on the left edge when the list is scrolled past start.
  final Widget? overflowLeadingIcon;

  /// Icon shown on the right edge when the list is scrolled past end.
  final Widget? overflowTrailingIcon;

  /// Called when the user taps the left overflow button.
  final VoidCallback? onLeadingOverflowTap;

  /// Called when the user taps the right overflow button.
  final VoidCallback? onTrailingOverflowTap;

  final int initialItems;
  final double? width;

  @override
  State<InfiniteTabBar> createState() => InfiniteTabBarState();
}

class InfiniteTabBarState extends State<InfiniteTabBar> {
  final _scrollKey = GlobalKey<MultiDirectionalInfiniteScrollState>();

  bool _showLeadingOverflow = false;
  bool _showTrailingOverflow = false;

  double _measureWidth(BuildContext context) =>
      widget.width ?? MediaQuery.sizeOf(context).width;

  @override
  void didUpdateWidget(InfiniteTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      // Defer to avoid mutating scroll position during an active layout pass.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) scrollToIndex(widget.selectedIndex);
      });
    }
  }

  /// Smoothly scrolls the bar so that [index] is centered.
  void scrollToIndex(int index, {Duration? duration}) {
    final w = _measureWidth(context);
    final position = -w / 2 + widget.itemWidth / 2 + index * widget.itemWidth;
    _scrollKey.currentState?.scrollTo(
      duration ?? const Duration(milliseconds: 700),
      position: position,
    );
  }

  void _onScroll(double position) {
    final w = _measureWidth(context);
    final upper = 200.0;
    final lower = -200 - w / 2 - 100;

    final showTrailing = position > upper;
    final showLeading = position < lower;

    if (showTrailing != _showTrailingOverflow ||
        showLeading != _showLeadingOverflow) {
      setState(() {
        _showTrailingOverflow = showTrailing;
        _showLeadingOverflow = showLeading;
      });
    }

    if (position > lower && position < upper) {
      if (_showLeadingOverflow || _showTrailingOverflow) {
        setState(() {
          _showLeadingOverflow = false;
          _showTrailingOverflow = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = _measureWidth(context);
    final selected =
        widget.selectedTextColor ?? Theme.of(context).colorScheme.onSurface;
    final unselected =
        widget.unselectedTextColor ??
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);
    final indicator =
        widget.selectedIndicatorColor ??
        Theme.of(context).colorScheme.onSurface;
    final track =
        widget.trackColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight =
        widget.highlightDotColor ?? Theme.of(context).colorScheme.primary;

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        // Defer scroll: SizeChangedLayoutNotification fires during layout,
        // mutating the viewport in the same pass causes a Flutter error.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final w2 = _measureWidth(context);
          final pos =
              -w2 / 2 +
              widget.itemWidth / 2 +
              widget.selectedIndex * widget.itemWidth;
          _scrollKey.currentState?.scrollTo(
            const Duration(milliseconds: 700),
            position: pos,
          );
        });
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Stack(
          children: [
            MultiDirectionalInfiniteScroll(
              key: _scrollKey,
              height: widget.height,
              overBoundsDetection: 50,
              initialItems: widget.initialItems,
              startingScrollPosition: -w / 2 + widget.itemWidth / 2,
              duration: const Duration(milliseconds: 1500),
              shouldAddBottom: widget.shouldAddBottom,
              shouldAddTop: widget.shouldAddTop,
              onScroll: _onScroll,
              itemBuilder: (index, isFirst, isLast) {
                final isSelected = index == widget.selectedIndex;
                final isHL = widget.isHighlighted?.call(index) ?? false;
                final spacePad = w / 2 - widget.itemWidth / 2;

                return Container(
                  color: Theme.of(context).colorScheme.surface,
                  padding: EdgeInsetsDirectional.only(
                    start: isFirst ? spacePad : 0,
                    end: isLast ? spacePad : 0,
                  ),
                  child: Stack(
                    children: [
                      // ── Tap area + label ─────────────────────
                      SizedBox(
                        height: widget.height,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => widget.onSelected(index),
                            child: SizedBox(
                              width: widget.itemWidth,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Text(
                                        widget.labelBuilder(index),
                                        key: ValueKey(
                                          '${index}_${isSelected}_label',
                                        ),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSelected
                                              ? selected
                                              : unselected,
                                          fontWeight: isHL
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.clip,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Builder(
                                      builder: (context) {
                                        final sub = widget.sublabelBuilder
                                            ?.call(index);
                                        if (sub == null) {
                                          return const SizedBox.shrink();
                                        }
                                        return AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          child: Text(
                                            sub,
                                            key: ValueKey(
                                              '${index}_${isSelected}_sub',
                                            ),
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: isSelected
                                                  ? selected
                                                  : unselected,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Highlighted (e.g. "today") dot ───────
                      if (isHL && !isSelected)
                        Align(
                          alignment: AlignmentDirectional.bottomEnd,
                          child: SizedBox(
                            width: widget.itemWidth,
                            child: Center(
                              heightFactor: 0.5,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40),
                                  ),
                                  color: highlight.withValues(alpha: 0.5),
                                ),
                                width: 75,
                                height: 7,
                              ),
                            ),
                          ),
                        ),

                      // ── Track line ───────────────────────────
                      Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Container(
                          width: widget.itemWidth,
                          height: 2,
                          color: track,
                        ),
                      ),

                      // ── Selected indicator bar ───────────────
                      Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: _ScaleOpacity(
                          animateIn: isSelected,
                          duration: const Duration(milliseconds: 500),
                          durationOpacity: const Duration(milliseconds: 300),
                          curve: isSelected
                              ? Curves.decelerate
                              : Curves.easeOutQuart,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                              color: indicator,
                            ),
                            width: widget.itemWidth,
                            height: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // ── Leading overflow button ─────────────────────────
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _ScaleOpacity(
                animateIn: _showLeadingOverflow,
                duration: const Duration(milliseconds: 400),
                durationOpacity: const Duration(milliseconds: 200),
                alignment: AlignmentDirectional.centerStart,
                curve: Curves.fastOutSlowIn,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 8,
                    bottom: 8,
                    start: 2,
                  ),
                  child: Material(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap:
                          widget.onLeadingOverflowTap ??
                          () {
                            _scrollKey.currentState?.scrollTo(
                              const Duration(milliseconds: 700),
                            );
                            widget.onSelected(0);
                          },
                      child: SizedBox(
                        width: 44,
                        height: 34,
                        child:
                            widget.overflowLeadingIcon ??
                            Icon(
                              Icons.arrow_left_rounded,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 28,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Trailing overflow button ────────────────────────
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _ScaleOpacity(
                animateIn: _showTrailingOverflow,
                duration: const Duration(milliseconds: 400),
                durationOpacity: const Duration(milliseconds: 200),
                alignment: AlignmentDirectional.centerEnd,
                curve: Curves.fastOutSlowIn,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 8,
                    bottom: 8,
                    end: 2,
                  ),
                  child: Material(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap:
                          widget.onTrailingOverflowTap ??
                          () {
                            _scrollKey.currentState?.scrollTo(
                              const Duration(milliseconds: 700),
                            );
                            widget.onSelected(0);
                          },
                      child: SizedBox(
                        width: 44,
                        height: 34,
                        child:
                            widget.overflowTrailingIcon ??
                            Icon(
                              Icons.arrow_right_rounded,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 28,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Internal animation helper ─────────────────────────────────────────

class _ScaleOpacity extends StatelessWidget {
  const _ScaleOpacity({
    required this.child,
    required this.animateIn,
    this.duration = const Duration(milliseconds: 500),
    this.durationOpacity = const Duration(milliseconds: 100),
    this.alignment = AlignmentDirectional.center,
    this.curve = Curves.easeInOutCubicEmphasized,
  });

  final Widget child;
  final bool animateIn;
  final Duration duration;
  final Duration durationOpacity;
  final AlignmentDirectional alignment;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: durationOpacity,
      opacity: animateIn ? 1 : 0,
      child: AnimatedScale(
        scale: animateIn ? 1 : 0,
        duration: duration,
        curve: curve,
        alignment: alignment.resolve(Directionality.of(context)),
        child: child,
      ),
    );
  }
}
