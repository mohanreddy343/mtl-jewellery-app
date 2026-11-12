// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// /// First screen of the app. Shows the logo for ~2 seconds, then opens
// /// '/home' if the user is already logged in, otherwise '/login'.
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   static const _bg = Color(0xFFFFF8F2);
//   static const _plum = Color(0xFF5A1A2B);
//   static const _soft = Color(0xFF7A4A52);
//   static const _brand = 'Glow'; // change to your real app name
//   static const _tagline = 'YOUR SHADE, YOUR WAY';
//   static const _shades = [
//     Color(0xFFE8A0A0),
//     Color(0xFFD4766E),
//     Color(0xFFB3454F),
//     Color(0xFF8A2E3F),
//     Color(0xFF5A1A2B),
//   ];
//
//   late final AnimationController _controller;
//   late final Animation<double> _fade;
//   late final Animation<double> _scale;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//     _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
//     _scale = Tween<double>(begin: 0.8, end: 1).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
//     );
//     _controller.forward();
//     _goNext();
//   }
//
//   Future<void> _goNext() async {
//     await Future.delayed(const Duration(milliseconds: 2200));
//
//     bool loggedIn = false;
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       loggedIn = prefs.getBool('logged_in') ?? false;
//     } catch (_) {}
//
//     if (!mounted) return;
//     Navigator.pushReplacementNamed(context, loggedIn ? '/home' : '/login');
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bg,
//       body: SafeArea(
//         child: Center(
//           child: AnimatedBuilder(
//             animation: _controller,
//             builder: (context, _) {
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Wordmark
//                   Opacity(
//                     opacity: _fade.value,
//                     child: Transform.scale(
//                       scale: _scale.value,
//                       child: const Text(
//                         _brand,
//                         style: TextStyle(
//                           fontFamily: 'serif',
//                           fontSize: 56,
//                           fontWeight: FontWeight.w600,
//                           color: _plum,
//                           letterSpacing: 1,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 28),
//
//                   // Shade swatches, popping in one after another
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: List.generate(_shades.length, (i) {
//                       final start = 0.3 + i * 0.09;
//                       final t = Curves.easeOutBack.transform(
//                         ((_controller.value - start) / 0.3).clamp(0.0, 1.0),
//                       );
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 5),
//                         child: Opacity(
//                           opacity: t.clamp(0.0, 1.0),
//                           child: Transform.scale(
//                             scale: t,
//                             child: Container(
//                               width: 44,
//                               height: 44,
//                               decoration: BoxDecoration(
//                                 color: _shades[i],
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     }),
//                   ),
//                   const SizedBox(height: 28),
//
//                   // Tagline fades in last
//                   Opacity(
//                     opacity: ((_controller.value - 0.7) / 0.3).clamp(0.0, 1.0),
//                     child: const Text(
//                       _tagline,
//                       style: TextStyle(
//                         fontSize: 13,
//                         letterSpacing: 4,
//                         color: _soft,
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:math' as math;
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// /// First screen of the app. Plays a short animation (container truck tips over
// /// and cosmetics spill onto the road), shows the brand, then opens '/home' if
// /// the user is already logged in, otherwise '/login'.
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   static const _bg = Color(0xFFFFF8F2);
//   static const _plum = Color(0xFF5A1A2B);
//   static const _soft = Color(0xFF7A4A52);
//   static const _brand = 'Glow'; // change to your real app name
//   static const _tagline = 'YOUR SHADE, YOUR WAY';
//   static const _totalMs = 4600; // total animation length
//
//   late final AnimationController _controller;
//   late final List<_Product> _products;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: _totalMs),
//     );
//     _products = _Product.generate();
//     _controller.forward();
//     _goNext();
//   }
//
//   Future<void> _goNext() async {
//     await Future.delayed(const Duration(milliseconds: _totalMs + 500));
//
//     bool loggedIn = false;
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       loggedIn = prefs.getBool('logged_in') ?? false;
//     } catch (_) {}
//
//     if (!mounted) return;
//     Navigator.pushReplacementNamed(context, loggedIn ? '/home' : '/login');
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bg,
//       body: SafeArea(
//         child: Center(
//           child: AnimatedBuilder(
//             animation: _controller,
//             builder: (context, _) {
//               final t = _controller.value;
//               final brandT =
//               Curves.easeOut.transform(((t - 0.70) / 0.20).clamp(0.0, 1.0));
//               final tagT = ((t - 0.85) / 0.15).clamp(0.0, 1.0);
//
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Truck crash scene
//                   SizedBox(
//                     width: double.infinity,
//                     height: 280,
//                     child: CustomPaint(
//                       painter: _CrashPainter(
//                         t: t,
//                         totalSec: _totalMs / 1000,
//                         products: _products,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//
//                   // Wordmark
//                   Opacity(
//                     opacity: brandT,
//                     child: Transform.scale(
//                       scale: 0.85 + 0.15 * brandT,
//                       child: const Text(
//                         _brand,
//                         style: TextStyle(
//                           fontFamily: 'serif',
//                           fontSize: 56,
//                           fontWeight: FontWeight.w600,
//                           color: _plum,
//                           letterSpacing: 1,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//
//                   // Tagline
//                   Opacity(
//                     opacity: tagT,
//                     child: const Text(
//                       _tagline,
//                       style: TextStyle(
//                         fontSize: 13,
//                         letterSpacing: 4,
//                         color: _soft,
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Cosmetic product that falls out of the container
// // ─────────────────────────────────────────────────────────────────────────────
// class _Product {
//   final double spawn; // when it leaves the truck (0..1 of timeline)
//   final double vx; // horizontal speed (x scene height per second)
//   final double vy; // vertical speed  (x scene height per second)
//   final double rot; // start rotation
//   final double spin; // rotation speed (rad/s)
//   final int type; // 0 lipstick, 1 bottle, 2 compact, 3 tube
//   final Color color;
//
//   const _Product({
//     required this.spawn,
//     required this.vx,
//     required this.vy,
//     required this.rot,
//     required this.spin,
//     required this.type,
//     required this.color,
//   });
//
//   static List<_Product> generate() {
//     final r = math.Random(7);
//     const colors = [
//       Color(0xFFE8A0A0),
//       Color(0xFFD4766E),
//       Color(0xFFB3454F),
//       Color(0xFF8A2E3F),
//       Color(0xFF5A1A2B),
//     ];
//     return List.generate(16, (i) {
//       return _Product(
//         spawn: 0.34 + i * 0.018,
//         vx: -(0.15 + r.nextDouble() * 0.5),
//         vy: -0.3 + r.nextDouble() * 0.4,
//         rot: r.nextDouble() * math.pi * 2,
//         spin: -6 + r.nextDouble() * 12,
//         type: i % 4,
//         color: colors[r.nextInt(colors.length)],
//       );
//     });
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Painter: road, truck driving in, container tipping, products falling
// // ─────────────────────────────────────────────────────────────────────────────
// class _CrashPainter extends CustomPainter {
//   static const impact = 0.30; // moment the truck "crashes" (0..1)
//
//   final double t;
//   final double totalSec;
//   final List<_Product> products;
//
//   _CrashPainter({
//     required this.t,
//     required this.totalSec,
//     required this.products,
//   });
//
//   double _tiltAt(double tt) =>
//       0.45 * Curves.easeOutBack.transform(((tt - impact) / 0.25).clamp(0.0, 1.0));
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final w = size.width;
//     final h = size.height;
//     final roadY = h * 0.84;
//
//     canvas.save();
//
//     // Screen shake right after impact
//     final since = t - impact;
//     if (since > 0 && since < 0.08) {
//       canvas.translate(math.sin(t * 500) * 4 * (1 - since / 0.08), 0);
//     }
//
//     // Road
//     canvas.drawRect(
//       Rect.fromLTWH(0, roadY, w, h - roadY),
//       Paint()..color = const Color(0xFF4A3B3F),
//     );
//     final dash = Paint()
//       ..color = Colors.white70
//       ..strokeWidth = 3;
//     final dashY = roadY + (h - roadY) * 0.55;
//     for (double x = 0; x < w; x += 44) {
//       canvas.drawLine(Offset(x, dashY), Offset(x + 22, dashY), dash);
//     }
//
//     // Truck geometry
//     final truckW = w * 0.62;
//     final cabW = truckW * 0.26;
//     final boxW = truckW - cabW;
//     final wheelR = h * 0.065;
//     final chassisY = roadY - wheelR * 1.6;
//     final boxH = h * 0.42;
//     final cabH = h * 0.30;
//
//     final enter = Curves.easeOutCubic.transform((t / impact).clamp(0.0, 1.0));
//     final finalX = w * 0.30;
//     final truckX = -truckW + (finalX + truckW) * enter;
//     final boxLeft = truckX;
//     final boxRight = truckX + boxW;
//     final cabLeft = boxRight + 3;
//
//     // Chassis
//     canvas.drawRect(
//       Rect.fromLTWH(boxLeft, chassisY, truckW, wheelR * 0.5),
//       Paint()..color = const Color(0xFF2A1015),
//     );
//
//     // Cab
//     final cabRect = Rect.fromLTWH(cabLeft, chassisY - cabH, cabW, cabH);
//     canvas.drawRRect(
//       RRect.fromRectAndCorners(cabRect,
//           topRight: const Radius.circular(14),
//           topLeft: const Radius.circular(4)),
//       Paint()..color = const Color(0xFF5A1A2B),
//     );
//     canvas.drawRect(
//       Rect.fromLTWH(
//           cabLeft + cabW * 0.45, chassisY - cabH * 0.85, cabW * 0.45, cabH * 0.38),
//       Paint()..color = const Color(0xFFBFE3F0),
//     );
//     canvas.drawCircle(
//       Offset(cabLeft + cabW - 4, chassisY - cabH * 0.2),
//       3.5,
//       Paint()..color = const Color(0xFFFFD56B),
//     );
//
//     // Container (tips up at the rear after impact, pivot near the cab)
//     final tilt = _tiltAt(t);
//     canvas.save();
//     canvas.translate(boxRight, chassisY);
//     canvas.rotate(tilt);
//     final boxRect = Rect.fromLTWH(-boxW, -boxH, boxW, boxH);
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(boxRect, const Radius.circular(6)),
//       Paint()..color = const Color(0xFFB3454F),
//     );
//     canvas.drawRect(
//       Rect.fromLTWH(-boxW, -boxH * 0.30, boxW, boxH * 0.06),
//       Paint()..color = Colors.white24,
//     );
//     _text(canvas, 'GLOW', Offset(-boxW / 2, -boxH * 0.58), h * 0.095,
//         Colors.white);
//     if (tilt > 0.02) {
//       // open rear door
//       canvas.drawRect(
//         Rect.fromLTWH(-boxW, -boxH, boxW * 0.06, boxH),
//         Paint()..color = const Color(0xFF2A1015),
//       );
//     }
//     canvas.restore();
//
//     // Wheels
//     final wheelPaint = Paint()..color = Colors.black87;
//     final hubPaint = Paint()..color = Colors.grey.shade400;
//     final spoke = Paint()
//       ..color = Colors.grey.shade700
//       ..strokeWidth = 2;
//     final wheelXs = [
//       boxLeft + boxW * 0.20,
//       boxLeft + boxW * 0.38,
//       cabLeft + cabW * 0.5,
//     ];
//     final wheelAngle = enter * 14;
//     for (final wx in wheelXs) {
//       final c = Offset(wx, roadY - wheelR);
//       canvas.drawCircle(c, wheelR, wheelPaint);
//       canvas.drawCircle(c, wheelR * 0.45, hubPaint);
//       canvas.drawLine(
//         c,
//         c + Offset(math.cos(wheelAngle), math.sin(wheelAngle)) * wheelR * 0.45,
//         spoke,
//       );
//     }
//
//     // Dust cloud on impact
//     if (since > 0 && since < 0.15) {
//       final p = since / 0.15;
//       for (int k = 0; k < 3; k++) {
//         canvas.drawCircle(
//           Offset(cabLeft + cabW + k * wheelR * 0.9, roadY - wheelR * 0.5),
//           wheelR * (0.6 + p * 1.6 + k * 0.2),
//           Paint()..color = Colors.grey.withOpacity((1 - p) * 0.35),
//         );
//       }
//     }
//
//     // Falling products (simple gravity + bounce simulation)
//     final g = h * 5;
//     final s = h * 0.08;
//     for (final p in products) {
//       if (t < p.spawn) continue;
//
//       final ts = _tiltAt(p.spawn);
//       const a = 0.97;
//       final b = boxH * 0.2;
//       var x = boxRight + (-a * boxW * math.cos(ts) + b * math.sin(ts));
//       var y = chassisY + (-a * boxW * math.sin(ts) - b * math.cos(ts));
//       var vx = p.vx * h;
//       var vy = p.vy * h;
//       var rot = p.rot;
//       var spin = p.spin;
//
//       final steps = ((t - p.spawn) * totalSec * 60).floor();
//       const dt = 1 / 60;
//       final floorY = roadY - s * 0.5;
//       for (int i = 0; i < steps; i++) {
//         vy += g * dt;
//         x += vx * dt;
//         y += vy * dt;
//         rot += spin * dt;
//         if (y >= floorY) {
//           y = floorY;
//           vy = vy.abs() > h * 0.15 ? -vy * 0.4 : 0;
//           vx *= 0.82;
//           spin *= 0.8;
//         }
//       }
//       _drawProduct(canvas, p, Offset(x, y), rot, s);
//     }
//
//     canvas.restore();
//   }
//
//   void _drawProduct(Canvas canvas, _Product p, Offset pos, double rot, double s) {
//     canvas.save();
//     canvas.translate(pos.dx, pos.dy);
//     canvas.rotate(rot);
//     final color = Paint()..color = p.color;
//     final gold = Paint()..color = const Color(0xFFD9B46A);
//
//     switch (p.type) {
//       case 0: // lipstick
//         canvas.drawRRect(
//           RRect.fromRectAndRadius(
//               Rect.fromLTWH(-s * 0.25, -s * 0.1, s * 0.5, s * 0.6),
//               const Radius.circular(2)),
//           gold,
//         );
//         canvas.drawRRect(
//           RRect.fromRectAndRadius(
//               Rect.fromLTWH(-s * 0.2, -s * 0.6, s * 0.4, s * 0.5),
//               const Radius.circular(3)),
//           color,
//         );
//         break;
//       case 1: // bottle
//         canvas.drawRRect(
//           RRect.fromRectAndRadius(
//               Rect.fromCenter(center: Offset.zero, width: s * 0.6, height: s * 0.8),
//               const Radius.circular(4)),
//           color,
//         );
//         canvas.drawRect(
//           Rect.fromLTWH(-s * 0.15, -s * 0.7, s * 0.3, s * 0.3),
//           Paint()..color = Colors.black87,
//         );
//         break;
//       case 2: // compact
//         canvas.drawCircle(Offset.zero, s * 0.5, gold);
//         canvas.drawCircle(Offset.zero, s * 0.35, color);
//         break;
//       default: // tube
//         canvas.drawRRect(
//           RRect.fromRectAndRadius(
//               Rect.fromCenter(center: Offset.zero, width: s * 0.4, height: s),
//               const Radius.circular(3)),
//           color,
//         );
//         canvas.drawRect(
//           Rect.fromLTWH(-s * 0.15, -s * 0.6, s * 0.3, s * 0.15),
//           Paint()..color = Colors.white,
//         );
//     }
//     canvas.restore();
//   }
//
//   void _text(Canvas c, String s, Offset center, double fs, Color col) {
//     final tp = TextPainter(
//       text: TextSpan(
//         text: s,
//         style: TextStyle(
//           fontSize: fs,
//           fontWeight: FontWeight.w800,
//           letterSpacing: 2,
//           color: col,
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     )..layout();
//     tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
//   }
//
//   @override
//   bool shouldRepaint(covariant _CrashPainter old) => old.t != t;
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

/// Full-screen video splash. Plays assets/videos/splash.mp4 once, then opens
/// '/home' if the user is already logged in, otherwise '/login'.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _videoPath = 'assets/videos/splash.mp4';
  static const _volume = 1.0; // set to 0.0 for a silent splash

  late final VideoPlayerController _video;
  Timer? _failsafe;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _video = VideoPlayerController.asset(_videoPath);
    _init();
  }

  Future<void> _init() async {
    try {
      await _video.initialize();
      await _video.setVolume(_volume);
      await _video.setLooping(false);
      _video.addListener(_onVideoTick);
      if (!mounted) return;
      setState(() {});
      await _video.play();

      // Safety net: never get stuck on the splash.
      _failsafe = Timer(
        _video.value.duration + const Duration(seconds: 2),
        _goNext,
      );
    } catch (_) {
      // Video missing / failed to load -> just continue.
      _goNext();
    }
  }

  void _onVideoTick() {
    final v = _video.value;
    if (v.hasError) {
      _goNext();
      return;
    }
    if (v.isInitialized && v.duration > Duration.zero && v.position >= v.duration) {
      _goNext();
    }
  }

  Future<void> _goNext() async {
    if (_navigated) return;
    _navigated = true;
    _failsafe?.cancel();

    bool loggedIn = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      loggedIn = prefs.getBool('logged_in') ?? false;
    } catch (_) {}

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, loggedIn ? '/home' : '/login');
  }

  @override
  void dispose() {
    _failsafe?.cancel();
    _video.removeListener(_onVideoTick);
    _video.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = _video.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen video (cover = fills the screen, crops edges if needed)
          if (ready)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _video.value.size.width,
                height: _video.value.size.height,
                child: VideoPlayer(_video),
              ),
            ),

          // Skip button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton(
                  onPressed: _goNext,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black38,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Skip',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}