import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class WidgetToImage {
  static Future<Uint8List> takeScreenshot(Widget child) async {
    final screenshotController = ScreenshotController();
    return await screenshotController.captureFromWidget(Material(child: child),
        pixelRatio: 4.0);
  }

  static Future<bool> saveImage(Uint8List byte) async {
    final result = await ImageGallerySaver.saveImage(byte);
    return result['isSuccess'];
  }

  static Future<bool> shareImage(Uint8List byte) async {
    final directory = await getTemporaryDirectory();
    final imageFile = File('${directory.path}/image.png');
    await imageFile.writeAsBytes(byte, flush: true);
    ShareResult result = await Share.shareXFiles([XFile(imageFile.path)]);
    return result.status == ShareResultStatus.success;
  }
}
