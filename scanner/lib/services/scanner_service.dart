import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/prescription.dart';

abstract class PrescriptionScanner {
  Future<String?> scanImage(String imagePath);
}

class MLKitPrescriptionScanner implements PrescriptionScanner {
  @override
  Future<String?> scanImage(String imagePath) async {
    final textRecognizer = TextRecognizer();
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      print('Error during OCR: $e');
      return null;
    } finally {
      textRecognizer.close();
    }
  }
}

class PrescriptionParser {
  Prescription parseFromText(String text) {
    final lines = text.split('\n');
    String patientName = '';
    String doctorName = '';
    final medications = <Medication>[];

    for (var line in lines) {
      if (line.toLowerCase().contains('patient')) {
        patientName = line.replaceAll('Patient:', '').trim();
      } else if (line.toLowerCase().contains('dr.')) {
        doctorName = line.trim();
      } else if (line.toLowerCase().contains('mg') ||
          line.toLowerCase().contains('ml') ||
          line.toLowerCase().contains('tablet')) {
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          medications.add(
            Medication(
              name: parts[0],
              dosage: parts[1],
              frequency: parts[2],
              duration: parts.length > 3 ? parts[3] : 'As directed',
            ),
          );
        }
      }
    }

    return Prescription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      patientName: patientName.isNotEmpty ? patientName : 'Unknown Patient',
      doctorName: doctorName.isNotEmpty ? doctorName : 'Unknown Doctor',
      medications: medications,
      notes: 'Automatically scanned prescription',
    );
  }
}
