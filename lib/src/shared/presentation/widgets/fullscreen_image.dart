import 'package:flutter/material.dart';

/// A widget that displays an image in fullscreen mode with a dismiss button.
/// Supports zooming and panning through the InteractiveViewer.
class FullscreenImage extends StatelessWidget {
  /// The URL of the image to display
  final String imageUrl;

  /// Optional title to display at the top of the screen
  final String? title;

  /// Optional hero tag for smooth transitions
  final String? heroTag;

  /// Optional background color
  final Color backgroundColor;

  const FullscreenImage({
    super.key,
    required this.imageUrl,
    this.title,
    this.heroTag,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Interactive viewer for zooming and panning
          Center(
            child: heroTag != null
                ? Hero(
                    tag: heroTag!,
                    child: _buildInteractiveImage(context),
                  )
                : _buildInteractiveImage(context),
          ),

          // Title bar if title is provided
          if (title != null)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.black.withOpacity(0.5),
                child: Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveImage(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 40),
              const SizedBox(height: 16),
              Text(
                'Failed to load image',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
