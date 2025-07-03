import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../services/hive_service.dart';
import '../models/prescription.dart';
import '../services/scanner_service.dart';
import 'prescription_list.dart';

class PrescriptionHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const PrescriptionHomePage({super.key, required this.cameras});

  @override
  _PrescriptionHomePageState createState() => _PrescriptionHomePageState();
}

class _PrescriptionHomePageState extends State<PrescriptionHomePage> {
  final _scanner = MLKitPrescriptionScanner();
  final _parser = PrescriptionParser();
  final _imagePicker = ImagePicker();

  List<Prescription> _prescriptions = [];
  bool _isLoading = false;

  Future<void> _scanFromCamera() async {
    setState(() => _isLoading = true);
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await _processImage(image.path);
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _scanFromGallery() async {
    setState(() => _isLoading = true);
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processImage(image.path);
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processImage(String imagePath) async {
    try {
      final text = await _scanner.scanImage(imagePath);
      if (text != null && text.isNotEmpty) {
        final prescription = _parser.parseFromText(text, imagePath);
        await HiveService.savePrescription(prescription);
        setState(() {
          _prescriptions.add(prescription);
        });
      } else {
        _showError('No text could be extracted from the image');
      }
    } catch (e) {
      _showError('Error processing image: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Scanner'),
        actions: [
          if (_prescriptions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.list),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PrescriptionListScreen(
                            initialPrescriptions: _prescriptions,
                          ),
                    ),
                  ),
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildScannerUI(),
      floatingActionButton:
          _isLoading
              ? null
              : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'camera',
                    onPressed: _scanFromCamera,
                    tooltip: 'Scan from Camera',
                    child: const Icon(Icons.camera_alt),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: 'gallery',
                    onPressed: _scanFromGallery,
                    tooltip: 'Scan from Gallery',
                    child: const Icon(Icons.photo_library),
                  ),
                ],
              ),
    );
  }

  Widget _buildScannerUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.medical_services, size: 100, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'Prescription Scanner',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Scan a prescription to extract medication information',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          if (_prescriptions.isNotEmpty) ...[
            const SizedBox(height: 30),
            Text(
              '${_prescriptions.length} prescription(s) scanned',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
}
