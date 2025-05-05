import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as ui;
import 'package:path_provider/path_provider.dart';

class WatermarkImage {
  static Future<File> addWaterMarkToPhoto({
    required File image,
    required String waterMarkText,
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

    //DateTime & Time format
    var now = DateTime.now();
    var format =
        "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}";

    // Watermark text based on showDateTime value
    String waterMarkedText =
        showDateTime ? "$waterMarkText $format" : waterMarkText;

    // Create a copy of the original image for watermarking
    ui.Image watermarkedImageData = ui.copyResize(
      originalImage,
      width: originalImage.width,
      height: originalImage.height,
    );

    // Calculate center position
    final font = ui.arial48;
    final textWidth = waterMarkedText.length * 15; // Approximate width
    final x = (watermarkedImageData.width - textWidth) ~/ 2;
    final y = watermarkedImageData.height ~/ 2;

    // Apply semi-transparent watermark
    ui.drawString(
      watermarkedImageData,
      waterMarkedText,
      font: font,
      x: x,
      y: y,
      color: ui.ColorUint8.rgba(
        255,
        255,
        255,
        (255 * opacity).toInt(),
      ),
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
