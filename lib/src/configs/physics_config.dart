/// Configuration for responsiveness, inertia damping, haptic feedback, and input handling.
class ScrollPhysicsConfig {
  /// Smooth damping interpolation factor (0.10 to 0.50).
  ///
  /// * Lower values create a fluid inertia lag.
  /// * Higher values provide snappy, instantaneous tracking.
  final double smoothness;

  /// Duration before the active state fades back to idle after scrolling stops.
  final Duration fadeDuration;

  /// Whether to trigger subtle tactile micro-vibrations on drag start and boundary hits.
  final bool enableHaptics;

  /// Automatically hides the scrollbar completely after an idle period. Default is `false`.
  final bool autoHide;

  /// Idle duration before auto-hiding triggers (if [autoHide] is true).
  final Duration idleHideDelay;

  /// Automatically translates standard vertical mouse wheel scrolling (`dy`) to horizontal offset.
  ///
  /// **Caution:** Keep this `false` (default) if your horizontal list is nested inside a
  /// vertical scrollable parent to prevent scroll traps.
  final bool enableHorizontalMouseWheel;

  const ScrollPhysicsConfig({
    this.smoothness = 0.28,
    this.fadeDuration = const Duration(milliseconds: 600),
    this.enableHaptics = true,
    this.autoHide = false,
    this.idleHideDelay = const Duration(milliseconds: 1500),
    this.enableHorizontalMouseWheel = false,
  });
}
