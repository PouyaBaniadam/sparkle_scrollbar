/// A customizable, GPU-accelerated glow shader scrollbar with dynamic particle effects for Flutter.
///
/// Features:
/// * GPU-accelerated particle shader effects via Flutter runtime effects.
/// * Support for both [Axis.vertical] and [Axis.horizontal] scrollables.
/// * Dynamic particle shapes: stars, diamonds, squares, and glowing circles.
/// * Velocity-driven particle color shifts and propulsion dynamics.
/// * Built-in tactile haptic feedback and inertia damping physics.
/// * Floating position and percentage tooltip bubbles.
/// * Ultra-lightweight fallback classic canvas mode.
library sparkle_scrollbar;

export 'src/configs/enums.dart';
export 'src/configs/particle_config.dart';
export 'src/configs/physics_config.dart';
export 'src/configs/thumb_config.dart';
export 'src/configs/tooltip_config.dart';
export 'src/configs/track_config.dart';
export 'src/widgets/sparkle_scrollbar.dart';
