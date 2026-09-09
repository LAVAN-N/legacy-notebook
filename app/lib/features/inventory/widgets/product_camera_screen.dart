import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Opens the custom product camera with real-time 16:9 viewfinder guide.
/// Returns the cropped file path on successful capture, or null on cancel.
Future<String?> openProductCamera(BuildContext context) async {
  try {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      return null;
    }
    if (!context.mounted) return null;
    return await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => ProductCameraScreen(cameras: cameras),
      ),
    );
  } catch (e) {
    debugPrint('Error accessing cameras: $e');
    return null;
  }
}

class ProductCameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const ProductCameraScreen({super.key, required this.cameras});

  @override
  State<ProductCameraScreen> createState() => _ProductCameraScreenState();
}

class _ProductCameraScreenState extends State<ProductCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.auto;
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _capturedImagePath;
  String? _errorMessage;

  static const double targetAspectRatio = 16 / 9;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Prefer back camera
    final backCameraIndex = widget.cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );
    _selectedCameraIndex = backCameraIndex != -1 ? backCameraIndex : 0;
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final camera = widget.cameras[_selectedCameraIndex];
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      await controller.setFlashMode(_flashMode);

      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Could not start camera: $e';
      });
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    FlashMode nextMode;
    switch (_flashMode) {
      case FlashMode.auto:
        nextMode = FlashMode.always;
        break;
      case FlashMode.always:
        nextMode = FlashMode.off;
        break;
      case FlashMode.off:
      default:
        nextMode = FlashMode.auto;
        break;
    }
    try {
      await _controller!.setFlashMode(nextMode);
      setState(() {
        _flashMode = nextMode;
      });
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (widget.cameras.length < 2) return;
    final nextIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
    setState(() {
      _selectedCameraIndex = nextIndex;
    });
    HapticFeedback.selectionClick();
    await _controller?.dispose();
    _controller = null;
    _initCamera();
  }

  Future<void> _takePhoto(Rect cutoutRect, Size screenSize) async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });
    HapticFeedback.mediumImpact();

    try {
      final XFile photo = await _controller!.takePicture();

      // Crop photo exactly matching the on-screen 16:9 cutout viewfinder
      final croppedPath = await _cropCameraImage(
        sourcePath: photo.path,
        cutoutRect: cutoutRect,
        screenSize: screenSize,
        previewAspectRatio: _controller!.value.aspectRatio,
      );

      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _capturedImagePath = croppedPath;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking picture: $e')),
      );
    }
  }

  Future<String> _cropCameraImage({
    required String sourcePath,
    required Rect cutoutRect,
    required Size screenSize,
    required double previewAspectRatio,
  }) async {
    String cleanPath = sourcePath;
    if (cleanPath.startsWith('file://')) {
      cleanPath = Uri.parse(cleanPath).toFilePath();
    }
    final bytes = await File(cleanPath).readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();

    // Camera controller aspect ratio is width/height (sensor orientation).
    // In portrait, the displayed preview ratio is 1 / previewAspectRatio.
    final double dispPreviewRatio = 1 / previewAspectRatio;
    final double screenRatio = screenSize.width / screenSize.height;

    double dispW, dispH, offX, offY;
    if (dispPreviewRatio > screenRatio) {
      dispH = screenSize.height;
      dispW = screenSize.height * dispPreviewRatio;
      offX = (screenSize.width - dispW) / 2;
      offY = 0;
    } else {
      dispW = screenSize.width;
      dispH = screenSize.width / dispPreviewRatio;
      offX = 0;
      offY = (screenSize.height - dispH) / 2;
    }

    final double relLeft = (cutoutRect.left - offX) / dispW;
    final double relTop = (cutoutRect.top - offY) / dispH;
    final double relW = cutoutRect.width / dispW;
    final double relH = cutoutRect.height / dispH;

    final double cropX = (relLeft * imgW).clamp(0.0, imgW - 10);
    final double cropY = (relTop * imgH).clamp(0.0, imgH - 10);
    final double cropW = (relW * imgW).clamp(10.0, imgW - cropX);
    final double cropH = (relH * imgH).clamp(10.0, imgH - cropY);

    // Output high quality 16:9 crop
    final outW = cropW.clamp(480.0, 1920.0).toInt();
    final outH = (outW / targetAspectRatio).toInt();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
    );

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(cropX, cropY, cropW, cropH),
      Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
      Paint()..filterQuality = FilterQuality.high,
    );

    final picture = recorder.endRecording();
    final croppedImage = await picture.toImage(outW, outH);
    final byteData =
        await croppedImage.toByteData(format: ui.ImageByteFormat.png);
    final croppedBytes = byteData!.buffer.asUint8List();

    final tempDir = Directory.systemTemp;
    final croppedPath =
        '${tempDir.path}/prod_cam_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(croppedPath).writeAsBytes(croppedBytes);

    return croppedPath;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenSize = MediaQuery.of(context).size;

    // Viewfinder 16:9 cutout geometry
    final cutoutWidth = (screenSize.width - 40).clamp(240.0, 420.0);
    final cutoutHeight = cutoutWidth / targetAspectRatio;
    final cutoutRect = Rect.fromCenter(
      center: Offset(screenSize.width / 2, screenSize.height * 0.45),
      width: cutoutWidth,
      height: cutoutHeight,
    );

    // If captured photo preview is active
    if (_capturedImagePath != null) {
      return _buildCapturedPreview(context, colors);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Live Camera Preview
            if (_controller != null && _controller!.value.isInitialized)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.previewSize!.height,
                    height: _controller!.value.previewSize!.width,
                    child: CameraPreview(_controller!),
                  ),
                ),
              )
            else if (_isInitializing)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.white70, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initCamera,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),

            // 16:9 Cutout Overlay & Framing Guides
            if (_controller != null && _controller!.value.isInitialized)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CameraCutoutPainter(
                      cutoutRect: cutoutRect,
                      colors: colors,
                    ),
                  ),
                ),
              ),

            // Top Bar Controls
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Row(
                    children: [
                      if (widget.cameras.length > 1)
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.black.withValues(alpha: 0.5),
                          ),
                          icon: const Icon(Icons.flip_camera_ios,
                              color: Colors.white),
                          onPressed: _switchCamera,
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.black.withValues(alpha: 0.5),
                        ),
                        icon: Icon(
                          _flashMode == FlashMode.auto
                              ? Icons.flash_auto
                              : (_flashMode == FlashMode.always
                                  ? Icons.flash_on
                                  : Icons.flash_off),
                          color: _flashMode == FlashMode.off
                              ? Colors.white54
                              : Colors.amber,
                        ),
                        onPressed: _toggleFlash,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // User Hint Tag below Cutout
            Positioned(
              top: cutoutRect.bottom + 16,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.crop_16_9, size: 16, color: colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Align product within 16:9 frame',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Shutter Controls
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _isCapturing
                      ? null
                      : () => _takePhoto(cutoutRect, screenSize),
                  child: Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isCapturing ? colors.primary : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: _isCapturing
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapturedPreview(BuildContext context, AppColors colors) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Cropped Image Display
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: AspectRatio(
                aspectRatio: targetAspectRatio,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white30, width: 2),
                    image: DecorationImage(
                      image: FileImage(File(_capturedImagePath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Action Bar
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 24,
            right: 24,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _capturedImagePath = null;
                      });
                    },
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('Retake'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(_capturedImagePath);
                    },
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Use Photo'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraCutoutPainter extends CustomPainter {
  final Rect cutoutRect;
  final AppColors colors;

  _CameraCutoutPainter({required this.cutoutRect, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black.withValues(alpha: 0.65);
    final backgroundPath =
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutRRect =
        RRect.fromRectAndRadius(cutoutRect, const Radius.circular(16));
    final cutoutPath = Path()..addRRect(cutoutRRect);
    final finalPath =
        Path.combine(PathOperation.difference, backgroundPath, cutoutPath);
    canvas.drawPath(finalPath, backgroundPaint);

    // Subtle 3x3 Grid Guidelines inside cutout
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final thirdW = cutoutRect.width / 3;
    final thirdH = cutoutRect.height / 3;

    // Vertical lines
    canvas.drawLine(
      Offset(cutoutRect.left + thirdW, cutoutRect.top),
      Offset(cutoutRect.left + thirdW, cutoutRect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cutoutRect.left + thirdW * 2, cutoutRect.top),
      Offset(cutoutRect.left + thirdW * 2, cutoutRect.bottom),
      gridPaint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(cutoutRect.left, cutoutRect.top + thirdH),
      Offset(cutoutRect.right, cutoutRect.top + thirdH),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cutoutRect.left, cutoutRect.top + thirdH * 2),
      Offset(cutoutRect.right, cutoutRect.top + thirdH * 2),
      gridPaint,
    );

    // Outer Border Frame
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(cutoutRRect, borderPaint);

    // Corner Accents (Thick primary color corners)
    final cornerPaint = Paint()
      ..color = colors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const cornerLen = 22.0;
    final r = cutoutRect;

    // Top-Left
    canvas.drawLine(
        Offset(r.left, r.top + cornerLen), Offset(r.left, r.top + 16), cornerPaint);
    canvas.drawLine(
        Offset(r.left + 16, r.top), Offset(r.left + cornerLen, r.top), cornerPaint);

    // Top-Right
    canvas.drawLine(Offset(r.right - cornerLen, r.top),
        Offset(r.right - 16, r.top), cornerPaint);
    canvas.drawLine(Offset(r.right, r.top + 16),
        Offset(r.right, r.top + cornerLen), cornerPaint);

    // Bottom-Left
    canvas.drawLine(Offset(r.left, r.bottom - cornerLen),
        Offset(r.left, r.bottom - 16), cornerPaint);
    canvas.drawLine(Offset(r.left + 16, r.bottom),
        Offset(r.left + cornerLen, r.bottom), cornerPaint);

    // Bottom-Right
    canvas.drawLine(Offset(r.right - cornerLen, r.bottom),
        Offset(r.right - 16, r.bottom), cornerPaint);
    canvas.drawLine(Offset(r.right, r.bottom - 16),
        Offset(r.right, r.bottom - cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
