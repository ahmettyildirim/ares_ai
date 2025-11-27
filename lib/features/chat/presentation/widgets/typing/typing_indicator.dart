import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _dotAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _dotAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // 🔥 ÇOK ÖNEMLİ: animasyon mutlaka durmalı
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotAnimation,
      builder: (context, child) {
        int dots = _dotAnimation.value.floor() % 3 + 1;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            '${"chat_ares_typing".tr()}${'.' * dots}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      },
    );
  }
}
