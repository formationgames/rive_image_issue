import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'rive_animation_widget.dart';

/// The root widget for the application.
class VxAppWidget extends StatefulWidget {
  const VxAppWidget({super.key});

  @override
  createState() => _VxAppWidgetState();
}

class _VxAppWidgetState extends State<VxAppWidget> {
  // Create a cache of processed images by filepath
  final Map<String, (String key, RenderImage? image)> _images = {};

  @override
  build(context) {
    final images = _resolveImages({});
    return Padding(
      padding: EdgeInsets.all(80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: RiveAnimationWidget(
              src: '',
              data: {'Color': 5, 'Number': 99},
              artboard: 'Main Big',
              images: images,
            ),
          ),
          SizedBox(
            height: 100,
            width: 100,
            child: RiveAnimationWidget(
              src: '',
              data: {'Color': 4, 'Number': 99},
              artboard: 'Main Big',
              images: images,
            ),
          ),
          SizedBox(
            height: 100,
            width: 100,
            child: RiveAnimationWidget(
              src: '',
              data: {'Color': 3, 'Number': 99},
              artboard: 'Main Big',
              images: images,
            ),
          ),
          SizedBox(
            height: 100,
            width: 100,
            child: RiveAnimationWidget(
              src: '',
              data: {'Color': 2, 'Number': 99},
              artboard: 'Main Big',
              images: images,
            ),
          ),
          SizedBox(
            height: 100,
            width: 100,
            child: RiveAnimationWidget(
              src: '',
              data: {'Color': 1, 'Number': 99},
              artboard: 'Main Big',
              images: images,
            ),
          ),
          SizedBox(
            height: 100,
            width: 100,
            child: RiveAnimationWidget(
              src: '',
              data: {'Color': 0, 'Number': 99},
              artboard: 'Main Big',
              images: images,
            ),
          ),
        ],
      ),
    );
  }

  /// Resolve image data
  Map<String, RenderImage> _resolveImages(Map<String, dynamic> images) {
    // Process all images in the background
    _processImage('base', 'assets/animation/base.webp');
    _processImage('core', 'assets/animation/core.webp');
    _processImage('rare', 'assets/animation/rare.webp');
    _processImage('elite', 'assets/animation/elite.webp');
    _processImage('star', 'assets/animation/star.webp');
    _processImage('superstar', 'assets/animation/superstar.webp');

    // Transform the cache from filename keys back to the original keys
    return _images.entries.fold(<String, RenderImage>{}, (acc, entry) {
      if (entry.value.$2 == null) return acc;
      return acc..[entry.value.$1] = entry.value.$2!;
    });
  }

  /// Process image data asynchronously in the background
  void _processImage(String key, String filepath) {
    // Skip if already processed
    if (_images.containsKey(filepath)) return;

    // Create key to mark as processing
    _images[filepath] = (key, null);

    // Trigger background processing
    unawaited(
      Future(() async {
        try {
          // Load the raw data for the image resource
          final data = await rootBundle.load(filepath);

          // Decode into rives format
          final decoded = await Factory.rive.decodeImage(
            data.buffer.asUint8List(),
          );
          if (decoded == null) {
            return print('RIVE no decoded image data: $key');
          }

          // Store processed image in the cache
          _images[filepath] = (key, decoded);

          // Rebuild the component
          if (mounted) setState(() {});
        } catch (e) {
          // Log processing errors
          print('RIVE processImage: $key $e');
        }
      }),
    );
  }
}
