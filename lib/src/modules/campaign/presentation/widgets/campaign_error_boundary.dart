import 'package:flutter/material.dart';

/// A widget that catches errors in its child widget tree and displays a fallback UI
class CampaignErrorBoundary extends StatefulWidget {
  final Widget child;

  const CampaignErrorBoundary({
    super.key,
    required this.child,
  });

  @override
  State<CampaignErrorBoundary> createState() => _CampaignErrorBoundaryState();
}

class _CampaignErrorBoundaryState extends State<CampaignErrorBoundary> {
  bool _hasError = false;
  FlutterErrorDetails? _errorDetails;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Return fallback UI
      return Material(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'There was an error rendering this component.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorDetails = null;
                  });
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // No error, render the child widget
    return widget.child;
  }

  @override
  void dispose() {
    // Reset to default error handler
    FlutterError.onError = FlutterError.presentError;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Set custom error handler
    FlutterError.onError = _handleFlutterError;
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorDetails = details;
      });
    }
    // Log the error
    debugPrint('Error in CampaignErrorBoundary: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  }
}
