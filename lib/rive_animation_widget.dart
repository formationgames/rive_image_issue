import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class RiveAnimationWidget extends StatefulWidget {
  const RiveAnimationWidget({
    required this.src,
    this.artboard,
    this.data = const {},
    this.images = const {},
    super.key,
  });

  final String src;
  final String? artboard;
  final Map<String, dynamic> data;
  final Map<String, RenderImage> images;

  @override
  createState() => _RiveAnimationWidget();
}

class _RiveAnimationWidget extends State<RiveAnimationWidget> {
  /// The rive resource loaded from disk with fonts and images injected
  File? _file;

  /// The rive animation controller
  RiveWidgetController? _controller;

  /// View model instance to update and dispose
  ViewModelInstance? _model;

  // Has initialisation been started
  bool _init = false;

  /// Supported font names
  static const _fonts = [
    'fieldgothic-no27',
    'fieldgothic-no37',
    'fieldgothic-no52',
    'fieldgothic-no54',
  ];

  @override
  didUpdateWidget(prev) {
    // Sync all incoming args with the rive view models
    _syncModels();

    super.didUpdateWidget(prev);
  }

  @override
  dispose() {
    _file?.dispose();
    _controller?.dispose();
    _model?.dispose();
    super.dispose();
  }

  @override
  build(context) {
    try {
      // Load the file if it hasn't been loaded yet
      if (!_init) {
        _init = true;
        unawaited(_initRive());
      }

      // Wait for the file to load
      if (_controller == null) return SizedBox.shrink();

      // Return the animation
      return RiveWidget(controller: _controller!, fit: Fit.contain);
    } catch (e) {
      print('RIVE build: $e');
      return SizedBox.shrink();
    }
  }

  /// Load the rive file and initialise the controller
  Future<void> _initRive() async {
    // final filepath = widget.src.filepath;
    final filepath = 'assets/animation/card.riv';
    final artboard = widget.artboard;

    // Load the rive asset and hydrate all assets from resources
    _file ??= filepath.startsWith('assets/')
        ? await File.asset(
            filepath,
            riveFactory: Factory.rive,
            assetLoader: _loader,
          )
        : await File.path(
            filepath,
            riveFactory: Factory.rive,
            assetLoader: _loader,
          );

    // Initialise the controller with the file
    _controller ??= RiveWidgetController(
      _file!,
      artboardSelector: artboard == null || artboard.isEmpty
          ? const ArtboardDefault()
          : ArtboardSelector.byName(artboard),
    );

    // Create view model instance
    final vm = _file?.viewModelByName('Main');
    _model ??= vm?.createDefaultInstance();

    // Sync all incoming args with the rive view models
    _syncModels();

    // Rebuild the component
    if (mounted) setState(() {});
  }

  /// Load referenced assets from resources.
  bool _loader(FileAsset asset, Uint8List? bytes) => switch (asset) {
    FontAsset x => _setFont(x),
    _ => false,
  };

  /// Sync all incoming args with the rive view models
  void _syncModels() {
    // Sync all data properties with view models
    for (var entry in widget.data.entries) {
      // Set the property based on value type
      final type = entry.value.runtimeType;
      switch (entry.value) {
        case String x:
          final prop = _model?.string(entry.key);
          if (prop == null) {
            print('RIVE no property: $type');
            continue;
          }
          prop.value = x;
        case double x:
          final prop = _model?.number(entry.key);
          if (prop == null) {
            print('RIVE no property: $type');
            continue;
          }
          prop.value = x;
        case int x:
          final prop = _model?.number(entry.key);
          if (prop == null) {
            print('RIVE no property: $type');
            continue;
          }
          prop.value = x.toDouble();
        case bool x:
          final prop = _model?.boolean(entry.key);
          if (prop == null) {
            print('RIVE no property: $type');
            continue;
          }
          prop.value = x;
        default:
          print('RIVE no support for property type: $type');
      }
    }

    // Sync all image properties with view models
    for (var entry in widget.images.entries) {
      // final (model, nested, key) = _getViewModel(entry.key);
      // if (model == null || nested == null) continue;
      final prop = _model?.image(entry.key);
      if (prop == null) {
        print('RIVE no image prop: $prop');
        continue;
      }
      prop.value = entry.value;
    }

    // Bind the view model instances to the state machine
    _controller?.dataBind(DataBind.byInstance(_model!));
  }

  /// Load a font asset
  bool _setFont(FontAsset asset) {
    // Clean the font name
    final name = asset.name.replaceAll(' ', '');

    // Check if font is supported
    if (!_fonts.contains(name)) {
      print('RIVE font not supported: ${asset.name}');
      return false;
    }

    // Load the font data
    rootBundle.load('assets/font/$name.otf').then((data) async {
      if (mounted) {
        final list = data.buffer.asUint8List();

        // Decode the font data
        final font = await Factory.rive.decodeFont(list);
        if (font == null) return;

        // Set the font asset in rive
        asset.font(font);

        // Force rebuild in case the rive animation is no longer advancing
        setState(() {});
      }
    });

    // Tell the runtime not to load the asset automatically
    return true;
  }
}
