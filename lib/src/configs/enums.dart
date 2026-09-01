/// Defines the rendering engine mode used by the scrollbar.
enum ScrollbarRenderMode {
  /// Full GPU fragment shader mode with glowing aura and floating particles.
  shader,

  /// Lightweight Canvas-based minimal fallback scrollbar without shader execution.
  classic,
}

/// Geometric particle shapes supported by the GLSL shader engine.
enum ParticleShape {
  /// Soft glowing circular dot.
  circle,

  /// Four-point shining star flare with cross-directional light rays.
  star,

  /// Sharp 45-degree rotated diamond rhombus.
  diamond,

  /// Pixelated retro square box.
  square,
}

/// Positioning alignment of the scrollbar along the viewport boundary.
enum ScrollbarAlignment {
  /// Aligns to the right edge (vertical scrolling).
  right,

  /// Aligns to the left edge (vertical scrolling / RTL layouts).
  left,

  /// Aligns to the bottom edge (horizontal scrolling).
  bottom,

  /// Aligns to the top edge (horizontal scrolling).
  top,
}

/// Behavior modes for displaying the floating scroll position tooltip.
enum ScrollbarTooltipMode {
  /// Tooltip appears only while actively dragging the thumb.
  onDragOnly,

  /// Tooltip appears whenever any scroll activity occurs (wheel, drag, touch).
  alwaysOnScroll,

  /// Tooltip is completely disabled and will not render.
  none,
}
