import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as ui;
import 'package:path_provider/path_provider.dart';

class WatermarkImage {
  static Future<File> addWaterMarkToPhoto({
    required File image,
    bool showDateTime = false,
    double opacity = 0.3, // Default low opacity
  }) async {
    File? watermarkedImage;

    // Decode image and return new image
    File fileName2 = File(image.path);
    ui.Image? originalImage = ui.decodeImage(fileName2.readAsBytesSync());
    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    // Load logo image from assets using Flutter's asset bundle
    final ByteData logoData = await rootBundle.load('assets/icons/logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    ui.Image? logoImage = ui.decodeImage(logoBytes);
    if (logoImage == null) {
      throw Exception('Failed to decode logo image');
    }

    // Resize logo to fit (e.g., 1/4 of the image width)
    int logoTargetWidth = (originalImage.width / 4).round();
    int logoTargetHeight =
        (logoImage.height * logoTargetWidth / logoImage.width).round();
    logoImage = ui.copyResize(logoImage,
        width: logoTargetWidth, height: logoTargetHeight);

    // Apply opacity to the logo image before compositing
    for (int yLogo = 0; yLogo < logoImage.height; yLogo++) {
      for (int xLogo = 0; xLogo < logoImage.width; xLogo++) {
        final pixel = logoImage.getPixel(xLogo, yLogo);
        final a = (pixel.a * opacity).toInt();
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        logoImage.setPixelRgba(xLogo, yLogo, r, g, b, a);
      }
    }

    // Create a copy of the original image for watermarking
    ui.Image watermarkedImageData = ui.copyResize(
      originalImage,
      width: originalImage.width,
      height: originalImage.height,
    );

    // Calculate center position for logo
    final x = (watermarkedImageData.width - logoImage.width) ~/ 2;
    final y = (watermarkedImageData.height - logoImage.height) ~/ 2;

    // Draw the logo with opacity using compositeImage
    ui.compositeImage(
      watermarkedImageData,
      logoImage,
      dstX: x,
      dstY: y,
      blend: ui.BlendMode.alpha,
    );

    // Create temporary directory on storage
    var tempDir = await getTemporaryDirectory();

    // Generate random name
    Random random = Random();
    String randomFileName = random.nextInt(10000).toString();

    // Store new image on filename
    File('${tempDir.path}/$randomFileName.png')
        .writeAsBytesSync(ui.encodePng(watermarkedImageData));

    // Set watermarked image from image path
    watermarkedImage = File('${tempDir.path}/$randomFileName.png');

    return watermarkedImage;
  }
}
