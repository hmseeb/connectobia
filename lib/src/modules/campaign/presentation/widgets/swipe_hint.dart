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
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  Widget build(BuildContext context) {
    if (!_showHint) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: (isDark ? Colors.blue.shade800 : Colors.blue.shade100)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (isDark ? Colors.blue.shade300 : Colors.blue.shade500)
                  .withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.swipe_left,
                size: 18,
                color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Swipe left on any campaign to see edit and delete options',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color,
                    height: 1.2,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 16,
                  color: theme.hintColor,
                ),
                constraints: const BoxConstraints(
                  maxHeight: 24,
                  maxWidth: 24,
                ),
                padding: EdgeInsets.zero,
                onPressed: _dismiss,
              ),
            ],
          ),
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
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _controller.forward();
    _checkIfFirstTime();

    // Auto-dismiss after 8 seconds
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  Future<void> _checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    // Reset hint for testing if needed
    // await prefs.setBool('has_shown_swipe_hint', false);

    final hasShownHint = prefs.getBool('has_shown_swipe_hint') ?? false;
    final hasShownTour = prefs.getBool('has_shown_product_tour') ?? false;

    // Don't show the hint if the full product tour has been shown
    // or if the hint has been shown before
    if (hasShownHint || hasShownTour) {
      setState(() {
        _showHint = false;
      });
    } else {
      // Save that we've shown the hint
      await prefs.setBool('has_shown_swipe_hint', true);
    }
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showHint = false;
        });
      }
    });
  }
}
