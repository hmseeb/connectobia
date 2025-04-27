import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwipeHint extends StatefulWidget {
  const SwipeHint({super.key});

  @override
  State<SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<SwipeHint>
    with SingleTickerProviderStateMixin {
  bool _showHint = true;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  Widget build(BuildContext context) {
    if (!_showHint) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Swipe left to see actions',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close,
                  size: 14, color: Theme.of(context).hintColor),
              constraints: const BoxConstraints(maxHeight: 24, maxWidth: 24),
              padding: EdgeInsets.zero,
              onPressed: _dismiss,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0),
      end: const Offset(-0.15, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
    _checkIfFirstTime();

    // Auto-dismiss after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  Future<void> _checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    // Reset hint for new UI if needed
    // await prefs.setBool('has_shown_swipe_hint', false);
    final hasShownHint = prefs.getBool('has_shown_swipe_hint') ?? false;

    if (hasShownHint) {
      setState(() {
        _showHint = false;
      });
    } else {
      // Save that we've shown the hint
      await prefs.setBool('has_shown_swipe_hint', true);
    }
  }

  void _dismiss() {
    setState(() {
      _showHint = false;
    });
  }
}
