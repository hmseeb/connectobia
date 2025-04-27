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

  @override
  Widget build(BuildContext context) {
    if (!_showHint) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'New feature: Swipe actions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: _dismiss,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Swipe left on a campaign to delete, or swipe right to access more actions',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.blue.withOpacity(0.7),
                      child: const Row(
                        children: [
                          Icon(Icons.menu, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('Actions',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.red.withOpacity(0.7),
                      child: const Row(
                        children: [
                          Text('Delete',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                          SizedBox(width: 4),
                          Icon(Icons.delete, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
      begin: const Offset(-0.2, 0),
      end: const Offset(0.2, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
    _checkIfFirstTime();
  }

  Future<void> _checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
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
