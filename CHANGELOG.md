## 0.0.6
* **CRITICAL FIX**: Resolved a notification collision issue in nested scroll views where horizontal scroll actions erroneously triggered orthogonal vertical scrollbar animations and metric updates.
* **FIX**: Fixed an issue where the scrollbar thumb, track, and glowing shader particles remained visible when content did not exceed the viewport boundary (`maxScrollExtent <= 0`).
* **IMPROVEMENT**: Added automatic smooth fade-out animations when content is not scrollable, dynamically restoring visibility upon viewport resizing or list expansion.
* **UX FIX**: Wrapped non-scrollable states in `IgnorePointer` to prevent phantom touch interception over underlying clickable UI elements.

## 0.0.5
* **FIX**: Fixed an issue where the scrollbar thumb and particle effects remained visible when the content did not exceed the viewport boundary (`maxScrollExtent <= 0`).
* **IMPROVEMENT**: Added automatic, smooth fade-out animations when content is not scrollable, dynamically fading back in upon window resize or list expansion.
* **UX FIX**: Wrapped non-scrollable states with `IgnorePointer` to prevent phantom gesture interception over underlying UI elements.

## 0.0.4
* **CRITICAL FIX**: Resolved a severe framework assertion error (`!semantics.parentDataDirty` and UI freezing) caused by synchronous `setState` calls during the layout phase.
* Safely deferred scroll metric layout updates using `addPostFrameCallback` to ensure perfect compatibility with heavily nested and complex widget trees (like `ShaderMask`, `Flex`, and `SilkyScroll`).

## 0.0.3
* Added new **`ParticleShape.bubble`** effect featuring glossy translucent bubbles with realistic specular highlights and smooth side-to-side wobble motion.

## 0.0.2
* Fixed README image cache preview and license metadata.

## 0.0.1
* Initial release of SparkleScrollbar with GPU fragment shaders and dynamic particle engine.