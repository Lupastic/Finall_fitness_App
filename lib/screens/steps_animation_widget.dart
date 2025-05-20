import 'package:flutter/material.dart';

class StepsAnimationWidget extends StatefulWidget {
  const StepsAnimationWidget({super.key});

  @override
  State<StepsAnimationWidget> createState() => _StepsAnimationWidgetState();
}

class _StepsAnimationWidgetState extends State<StepsAnimationWidget>
    with SingleTickerProviderStateMixin {
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

    _offset = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Center(
        child: SlideTransition(
          position: _offset,
          child: FadeTransition(
            opacity: _opacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_walk, size: 80, color: Colors.lightBlueAccent),
                const SizedBox(height: 16),
                Text("Вперёд к 70,000 шагам!",
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
