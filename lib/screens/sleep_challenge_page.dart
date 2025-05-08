import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SleepAnimationWidget extends StatefulWidget {
  const SleepAnimationWidget({super.key});

  @override
  State<SleepAnimationWidget> createState() => _SleepAnimationWidgetState();
}

class _SleepAnimationWidgetState extends State<SleepAnimationWidget>
    with SingleTickerProviderStateMixin {
  static const sleepDuration = Duration(minutes: 1);
  Duration remainingTime = sleepDuration;
  Timer? _timer;
  bool isRunning = false;
  final player = AudioPlayer();

  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _offset = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  void startTimer() {
    if (isRunning) return;
    setState(() => isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime -= const Duration(seconds: 1);
        } else {
          timer.cancel();
          isRunning = false;
          playAlarm();
        }
      });
    });
  }

  void playAlarm() async {
    await player.play(AssetSource('alarm.mp3'));
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: SlideTransition(
          position: _offset,
          child: FadeTransition(
            opacity: _opacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.nightlight_round, size: 80, color: Colors.tealAccent),
                const SizedBox(height: 16),
                const Text("Таймер сна", style: TextStyle(fontSize: 20, color: Colors.white)),
                const SizedBox(height: 10),
                Text(formatTime(remainingTime),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: startTimer,
                  child: const Text("Начать сон"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
