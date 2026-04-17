import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Prevents the parent scroll view from intercepting pointer events
/// while the user is scrolling within this widget.
ValueNotifier<bool> cancelParentScroll = ValueNotifier<bool>(false);

/// A horizontally (or vertically) scrollable list that loads items
/// infinitely in both directions.
///
/// Items at negative indices grow to the left (or upward); items at
/// zero and above grow to the right (or downward).
class MultiDirectionalInfiniteScroll extends StatefulWidget {
  const MultiDirectionalInfiniteScroll({
    Key? key,
    required this.itemBuilder,
    required this.shouldAddTop,
    required this.shouldAddBottom,
    this.initialItems,
    this.overBoundsDetection = 50,
    this.startingScrollPosition = 0,
    this.duration = const Duration(milliseconds: 100),
    this.height,
    this.axis = Axis.horizontal,
    this.onTopLoaded,
    this.onBottomLoaded,
    this.onScroll,
    this.physics,
    this.scrollController,
  }) : super(key: key);

  /// Build a single item.
  ///
  /// [index] can be negative (items to the left/top of origin).
  /// [isFirst] and [isLast] indicate boundary items.
  final Widget Function(int index, bool isFirst, bool isLast) itemBuilder;

  /// Return `false` to stop loading items beyond [index] in the
  /// negative direction.
  final bool Function(int index) shouldAddTop;

  /// Return `false` to stop loading items beyond [index] in the
  /// positive direction.
  final bool Function(int index) shouldAddBottom;

  final int? initialItems;
  final int overBoundsDetection;
  final double startingScrollPosition;
  final Duration duration;
  final double? height;
  final Axis axis;
  final VoidCallback? onTopLoaded;
  final VoidCallback? onBottomLoaded;
  final void Function(double position)? onScroll;
  final ScrollPhysics? physics;
  final ScrollController? scrollController;

  @override
  State<MultiDirectionalInfiniteScroll> createState() =>
      MultiDirectionalInfiniteScrollState();
}

class MultiDirectionalInfiniteScrollState
    extends State<MultiDirectionalInfiniteScroll> {
  late ScrollController _ctrl;
  List<int> _top = [1];
  List<int> _bottom = [-1, 0];

  @override
  void initState() {
    super.initState();
    if (widget.initialItems != null) {
      _top = [];
      _bottom = [0];
      for (int i = 1; i < widget.initialItems!; i++) {
        _top.insert(0, -(widget.initialItems! - i));
        _bottom.add(i);
      }
    }
    _ctrl = widget.scrollController ?? ScrollController();
    _ctrl.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.animateTo(
        widget.startingScrollPosition,
        duration: widget.duration,
        curve: const ElasticOutCurve(0.7),
      );
    });
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _ctrl.removeListener(_onScroll);
      _ctrl.dispose();
    }
    super.dispose();
  }

  /// Animate scroll to [position] (defaults to [startingScrollPosition]).
  void scrollTo(Duration duration, {double? position}) {
    final target = position ?? widget.startingScrollPosition;
    final clamped = target.clamp(
      _ctrl.position.minScrollExtent,
      _ctrl.position.maxScrollExtent,
    );

    if (clamped == _ctrl.position.minScrollExtent ||
        clamped == _ctrl.position.maxScrollExtent) {
      _ctrl.notifyListeners();
      Future.delayed(const Duration(milliseconds: 1), () {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _ctrl.animateTo(
            target.clamp(_ctrl.position.minScrollExtent,
                _ctrl.position.maxScrollExtent),
            duration: duration,
            curve: Curves.fastOutSlowIn,
          );
        });
      });
    }

    _ctrl.animateTo(clamped,
        duration: duration, curve: Curves.fastOutSlowIn);
  }

  void _onScroll() {
    _checkBounds();
    widget.onScroll?.call(_ctrl.offset);
  }

  void _checkBounds() {
    if (_ctrl.offset >=
        _ctrl.position.maxScrollExtent - widget.overBoundsDetection) {
      _extendBottom();
      widget.onBottomLoaded?.call();
    }
    if (_ctrl.offset <=
        _ctrl.position.minScrollExtent + widget.overBoundsDetection) {
      _extendTop();
      widget.onTopLoaded?.call();
    }
  }

  void _extendBottom() {
    final next = _bottom.length;
    if (widget.shouldAddBottom(next)) setState(() => _bottom.add(next));
  }

  void _extendTop() {
    final next = -_top.length - 1;
    if (widget.shouldAddTop(next)) setState(() => _top.add(next));
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        cancelParentScroll.value = true;
        cancelParentScroll.notifyListeners();
      },
      onExit: (_) {
        cancelParentScroll.value = false;
        cancelParentScroll.notifyListeners();
      },
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            _ctrl.animateTo(
              _ctrl.offset + event.scrollDelta.dy,
              curve: Curves.linear,
              duration: const Duration(milliseconds: 100),
            );
          }
        },
        onPointerDown: (_) {
          if (_ctrl.offset >= _ctrl.position.maxScrollExtent ||
              _ctrl.offset <= _ctrl.position.minScrollExtent) {
            _checkBounds();
          }
        },
        child: SizedBox(
          height: widget.height,
          child: CustomScrollView(
            physics: widget.physics,
            scrollDirection: widget.axis,
            controller: _ctrl,
            center: const ValueKey('_center'),
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => SizedBox(
                    key: ValueKey(_top[i] * -1),
                    child: widget.itemBuilder(
                        _top[i], i == _top.length - 1, false),
                  ),
                  childCount: _top.length,
                ),
              ),
              SliverList(
                key: const ValueKey('_center'),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => SizedBox(
                    key: ValueKey(_bottom[i]),
                    child: widget.itemBuilder(
                        _bottom[i], false, i == _bottom.length - 1),
                  ),
                  childCount: _bottom.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
