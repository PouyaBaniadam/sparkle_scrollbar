import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../configs/enums.dart';
import '../configs/particle_config.dart';
import '../configs/physics_config.dart';
import '../configs/thumb_config.dart';
import '../configs/tooltip_config.dart';
import '../configs/track_config.dart';
import '../painters/classic_scrollbar_painter.dart';
import '../painters/shader_scrollbar_painter.dart';
import 'scroll_tooltip_bubble.dart';

/// A customizable, GPU-accelerated scrollbar with dynamic particle effects.
///
/// Wraps any scrollable widget (such as [ListView], [GridView], [SingleChildScrollView],
/// or [TextField]) to provide glowing shaders, dynamic sparks, tactile haptics,
/// and multi-axis support.
class SparkleScrollbar extends StatefulWidget {
  /// The scrollable child widget to attach the scrollbar to.
  final Widget child;

  /// An optional [ScrollController] that directly drives this scrollbar.
  final ScrollController? controller;

  /// The scrolling orientation direction of the scrollbar.
  final Axis orientation;

  /// The visual thickness width/height of the visible scrollbar track in pixels. Default is `40.0`.
  final double scrollbarThickness;

  /// The interactive touch and gesture detection boundary thickness. Default is `48.0`.
  final double hitAreaThickness;

  /// Outer padding margin around the scrollbar track relative to the viewport.
  final EdgeInsets margin;

  /// The placement side of the scrollbar along the viewport boundary.
  final ScrollbarAlignment alignment;

  /// The rendering engine mode: [ScrollbarRenderMode.shader] (GPU) or [ScrollbarRenderMode.classic] (Canvas).
  final ScrollbarRenderMode renderMode;

  /// Styling and material configuration for the draggable thumb capsule.
  final ThumbConfig thumbConfig;

  /// Configuration for emitted sparks, particle counts, and geometry shapes.
  final ParticleConfig particleConfig;

  /// Styling options for the background groove track.
  final TrackConfig trackConfig;

  /// Physics interpolation, inertia damping, auto-hide timers, and haptics.
  final ScrollPhysicsConfig physicsConfig;

  /// Floating position tooltip indicator configuration.
  final ScrollTooltipConfig tooltipConfig;

  /// Creates a [SparkleScrollbar] to wrap any scrollable widget.
  const SparkleScrollbar({
    super.key,
    required this.child,
    this.controller,
    this.orientation = Axis.vertical,
    this.scrollbarThickness = 40.0,
    this.hitAreaThickness = 48.0,
    this.margin = EdgeInsets.zero,
    this.alignment = ScrollbarAlignment.right,
    this.renderMode = ScrollbarRenderMode.shader,
    this.thumbConfig = const ThumbConfig(),
    this.particleConfig = const ParticleConfig(),
    this.trackConfig = const TrackConfig(),
    this.physicsConfig = const ScrollPhysicsConfig(),
    this.tooltipConfig = const ScrollTooltipConfig(),
  });

  @override
  State<SparkleScrollbar> createState() => _SparkleScrollbarState();
}

class _SparkleScrollbarState extends State<SparkleScrollbar>
    with SingleTickerProviderStateMixin {
  final GlobalKey _childKey = GlobalKey();
  ui.FragmentProgram? _program;
  late final Ticker _ticker;
  Timer? _decayTimer;
  Timer? _autoHideTimer;
  ScrollableState? _scrollableState;

  double _time = 0.0;
  double _displayThumbTop = 0.0;
  double _targetThumbTop = 0.0;
  double _displayThumbBottom = 0.20;
  double _targetThumbBottom = 0.20;

  double _displayActivity = 0.0;
  double _targetActivity = 0.0;
  double _displayVelocity = 0.0;
  double _targetVelocity = 0.0;

  double _scrollFraction = 0.0;
  double _currentPixels = 0.0;
  double _maxPixels = 0.0;

  bool _isDragging = false;
  bool _isHovered = false;
  bool _isAutoHidden = false;
  bool _metricsInitialized = false;

  /// Safely resolves the active [ScrollPosition] with content dimensions ready.
  ScrollPosition? get _effectivePosition {
    if (widget.controller != null && widget.controller!.hasClients) {
      final position = widget.controller!.position;
      if (position.hasContentDimensions) return position;
    }
    if (_scrollableState != null &&
        _scrollableState!.position.hasContentDimensions) {
      return _scrollableState!.position;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((elapsed) {
      _time = elapsed.inMilliseconds / 1000.0;

      final smooth = widget.physicsConfig.smoothness;
      _displayThumbTop += (_targetThumbTop - _displayThumbTop) * smooth;
      _displayThumbBottom +=
          (_targetThumbBottom - _displayThumbBottom) * smooth;

      _displayActivity += (_targetActivity - _displayActivity) * 0.14;
      _displayVelocity += (_targetVelocity - _displayVelocity) * 0.16;
      _targetVelocity *= 0.92;

      if (mounted) setState(() {});
    });

    widget.controller?.addListener(_onExplicitControllerNotification);

    WidgetsBinding.instance.addPostFrameCallback((_) => _initScrollableRef());
    if (widget.renderMode == ScrollbarRenderMode.shader) {
      _loadShader();
    }
  }

  @override
  void didUpdateWidget(covariant SparkleScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onExplicitControllerNotification);
      widget.controller?.addListener(_onExplicitControllerNotification);
      WidgetsBinding.instance.addPostFrameCallback((_) => _initScrollableRef());
    }
  }

  void _onExplicitControllerNotification() {
    if (widget.controller != null && widget.controller!.hasClients) {
      final pos = widget.controller!.position;
      if (pos.hasContentDimensions) {
        _updateMetrics(pos);
      }
    }
  }

  /// Traverses descendant elements to find the primary direct ScrollableState.
  ScrollableState? _findDescendantScrollable(BuildContext? context) {
    if (context == null) return null;
    ScrollableState? found;
    void visitor(Element element) {
      if (found != null) return;
      if (element is StatefulElement && element.state is ScrollableState) {
        final state = element.state as ScrollableState;
        if (state.widget.axis == widget.orientation) {
          found = state;
          return;
        }
      }
      element.visitChildren(visitor);
    }

    (context as Element).visitChildren(visitor);
    return found;
  }

  void _initScrollableRef() {
    if (widget.controller != null && widget.controller!.hasClients) {
      final pos = widget.controller!.position;
      if (pos.hasContentDimensions) {
        _updateMetrics(pos, immediate: true);
      }
      return;
    }

    _scrollableState = _findDescendantScrollable(_childKey.currentContext);
    if (_scrollableState != null &&
        _scrollableState!.position.hasContentDimensions) {
      _updateMetrics(_scrollableState!.position, immediate: true);
    }
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'packages/sparkle_scrollbar/shaders/sparkle_scrollbar.frag',
      );
      if (mounted) {
        setState(() => _program = program);
        if (!_ticker.isActive) _ticker.start();
      }
    } catch (_) {
      try {
        final program = await ui.FragmentProgram.fromAsset(
          'shaders/sparkle_scrollbar.frag',
        );
        if (mounted) {
          setState(() => _program = program);
          if (!_ticker.isActive) _ticker.start();
        }
      } catch (e) {
        debugPrint("SparkleScrollbar: Shader fallback active ($e)");
      }
    }
  }

  void _updateMetrics(ScrollMetrics metrics, {bool immediate = false}) {
    // Crucial safety check: ensure dimensions exist before reading extents
    if (!metrics.hasContentDimensions || metrics.viewportDimension <= 0) {
      return;
    }

    final oldMaxPixels = _maxPixels;
    _currentPixels = metrics.pixels;
    _maxPixels = metrics.maxScrollExtent;

    final totalContent = metrics.maxScrollExtent + metrics.viewportDimension;
    final naturalRatio =
        totalContent > 0 ? metrics.viewportDimension / totalContent : 0.2;
    final minThumbRatio = (50.0 / metrics.viewportDimension).clamp(0.06, 0.25);
    final viewPortRatio = naturalRatio.clamp(minThumbRatio, 0.40);

    if (metrics.maxScrollExtent > 0) {
      _scrollFraction =
          (metrics.pixels / metrics.maxScrollExtent).clamp(0.0, 1.0);
    } else {
      _scrollFraction = 0.0;
    }

    _targetThumbTop = _scrollFraction * (1.0 - viewPortRatio);
    _targetThumbBottom = _targetThumbTop + viewPortRatio;

    final bool scrollabilityChanged = (oldMaxPixels <= 0 && _maxPixels > 0) ||
        (oldMaxPixels > 0 && _maxPixels <= 0);

    if (immediate || !_metricsInitialized || scrollabilityChanged) {
      _displayThumbTop = _targetThumbTop;
      _displayThumbBottom = _targetThumbBottom;
      _metricsInitialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  void _wakeUpTicker() {
    if (!_ticker.isActive) _ticker.start();
    if (widget.physicsConfig.autoHide) {
      _isAutoHidden = false;
      _autoHideTimer?.cancel();
      _autoHideTimer = Timer(widget.physicsConfig.idleHideDelay, () {
        if (mounted && !_isDragging && !_isHovered) {
          setState(() => _isAutoHidden = true);
        }
      });
    }
  }

  void _triggerActivity(double delta) {
    _targetActivity = 1.0;
    _targetVelocity = (delta / 10.0).clamp(-2.5, 2.5);
    _wakeUpTicker();

    _decayTimer?.cancel();
    if (!_isDragging) {
      _decayTimer = Timer(widget.physicsConfig.fadeDuration, () {
        if (mounted && !_isDragging && !_isHovered) {
          _targetActivity = 0.0;
        }
      });
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // Isolate axis: Ignore bubbled notifications from orthogonal scroll views
    if (notification.metrics.axis != widget.orientation) {
      return false;
    }

    // Isolate depth: Only process primary direct scroll notifications
    if (notification.depth != 0) {
      return false;
    }

    if (notification.context != null && widget.controller == null) {
      _scrollableState = Scrollable.maybeOf(notification.context!);
    }

    _updateMetrics(notification.metrics);

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta;
      if (delta != null && delta != 0) _triggerActivity(delta);
    }
    return false;
  }

  void _handlePointerScroll(PointerScrollEvent event) {
    if (widget.physicsConfig.enableHorizontalMouseWheel &&
        widget.orientation == Axis.horizontal &&
        event.scrollDelta.dx == 0 &&
        event.scrollDelta.dy != 0) {
      final position = _effectivePosition;
      if (position == null || position.maxScrollExtent <= 0) return;

      final targetPixels = (position.pixels + event.scrollDelta.dy).clamp(
        0.0,
        position.maxScrollExtent,
      );
      position.jumpTo(targetPixels);
      _triggerActivity(event.scrollDelta.dy);
    }
  }

  void _onDragUpdate(double delta, double trackDimension) {
    final position = _effectivePosition;
    if (position == null || position.maxScrollExtent <= 0) return;

    final thumbLength = (_targetThumbBottom - _targetThumbTop) * trackDimension;
    final scrollableRange = trackDimension - thumbLength;
    if (scrollableRange <= 0) return;

    final deltaFraction = delta / scrollableRange;
    final targetPixels =
        (position.pixels + deltaFraction * position.maxScrollExtent).clamp(
      0.0,
      position.maxScrollExtent,
    );

    position.jumpTo(targetPixels);
    _triggerActivity(delta * 2.5);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onExplicitControllerNotification);
    _decayTimer?.cancel();
    _autoHideTimer?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final program = _program;
    final isShaderMode =
        widget.renderMode == ScrollbarRenderMode.shader && program != null;
    final isHoriz = widget.orientation == Axis.horizontal;

    final bool canScroll = _metricsInitialized && _maxPixels > 0.0;

    final cleanChild = Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          _handlePointerScroll(pointerSignal);
        }
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: widget.child,
      ),
    );

    final showTooltip = canScroll &&
        ((widget.tooltipConfig.mode == ScrollbarTooltipMode.alwaysOnScroll &&
                _displayActivity > 0.05) ||
            (widget.tooltipConfig.mode == ScrollbarTooltipMode.onDragOnly &&
                _isDragging));

    double? top, bottom, left, right, width, height;
    if (isHoriz) {
      left = widget.margin.left;
      right = widget.margin.right;
      height = widget.hitAreaThickness;
      if (widget.alignment == ScrollbarAlignment.top) {
        top = widget.margin.top;
      } else {
        bottom = widget.margin.bottom;
      }
    } else {
      top = widget.margin.top;
      bottom = widget.margin.bottom;
      width = widget.hitAreaThickness;
      if (widget.alignment == ScrollbarAlignment.left) {
        left = widget.margin.left;
      } else {
        right = widget.margin.right;
      }
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (metricsNotification) {
          if (metricsNotification.metrics.axis != widget.orientation ||
              metricsNotification.depth != 0) {
            return false;
          }

          _updateMetrics(
            metricsNotification.metrics,
            immediate: !_metricsInitialized,
          );
          return false;
        },
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            KeyedSubtree(key: _childKey, child: cleanChild),
            Positioned(
              top: top,
              bottom: bottom,
              left: left,
              right: right,
              width: width,
              height: height,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final trackDimension =
                      isHoriz ? constraints.maxWidth : constraints.maxHeight;

                  final gestureDetector = GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart:
                        isHoriz && canScroll ? (_) => _onDragStart() : null,
                    onHorizontalDragUpdate: isHoriz && canScroll
                        ? (d) => _onDragUpdate(d.delta.dx, trackDimension)
                        : null,
                    onHorizontalDragEnd:
                        isHoriz && canScroll ? (_) => _onDragEnd() : null,
                    onHorizontalDragCancel:
                        isHoriz && canScroll ? () => _onDragCancel() : null,
                    onVerticalDragStart:
                        !isHoriz && canScroll ? (_) => _onDragStart() : null,
                    onVerticalDragUpdate: !isHoriz && canScroll
                        ? (d) => _onDragUpdate(d.delta.dy, trackDimension)
                        : null,
                    onVerticalDragEnd:
                        !isHoriz && canScroll ? (_) => _onDragEnd() : null,
                    onVerticalDragCancel:
                        !isHoriz && canScroll ? () => _onDragCancel() : null,
                    child: Align(
                      alignment: isHoriz
                          ? (widget.alignment == ScrollbarAlignment.top
                              ? Alignment.topCenter
                              : Alignment.bottomCenter)
                          : (widget.alignment == ScrollbarAlignment.left
                              ? Alignment.centerLeft
                              : Alignment.centerRight),
                      child: SizedBox(
                        width: isHoriz
                            ? trackDimension
                            : widget.scrollbarThickness,
                        height: isHoriz
                            ? widget.scrollbarThickness
                            : trackDimension,
                        child: CustomPaint(
                          size: Size(
                            isHoriz
                                ? trackDimension
                                : widget.scrollbarThickness,
                            isHoriz
                                ? widget.scrollbarThickness
                                : trackDimension,
                          ),
                          painter: isShaderMode
                              ? ShaderScrollbarPainter(
                                  shader: program.fragmentShader(),
                                  time: _time,
                                  thumbTop: _displayThumbTop,
                                  thumbBottom: _displayThumbBottom,
                                  activity: _displayActivity,
                                  velocity: _displayVelocity,
                                  orientation: widget.orientation,
                                  thumbConfig: widget.thumbConfig,
                                  particleConfig: widget.particleConfig,
                                  trackConfig: widget.trackConfig,
                                )
                              : ClassicScrollbarPainter(
                                  thumbTop: _displayThumbTop,
                                  thumbBottom: _displayThumbBottom,
                                  activity: _displayActivity,
                                  orientation: widget.orientation,
                                  alignment: widget.alignment,
                                  thumbConfig: widget.thumbConfig,
                                  trackConfig: widget.trackConfig,
                                ),
                        ),
                      ),
                    ),
                  );

                  return AnimatedOpacity(
                    opacity: (_isAutoHidden || !canScroll) ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: IgnorePointer(
                      ignoring: !canScroll,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.grab,
                            onEnter: (_) {
                              if (!canScroll) return;
                              _isHovered = true;
                              _targetActivity = 0.6;
                              _wakeUpTicker();
                            },
                            onExit: (_) {
                              _isHovered = false;
                              if (!_isDragging) _targetActivity = 0.0;
                            },
                            child: gestureDetector,
                          ),
                          ScrollTooltipBubble(
                            thumbTop: _displayThumbTop,
                            thumbBottom: _displayThumbBottom,
                            trackDimension: trackDimension,
                            scrollFraction: _scrollFraction,
                            currentPixels: _currentPixels,
                            maxPixels: _maxPixels,
                            isVisible: showTooltip,
                            orientation: widget.orientation,
                            alignment: widget.alignment,
                            config: widget.tooltipConfig,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDragStart() {
    _isDragging = true;
    _decayTimer?.cancel();
    _targetActivity = 1.0;
    if (widget.physicsConfig.enableHaptics) {
      HapticFeedback.selectionClick();
    }
    _wakeUpTicker();
  }

  void _onDragEnd() {
    _isDragging = false;
    if (widget.physicsConfig.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    _decayTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted && !_isHovered) _targetActivity = 0.0;
    });
  }

  void _onDragCancel() {
    _isDragging = false;
    _targetActivity = 0.0;
  }
}
