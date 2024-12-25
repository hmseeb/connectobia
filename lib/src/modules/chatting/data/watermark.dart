import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as ui;
import 'package:path_provider/path_provider.dart';

class WatermarkImage {
  static Future<File> addWaterMarkToPhoto({
    required File image,
    required String waterMarkText,
    bool showDateTime = false,
  }) async {
    File? watermarkedImage;

    // Decode image and return new image
    File fileName2 = File(image.path);
    ui.Image? originalImage = ui.decodeImage(fileName2.readAsBytesSync());

    //DateTime & Time format
    var now = DateTime.now();
    var format =
        "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}";

    // Watermark text based on showDateTime value
    String waterMarkedText =
        showDateTime ? "$waterMarkText $format" : waterMarkText;

    // Add watermark to image and specify the position
    ui.drawString(
      originalImage!,
      waterMarkedText,
      font: ui.arial48,
    );

    // Create temporary directory on storage
    var tempDir = await getTemporaryDirectory();

    // Generate random name
    Random random = Random();
    String randomFileName = random.nextInt(10).toString();

    // Store new image on filename
    File('${tempDir.path}/$randomFileName.png')
        .writeAsBytesSync(ui.encodePng(originalImage));

    // Set watermarked image from image path
    watermarkedImage = File('${tempDir.path}/$randomFileName.png');

    return watermarkedImage;
  }
}
