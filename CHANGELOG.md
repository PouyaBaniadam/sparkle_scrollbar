## 0.0.4
* **CRITICAL FIX**: Resolved a severe framework assertion error (`!semantics.parentDataDirty` and UI freezing) caused by synchronous `setState` calls during the layout phase.
* Safely deferred scroll metric layout updates using `addPostFrameCallback` to ensure perfect compatibility with heavily nested and complex widget trees (like `ShaderMask`, `Flex`, and `SilkyScroll`).

## 0.0.3
* Added new **`ParticleShape.bubble`** effect featuring glossy translucent bubbles with realistic specular highlights and smooth side-to-side wobble motion.

## 0.0.2
* Fixed README image cache preview and license metadata.

## 0.0.1
* Initial release of SparkleScrollbar with GPU fragment shaders and dynamic particle engine.