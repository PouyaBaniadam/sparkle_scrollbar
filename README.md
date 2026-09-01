# Sparkle Scrollbar

A breathtaking, high-performance, GPU-accelerated custom scrollbar for Flutter powered by GLSL fragment shaders. It brings fluid liquid motion, dynamic particle sparks, and tactile haptic feedback to your scrollable views.

<p align="center">
  <img src="https://raw.githubusercontent.com/PouyaBaniadam/sparkle_scrollbar/refs/heads/main/assets/example_demo.gif" width="600" alt="Sparkle Scrollbar Demo">
</p>

---

## ✨ Features

* **GPU Fragment Shaders**: Built with custom GLSL shaders running natively on Flutter (Impeller & Skia compatible).
* **Multi-Axis Support**: Works seamlessly with both **Vertical** (`Axis.vertical`) and **Horizontal** (`Axis.horizontal`) scrollables.
* **Dynamic Particle Engine**: Emits glowing sparks with multiple distinct geometries (4-point shining stars, diamonds, pixels, and glowing circles).
* **Velocity Color Shifting**: Automatically shifts particle colors dynamically based on scroll velocity.
* **Tactile Haptics**: Built-in micro-vibrations on drag start and boundary overscrolls.
* **Floating Tooltip Bubbles**: Live tracking percentage or custom position indicator bubbles.
* **Classic Fallback Mode**: Includes an ultra-lightweight canvas renderer (`ScrollbarRenderMode.classic`) for unsupported environments.

---

## 📦 Installation

Add `sparkle_scrollbar` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  sparkle_scrollbar: ^0.0.1
```

---

## 🚀 Quick Start

Wrap any scrollable widget (such as `ListView`, `GridView`, or `SingleChildScrollView`) inside `SparkleScrollbar`:

```dart
import 'package:flutter/material.dart';
import 'package:sparkle_scrollbar/sparkle_scrollbar.dart';

class MyListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SparkleScrollbar(
        child: ListView.builder(
          itemCount: 50,
          itemBuilder: (context, index) => ListTile(
            title: Text('Item #${index + 1}'),
          ),
        ),
      ),
    );
  }
}
```

---

## 🎨 Advanced Customization

You can fully customize colors, particle count, physics damping, and orientation:

```dart
SparkleScrollbar(
  orientation: Axis.vertical,
  alignment: ScrollbarAlignment.right,
  thumbConfig: ThumbConfig.fromColor(Colors.cyanAccent, gripNotches: 3),
  particleConfig: ParticleConfig.fromColor(
    Colors.cyanAccent,
    count: 35,
    shape: ParticleShape.star,
    speed: 1.5,
  ),
  tooltipConfig: ScrollTooltipConfig.percentage(
    mode: ScrollbarTooltipMode.alwaysOnScroll,
  ),
  physicsConfig: const ScrollPhysicsConfig(
    smoothness: 0.25,
    enableHaptics: true,
  ),
  child: ListView.builder(...),
),
```

---

## ⚙️ Parameters Reference

### `SparkleScrollbar`
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `child` | `Widget` | *required* | The scrollable widget to attach the scrollbar to. |
| `orientation` | `Axis` | `Axis.vertical` | Scroll direction (`Axis.vertical` or `Axis.horizontal`). |
| `scrollbarThickness` | `double` | `40.0` | Visual width/height of the rendered scrollbar track. |
| `hitAreaThickness` | `double` | `48.0` | Touch gesture grab area width for mobile friendliness. |
| `alignment` | `ScrollbarAlignment` | `ScrollbarAlignment.right` | Position border (`right`, `left`, `top`, `bottom`). |
| `renderMode` | `ScrollbarRenderMode` | `ScrollbarRenderMode.shader` | GPU shader mode or classic canvas fallback. |
| `thumbConfig` | `ThumbConfig` | Default | Appearance, material, thickness, and grip notches of the thumb. |
| `particleConfig` | `ParticleConfig` | Default | Particle count, sizes, shapes, and velocity color dynamics. |
| `trackConfig` | `TrackConfig` | Default | Background groove track visibility and opacity. |
| `physicsConfig` | `ScrollPhysicsConfig` | Default | Inertia damping, haptics, auto-hide, and mouse wheel translation. |
| `tooltipConfig` | `ScrollTooltipConfig` | Default | Floating position or percentage indicator bubble behavior. |

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---
