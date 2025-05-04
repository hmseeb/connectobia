import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A widget that displays an interactive product tour overlay
/// to demonstrate the swipe action for editing and deleting campaigns.
class ProductTourOverlay extends StatefulWidget {
  final bool forceShow;

  const ProductTourOverlay({
    super.key,
    this.forceShow = false,
  });

  @override
  State<ProductTourOverlay> createState() => _ProductTourOverlayState();

  /// Shows the product tour again by resetting the preference
  /// This can be called from anywhere in the app to show the tour
  static Future<void> showAgain() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_shown_product_tour', false);
  }
}

class _ProductTourOverlayState extends State<ProductTourOverlay>
    with SingleTickerProviderStateMixin {
  bool _showOverlay = true;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _handAnimation;
  int _currentStep = 0;

  final List<Map<String, dynamic>> _tourSteps = [
    {
      'title': 'Swipe to Access Actions',
      'description':
          'Swipe left on any campaign card to reveal edit and delete options.',
      'icon': Icons.swipe_left,
    },
    {
      'title': 'Edit Campaign',
      'description':
          'Tap the blue edit button to modify your campaign details.',
      'icon': Icons.edit,
      'color': Colors.blue.shade700,
    },
    {
      'title': 'Delete Campaign',
      'description': 'Tap the red delete button to remove a campaign.',
      'icon': Icons.delete,
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (!_showOverlay) return const SizedBox.shrink();

    return Stack(
      children: [
        // Semi-transparent background overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: _completeProductTour,
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),

        // Tooltip/instruction card
        Positioned(
          top: MediaQuery.of(context).size.height * 0.15,
          left: 20,
          right: 20,
          child: ShadCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      _tourSteps[_currentStep]['icon'],
                      color: _tourSteps[_currentStep]['color'] ??
                          Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _tourSteps[_currentStep]['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _completeProductTour,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _tourSteps[_currentStep]['description'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of ${_tourSteps.length}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    ShadButton(
                      onPressed: _nextStep,
                      child: Text(
                        _currentStep < _tourSteps.length - 1
                            ? 'Next'
                            : 'Got it',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Animation of card with swipe action
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: 20,
          right: 20,
          child: Column(
            children: [
              // Animated card showing the swipe interaction
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ShadCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Campaign Example',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Example campaign description to show how swiping works.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.attach_money,
                                size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text('PKR 50,000', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Hand icon demonstrating swipe
              Align(
                alignment: Alignment.centerRight,
                child: FadeTransition(
                  opacity: _handAnimation,
                  child: const Icon(
                    Icons.swipe,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(-0.3, 0.0),
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

    _handAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);

    if (!widget.forceShow) {
      _checkIfFirstTime();
    }
  }

  Future<void> _checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    // For testing purposes, you can reset the preference
    // await prefs.setBool('has_shown_product_tour', false);
    final hasShownTour = prefs.getBool('has_shown_product_tour') ?? false;

    if (hasShownTour) {
      setState(() {
        _showOverlay = false;
      });
    }
  }

  void _completeProductTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_shown_product_tour', true);

    setState(() {
      _showOverlay = false;
    });
  }

  void _nextStep() {
    setState(() {
      if (_currentStep < _tourSteps.length - 1) {
        _currentStep++;
      } else {
        _completeProductTour();
      }
    });
  }
}
