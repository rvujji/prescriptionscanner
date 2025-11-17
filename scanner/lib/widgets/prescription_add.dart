import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import '../services/hive_service.dart';
import '../models/prescription.dart';
import '../models/appuser.dart';
import '../services/scanner_service.dart';
import 'prescription_manual.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

final Logger _logger = Logger('PrescriptionAddPage');

class PrescriptionAddPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const PrescriptionAddPage({super.key, required this.cameras});

  @override
  State<PrescriptionAddPage> createState() => _PrescriptionAddPageState();
}

class _PrescriptionAddPageState extends State<PrescriptionAddPage> {
  final _scanner = MLKitPrescriptionScanner();
  final _parser = PrescriptionParser();
  final _imagePicker = ImagePicker();
  final List<Prescription> _prescriptions = [];
  bool _isLoading = false;

  Future<void> _scanFromCamera() async {
    _logger.info('User initiated camera scan');
    setState(() => _isLoading = true);
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        _logger.info('Image captured from camera: ${image.path}');
        await _processImage(image.path);
      } else {
        _logger.warning('No image returned from camera');
      }
    } catch (e, stack) {
      _logger.severe('Camera capture failed: $e', e, stack);
      _showError('Failed to capture image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _requestGalleryPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        return true;
      }

      // Android 13+ needs READ_MEDIA_IMAGES
      if (await Permission.photos.isGranted) {
        return true;
      }

      final status = await Permission.photos.request();
      if (status.isPermanentlyDenied) {
        _showError('Please enable photo access in settings');
        await openAppSettings();
        return false;
      }
      return status.isGranted;
    } else {
      // iOS
      final status = await Permission.photos.request();
      if (status.isPermanentlyDenied || status.isRestricted) {
        _showError('Please enable photo access in Settings');
        await openAppSettings();
        return false;
      }
      return status.isGranted;
    }
  }

  Future<void> _scanFromGallery() async {
    _logger.info('User initiated gallery scan');
    try {
      // final permissionStatus = await _requestGalleryPermission();
      // if (!permissionStatus) {
      //   _logger.warning('Gallery permission not granted');
      //   return;
      // }
      setState(() => _isLoading = true);
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _logger.info('Image picked from gallery: ${image.path}');
        await _processImage(image.path);
      } else {
        _logger.warning('No image selected from gallery');
      }
    } catch (e, stack) {
      _logger.severe('Gallery image selection failed: $e', e, stack);
      _showError('Failed to pick image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processImage(String imagePath) async {
    _logger.info('Starting OCR + Parsing for: $imagePath');
    try {
      final text = await _scanner.scanImage(imagePath);
      if (text == null || text.isEmpty) {
        _logger.warning('OCR returned empty text');
        _showError('No text could be extracted from the image');
      }
      _logger.info('Text Parsing...');
      final prescription = _parser.parseFromText(text ?? '', imagePath);
      await HiveService.savePrescription(prescription);
      _logger.info('Prescription saved to Hive: ${prescription.id}');
      setState(() => _prescriptions.add(prescription));
      Navigator.pop(context, prescription);
    } catch (e, stack) {
      _logger.severe('Error processing image: $e', e, stack);
      _showError('Error processing image: $e');
    }
  }

  void _showError(String message) {
    _logger.warning('Showing error to user: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescription Scanner')),
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
                    heroTag: 'manual',
                    onPressed: _manualEntry,
                    tooltip: 'Add Manually',
                    child: const Icon(Icons.edit_note), 
                  ),
                  const SizedBox(height: 16),
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

  Future<void> _manualEntry() async {
    // Create a new empty prescription
    AppUser? loggedinUser = HiveService.getLoggedInUser();
    final newPrescription = Prescription(
      id: const Uuid().v4(),
      date: DateTime.now(),
      patientName: '',
      doctorName: '',
      medications: [],
      notes: '',
      imagePath: '',
      userId: loggedinUser?.id ?? '',
      isSynced: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Navigate to the editing screen
    final updatedPrescription = await Navigator.push<Prescription>(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                PrescriptionEditorScreen(prescription: newPrescription),
      ),
    );

    if (updatedPrescription != null) {
      try {
        setState(() => _isLoading = true);
        await HiveService.savePrescription(updatedPrescription);
        _logger.info('Manual prescription saved: ${updatedPrescription.id}');
        setState(() => _prescriptions.add(updatedPrescription));
        Navigator.pop(context, updatedPrescription);
      } catch (e, stack) {
        _logger.severe('Manual entry failed: $e', e, stack);
        _showError('Failed to save manual prescription: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
