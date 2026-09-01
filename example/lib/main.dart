import 'package:flutter/material.dart';
import 'package:sparkle_scrollbar/sparkle_scrollbar.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080A10),
      ),
      home: const SparkleScrollStudioScreen(),
    );
  }
}

class SparkleScrollStudioScreen extends StatefulWidget {
  const SparkleScrollStudioScreen({super.key});

  @override
  State<SparkleScrollStudioScreen> createState() =>
      _SparkleScrollStudioScreenState();
}

class _SparkleScrollStudioScreenState extends State<SparkleScrollStudioScreen> {
  // Infinite Hue Tuning (0.0 to 360.0 degrees)
  double _hue = 0.0;
  final double _saturation = 1.0;
  final double _lightness = 0.55;

  // Orientation & Tooltip state
  bool _isHorizontal = false;
  bool _showPercentageTooltip = false;

  // Particle dynamics state
  int _particleCount = 30;
  double _particleSize = 0.065;
  double _sparkSpeed = 1.2;
  final double _sparkIntensity = 1.0;
  ParticleShape _shape = ParticleShape.star;
  final bool _colorShift = false;

  // Thumb and Track geometry state
  double _thumbThickness = 0.095;
  int _gripNotches = 3;
  bool _enableWave = true;
  bool _showTrack = true;
  final double _trackOpacity = 0.15;

  // Physics, interaction, and input translation state
  bool _useClassic = false;
  final double _smoothness = 0.28;
  final bool _enableHaptics = true;
  bool _enableHorizontalMouseWheel = true;
  ScrollbarAlignment _alignment = ScrollbarAlignment.right;

  // Exact color calculations
  Color get _currentExactColor =>
      HSLColor.fromAHSL(1.0, _hue, _saturation, _lightness).toColor();
  Color get _currentGlowColor => HSLColor.fromAHSL(
        1.0,
        _hue,
        _saturation,
        (_lightness + 0.2).clamp(0.0, 1.0),
      ).toColor();
  Color get _currentSparkColor => HSLColor.fromAHSL(
        1.0,
        _hue,
        (_saturation * 0.9).clamp(0.0, 1.0),
        (_lightness + 0.35).clamp(0.0, 1.0),
      ).toColor();

  @override
  Widget build(BuildContext context) {
    final activeColor = _currentExactColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sparkle Scrollbar Studio",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF10131D),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Settings & Descriptions",
            icon: const Icon(Icons.tune),
            onPressed: () => _openInspector(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 360-Degree Spectrum Hue Picker and Orientation Toggle
          Container(
            color: const Color(0xFF121522),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: activeColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "HUE: ${_hue.toInt()}° (#${activeColor.value.toRadixString(16).substring(2).toUpperCase()})",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: activeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Horizontal: ",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Switch(
                          value: _isHorizontal,
                          activeColor: activeColor,
                          onChanged: (v) => setState(() {
                            _isHorizontal = v;
                            _alignment = v
                                ? ScrollbarAlignment.bottom
                                : ScrollbarAlignment.right;
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 360-Degree Continuous Hue Spectrum Gradient
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF0000),
                        Color(0xFFFFFF00),
                        Color(0xFF00FF00),
                        Color(0xFF00FFFF),
                        Color(0xFF0000FF),
                        Color(0xFFFF00FF),
                        Color(0xFFFF0000),
                      ],
                    ),
                  ),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 14,
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 9,
                      ),
                      overlayColor: Colors.transparent,
                    ),
                    child: Slider(
                      min: 0.0,
                      max: 360.0,
                      value: _hue,
                      onChanged: (v) => setState(() => _hue = v),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Viewport with Multi-Axis Sparkle Scrollbar
          Expanded(
            child: SparkleScrollbar(
              orientation: _isHorizontal ? Axis.horizontal : Axis.vertical,
              alignment: _alignment,
              renderMode: _useClassic
                  ? ScrollbarRenderMode.classic
                  : ScrollbarRenderMode.shader,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              thumbConfig: ThumbConfig(
                thickness: _thumbThickness,
                color: activeColor,
                glowColor: _currentGlowColor,
                gripNotchCount: _gripNotches,
                enableWaveEffect: _enableWave,
              ),
              particleConfig: ParticleConfig(
                count: _particleCount,
                minSize: _particleSize * 0.55,
                maxSize: _particleSize,
                speed: _sparkSpeed,
                intensity: _sparkIntensity,
                shape: _shape,
                color: _currentSparkColor,
                velocityShiftColor: _currentGlowColor,
                enableColorShift: _colorShift,
              ),
              trackConfig: TrackConfig(
                showTrack: _showTrack,
                opacity: _trackOpacity,
                color: activeColor,
              ),
              tooltipConfig: ScrollTooltipConfig.percentage(
                mode: _showPercentageTooltip
                    ? ScrollbarTooltipMode.alwaysOnScroll
                    : ScrollbarTooltipMode.none,
                backgroundColor: const Color(0xFF151928),
                textColor: _currentGlowColor,
              ),
              physicsConfig: ScrollPhysicsConfig(
                enableHaptics: _enableHaptics,
                smoothness: _smoothness,
                enableHorizontalMouseWheel: _enableHorizontalMouseWheel,
              ),
              child: ListView.builder(
                scrollDirection:
                    _isHorizontal ? Axis.horizontal : Axis.vertical,
                itemCount: 80,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                itemBuilder: (context, index) => Container(
                  width: _isHorizontal ? 220 : null,
                  margin: EdgeInsets.only(
                    bottom: _isHorizontal ? 0 : 12,
                    right: _isHorizontal ? 12 : 0,
                  ),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131724),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Item #${index + 1}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isHorizontal
                                ? "Horizontal Scroll"
                                : "Vertical Scroll",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: activeColor.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF10131D),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: activeColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.tune),
          label: const Text(
            "Open All Features & Descriptions",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => _openInspector(context),
        ),
      ),
    );
  }

  void _openInspector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D0F18),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            void update(VoidCallback fn) {
              setSheetState(fn);
              setState(fn);
            }

            final activeColor = _currentExactColor;

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (ctx, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: activeColor),
                        const SizedBox(width: 8),
                        const Text(
                          "Feature Studio & Docs",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Full control over every GPU shader uniform and physics parameter.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Divider(height: 28),
                    _buildSectionHeader(
                      "1. Tooltip & Percentage Display",
                      Icons.info_outline,
                      Colors.cyanAccent,
                    ),
                    _buildSwitchDocTile(
                      title: "Show Percentage Bubble",
                      description:
                          "Enables or completely disables the floating percentage indicator next to the thumb.",
                      value: _showPercentageTooltip,
                      activeColor: activeColor,
                      onChanged: (v) =>
                          update(() => _showPercentageTooltip = v),
                    ),
                    const Divider(height: 28),
                    _buildSectionHeader(
                      "2. Particle Shapes & Glow",
                      Icons.bubble_chart,
                      Colors.purpleAccent,
                    ),
                    _buildDocTile(
                      title: "Particle Shape",
                      description:
                          "GLSL mathematical geometry rendering 4-point shining stars, diamonds, pixels, or glowing circles.",
                      control: DropdownButton<ParticleShape>(
                        value: _shape,
                        underline: const SizedBox.shrink(),
                        items: ParticleShape.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.name.toUpperCase(),
                              style: TextStyle(color: activeColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => update(() => _shape = v!),
                      ),
                    ),
                    _buildSliderDocTile(
                      title: "Particle Count",
                      description:
                          "Number of sparks emitting from the active thumb capsule (0 to 50).",
                      val: _particleCount.toDouble(),
                      min: 0,
                      max: 50,
                      activeColor: activeColor,
                      displayVal: "$_particleCount sparks",
                      onChanged: (v) =>
                          update(() => _particleCount = v.round()),
                    ),
                    _buildSliderDocTile(
                      title: "Particle Size",
                      description:
                          "Diameter scale of the sparks and their light aura.",
                      val: _particleSize,
                      min: 0.02,
                      max: 0.14,
                      activeColor: activeColor,
                      displayVal: "${(_particleSize * 100).toInt()}%",
                      onChanged: (v) => update(() => _particleSize = v),
                    ),
                    _buildSliderDocTile(
                      title: "Emission Speed",
                      description:
                          "Speed multiplier launching particles in the opposite direction of scrolling.",
                      val: _sparkSpeed,
                      min: 0.5,
                      max: 3.0,
                      activeColor: activeColor,
                      displayVal: "${_sparkSpeed.toStringAsFixed(1)}x",
                      onChanged: (v) => update(() => _sparkSpeed = v),
                    ),
                    const Divider(height: 28),
                    _buildSectionHeader(
                      "3. Thumb & Track Geometry",
                      Icons.tune,
                      Colors.amberAccent,
                    ),
                    _buildSliderDocTile(
                      title: "Thumb Thickness",
                      description:
                          "Thickness radius of the scrollbar thumb capsule.",
                      val: _thumbThickness,
                      min: 0.05,
                      max: 0.16,
                      activeColor: activeColor,
                      displayVal: "${(_thumbThickness * 100).toInt()}%",
                      onChanged: (v) => update(() => _thumbThickness = v),
                    ),
                    _buildDocTile(
                      title: "Grip Notches",
                      description:
                          "Tactile mechanical ridges carved into the thumb (0, 1, or 3 ridges).",
                      control: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 0, label: Text("0")),
                          ButtonSegment(value: 1, label: Text("1")),
                          ButtonSegment(value: 3, label: Text("3")),
                        ],
                        selected: {_gripNotches},
                        onSelectionChanged: (set) =>
                            update(() => _gripNotches = set.first),
                      ),
                    ),
                    _buildSwitchDocTile(
                      title: "Traveling Light Wave",
                      description:
                          "Animated traveling pulse along the body of the thumb.",
                      value: _enableWave,
                      activeColor: activeColor,
                      onChanged: (v) => update(() => _enableWave = v),
                    ),
                    _buildSwitchDocTile(
                      title: "Show Background Track",
                      description:
                          "Draws a recessed groove track behind the scrollbar path.",
                      value: _showTrack,
                      activeColor: activeColor,
                      onChanged: (v) => update(() => _showTrack = v),
                    ),
                    const Divider(height: 28),
                    _buildSectionHeader(
                      "4. Physics & Modes",
                      Icons.touch_app,
                      Colors.pinkAccent,
                    ),
                    _buildSwitchDocTile(
                      title: "Horizontal Mouse Wheel Translation",
                      description:
                          "Translates standard vertical mouse wheel input (dy) into horizontal movement.",
                      value: _enableHorizontalMouseWheel,
                      activeColor: activeColor,
                      onChanged: (v) =>
                          update(() => _enableHorizontalMouseWheel = v),
                    ),
                    _buildSwitchDocTile(
                      title: "Classic Canvas Mode",
                      description:
                          "Lightweight fallback renderer without GPU shader effects.",
                      value: _useClassic,
                      activeColor: activeColor,
                      onChanged: (v) => update(() => _useClassic = v),
                    ),
                    _buildDocTile(
                      title: "Alignment",
                      description:
                          "Positions the scrollbar along the selected border.",
                      control: DropdownButton<ScrollbarAlignment>(
                        value: _alignment,
                        underline: const SizedBox.shrink(),
                        items: ScrollbarAlignment.values.map((a) {
                          return DropdownMenuItem(
                            value: a,
                            child: Text(a.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (v) => update(() => _alignment = v!),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocTile({
    required String title,
    required String description,
    required Widget control,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF131724),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              control,
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderDocTile({
    required String title,
    required String description,
    required double val,
    required double min,
    required double max,
    required Color activeColor,
    required String displayVal,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF131724),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                displayVal,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: activeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              height: 1.3,
            ),
          ),
          Slider(
            value: val.clamp(min, max),
            min: min,
            max: max,
            activeColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchDocTile({
    required String title,
    required String description,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131724),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Switch(
                value: value,
                activeColor: activeColor,
                onChanged: onChanged,
              ),
            ],
          ),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
