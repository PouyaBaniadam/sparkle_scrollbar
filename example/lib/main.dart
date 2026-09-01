import 'dart:ui';
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
        scaffoldBackgroundColor:
            const Color(0xFF050609), // Ultra deep space dark
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
  double _hue = 210.0;
  final double _saturation = 1.0;
  final double _lightness = 0.55;

  // Orientation & Tooltip state
  bool _isHorizontal = false;
  bool _showPercentageTooltip = true;

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

  // Reusable wrapper to apply the exact same SparkleScrollbar configuration
  // to both the Main View and the BottomSheet.
  Widget _buildSparkleWrapper({
    required Widget child,
    required Axis orientation,
    required ScrollbarAlignment alignment,
  }) {
    return SparkleScrollbar(
      orientation: orientation,
      alignment: alignment,
      renderMode: _useClassic
          ? ScrollbarRenderMode.classic
          : ScrollbarRenderMode.shader,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      thumbConfig: ThumbConfig(
        thickness: _thumbThickness,
        color: _currentExactColor,
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
        color: _currentExactColor,
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
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _currentExactColor;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Main Scrollable Content wrapped in the Sparkle Wrapper
          Positioned.fill(
            child: _buildSparkleWrapper(
              orientation: _isHorizontal ? Axis.horizontal : Axis.vertical,
              alignment: _alignment,
              child: ListView.builder(
                scrollDirection:
                    _isHorizontal ? Axis.horizontal : Axis.vertical,
                itemCount: 80,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
                itemBuilder: (context, index) => Container(
                  width: _isHorizontal ? 280 : null,
                  margin: EdgeInsets.only(
                    bottom: _isHorizontal ? 0 : 16,
                    right: _isHorizontal ? 16 : 0,
                  ),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0E14),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: activeColor.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _isHorizontal
                              ? Icons.horizontal_distribute_rounded
                              : Icons.layers_rounded,
                          color: activeColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Cosmic Block ${index + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Interact to trigger particles",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Floating App Bar (Glassmorphism Effect)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    bottom: 20,
                    left: 24,
                    right: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF050609).withValues(alpha: 0.9),
                        const Color(0xFF050609).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.blur_on_rounded,
                              color: activeColor, size: 32),
                          const SizedBox(width: 12),
                          const Text(
                            "Sparkle UI",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: activeColor.withValues(alpha: 0.15),
                          foregroundColor: activeColor,
                          padding: const EdgeInsets.all(12),
                        ),
                        icon: const Icon(Icons.tune_rounded),
                        onPressed: () => _openInspector(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openInspector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            // Helper function to update both the sheet and the main view
            void update(VoidCallback fn) {
              setSheetState(fn);
              setState(fn);
            }

            final activeColor = _currentExactColor;

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (ctx, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0C10),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border(
                      top: BorderSide(
                          color: activeColor.withValues(alpha: 0.3), width: 2),
                    ),
                  ),
                  // Applying Sparkle Scrollbar to the Settings Menu
                  child: _buildSparkleWrapper(
                    orientation: Axis.vertical,
                    alignment: ScrollbarAlignment.right,
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Text(
                          "Studio Settings",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: activeColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Fine-tune every GPU shader and physics aspect.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 32),

                        _buildSectionHeader("1. GENERAL & COLOR", Icons.palette,
                            Colors.greenAccent),
                        // Advanced Hue Selection Tile inside Settings
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13151D),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Accent Hue",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: activeColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: activeColor.withValues(
                                              alpha: 0.8),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Slide to completely change the app aesthetic.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
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
                                    trackHeight: 12,
                                    activeTrackColor: Colors.transparent,
                                    inactiveTrackColor: Colors.transparent,
                                    thumbColor: Colors.white,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8,
                                      elevation: 4,
                                    ),
                                    overlayColor:
                                        Colors.white.withValues(alpha: 0.2),
                                  ),
                                  child: Slider(
                                    min: 0.0,
                                    max: 360.0,
                                    value: _hue,
                                    onChanged: (v) => update(() => _hue = v),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildSwitchDocTile(
                          title: "Horizontal Main Axis",
                          description:
                              "Switch the main view to scroll horizontally.",
                          value: _isHorizontal,
                          activeColor: activeColor,
                          onChanged: (v) => update(() {
                            _isHorizontal = v;
                            _alignment = v
                                ? ScrollbarAlignment.bottom
                                : ScrollbarAlignment.right;
                          }),
                        ),

                        const SizedBox(height: 32),
                        _buildSectionHeader("2. TOOLTIPS",
                            Icons.chat_bubble_outline, Colors.cyanAccent),
                        _buildSwitchDocTile(
                          title: "Show Percentage Bubble",
                          description:
                              "Enables or disables the floating percentage indicator.",
                          value: _showPercentageTooltip,
                          activeColor: activeColor,
                          onChanged: (v) =>
                              update(() => _showPercentageTooltip = v),
                        ),

                        const SizedBox(height: 32),
                        _buildSectionHeader("3. PARTICLES", Icons.auto_awesome,
                            Colors.purpleAccent),
                        _buildDocTile(
                          title: "Particle Shape",
                          description:
                              "GLSL mathematical geometry rendering shapes.",
                          control: DropdownButton<ParticleShape>(
                            value: _shape,
                            dropdownColor: const Color(0xFF13151D),
                            borderRadius: BorderRadius.circular(16),
                            underline: const SizedBox.shrink(),
                            icon: Icon(Icons.keyboard_arrow_down,
                                color: activeColor),
                            items: ParticleShape.values.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s.name.toUpperCase(),
                                  style: TextStyle(
                                      color: activeColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => update(() => _shape = v!),
                          ),
                        ),
                        _buildSliderDocTile(
                          title: "Particle Count",
                          description:
                              "Number of sparks emitting from the thumb.",
                          val: _particleCount.toDouble(),
                          min: 0,
                          max: 50,
                          activeColor: activeColor,
                          displayVal: "$_particleCount",
                          onChanged: (v) =>
                              update(() => _particleCount = v.round()),
                        ),
                        _buildSliderDocTile(
                          title: "Particle Size",
                          description: "Diameter scale of the sparks and aura.",
                          val: _particleSize,
                          min: 0.02,
                          max: 0.14,
                          activeColor: activeColor,
                          displayVal: "${(_particleSize * 100).toInt()}%",
                          onChanged: (v) => update(() => _particleSize = v),
                        ),
                        _buildSliderDocTile(
                          title: "Emission Speed",
                          description: "Speed multiplier launching particles.",
                          val: _sparkSpeed,
                          min: 0.5,
                          max: 3.0,
                          activeColor: activeColor,
                          displayVal: "${_sparkSpeed.toStringAsFixed(1)}x",
                          onChanged: (v) => update(() => _sparkSpeed = v),
                        ),

                        const SizedBox(height: 32),
                        _buildSectionHeader("4. GEOMETRY", Icons.architecture,
                            Colors.amberAccent),
                        _buildSliderDocTile(
                          title: "Thumb Thickness",
                          description:
                              "Thickness radius of the scrollbar thumb.",
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
                              "Tactile mechanical ridges carved into the thumb.",
                          control: SegmentedButton<int>(
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor:
                                  activeColor.withValues(alpha: 0.2),
                              selectedForegroundColor: activeColor,
                            ),
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
                              "Animated pulse along the body of the thumb.",
                          value: _enableWave,
                          activeColor: activeColor,
                          onChanged: (v) => update(() => _enableWave = v),
                        ),
                        _buildSwitchDocTile(
                          title: "Show Track",
                          description: "Draws a recessed groove track behind.",
                          value: _showTrack,
                          activeColor: activeColor,
                          onChanged: (v) => update(() => _showTrack = v),
                        ),

                        const SizedBox(height: 32),
                        _buildSectionHeader("5. SYSTEM",
                            Icons.settings_system_daydream, Colors.pinkAccent),
                        _buildSwitchDocTile(
                          title: "Horiz. Mouse Wheel",
                          description:
                              "Translates standard vertical mouse wheel.",
                          value: _enableHorizontalMouseWheel,
                          activeColor: activeColor,
                          onChanged: (v) =>
                              update(() => _enableHorizontalMouseWheel = v),
                        ),
                        _buildSwitchDocTile(
                          title: "Classic Canvas Mode",
                          description:
                              "Lightweight fallback without GPU shader.",
                          value: _useClassic,
                          activeColor: activeColor,
                          onChanged: (v) => update(() => _useClassic = v),
                        ),
                        _buildDocTile(
                          title: "Alignment",
                          description: "Positions the scrollbar along borders.",
                          control: DropdownButton<ScrollbarAlignment>(
                            value: _alignment,
                            dropdownColor: const Color(0xFF13151D),
                            borderRadius: BorderRadius.circular(16),
                            underline: const SizedBox.shrink(),
                            icon: Icon(Icons.keyboard_arrow_down,
                                color: activeColor),
                            items: ScrollbarAlignment.values.map((a) {
                              return DropdownMenuItem(
                                value: a,
                                child: Text(
                                  a.name.toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => update(() => _alignment = v!),
                          ),
                        ),
                      ],
                    ),
                  ),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1.5,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF13151D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              control,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.4),
              height: 1.5,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF13151D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                displayVal,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: activeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.4),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: val.clamp(min, max),
              min: min,
              max: max,
              activeColor: activeColor,
              inactiveColor: activeColor.withValues(alpha: 0.2),
              onChanged: onChanged,
            ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF13151D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Switch(
                value: value,
                activeColor: activeColor,
                onChanged: onChanged,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.4),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
