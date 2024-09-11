import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // untuk menyimpan file di perangkat

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  XFile? _imageFile; // Gambar yang diambil

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Inisialisasi kamera
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      final CameraDescription frontCamera = cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras![0]);
      _cameraController = CameraController(frontCamera, ResolutionPreset.low);

      // Mulai mengontrol kamera
      await _cameraController?.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  // Method untuk mengambil gambar
  Future<void> _takePicture() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        // Mengambil gambar
        XFile picture = await _cameraController!.takePicture();

        // Menyimpan file ke perangkat
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String filePath =
            '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await picture.saveTo(filePath);

        setState(() {
          _imageFile = XFile(filePath);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gambar berhasil diambil dan disimpan!')),
        );
      } catch (e) {
        print('Error saat mengambil gambar: $e');
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard with Camera'),
      ),
      body: _isCameraInitialized
          ? 
          Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // const SizedBox(height: 30),
                Container(
                  width: 200.0,
                  height: 300.0, // Atur tinggi tampilan kamera
                  child: AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _takePicture,
                  child: const Text('Take Picture'),
                ),
                const SizedBox(height: 20),
                _imageFile != null
                    ? Image.file(File(_imageFile!.path),
                        height: 200) // Tampilkan gambar yang diambil
                    : const Text('No image captured'),
              ],
            ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
