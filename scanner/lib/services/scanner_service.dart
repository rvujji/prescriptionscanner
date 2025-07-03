import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/prescription.dart';
import '../models/medication.dart';

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
  Prescription parseFromText(String text, String imagePath) {
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
        medications.add(_parseMedicationLine(line));
      }
    }

    return Prescription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      patientName: patientName.isNotEmpty ? patientName : 'Unknown Patient',
      doctorName: doctorName.isNotEmpty ? doctorName : 'Unknown Doctor',
      medications: medications,
      notes: 'Automatically scanned prescription',
      imagePath: imagePath, // Image path can be set later if needed
    );
  }

  Medication _parseMedicationLine(String line) {
    final parts = line.split(RegExp(r'\s+'));
    final name = parts.isNotEmpty ? parts[0] : 'Unknown';

    // Parse dosage (default to 1 tablet if not specified)
    final dosage = _parseDosage(parts.length > 1 ? parts[1] : '1 tablet');

    // Parse times (default to 1x/day if not specified)
    final times = _parseTimes(parts.length > 2 ? parts[2] : '1x/day');

    // Parse duration (default to 7 days if not specified)
    final duration = parts.length > 3 ? parts[3] : '7 days';

    return Medication(
      name: name,
      dosage: dosage,
      times: times,
      duration: duration,
    );
  }

  Dosage _parseDosage(String dosageText) {
    try {
      // Handle cases like "200mg", "500mg", "1 tablet"
      final regex = RegExp(
        r'^(\d+)(mg|ml|g|tablet|cap|drop|puff)s?$',
        caseSensitive: false,
      );
      final match = regex.firstMatch(dosageText);

      if (match != null) {
        final quantity = double.parse(match.group(1)!);
        final unit = match.group(2)!.toLowerCase();

        return Dosage(
          quantity: quantity,
          unit: _parseDosageUnit(unit),
          customUnit: unit == 'other' ? dosageText : null,
        );
      }

      // If no match, try to split quantity and unit
      final split = dosageText.split(RegExp(r'(?<=\d)(?=\D)'));
      if (split.length == 2) {
        return Dosage(
          quantity: double.parse(split[0]),
          unit: _parseDosageUnit(split[1]),
          customUnit: null,
        );
      }
    } catch (e) {
      print('Error parsing dosage: $e');
    }

    // Default fallback
    return Dosage(quantity: 1, unit: DosageUnit.tablet, customUnit: dosageText);
  }

  DosageUnit _parseDosageUnit(String unit) {
    switch (unit.toLowerCase()) {
      case 'mg':
        return DosageUnit.milligram;
      case 'g':
        return DosageUnit.gram;
      case 'ml':
        return DosageUnit.milliliter;
      case 'l':
        return DosageUnit.liter;
      case 'drop':
        return DosageUnit.drop;
      case 'tablet':
        return DosageUnit.tablet;
      case 'cap':
        return DosageUnit.capsule;
      case 'puff':
        return DosageUnit.puff;
      default:
        return DosageUnit.other;
    }
  }

  List<AdministrationTime> _parseTimes(String timesText) {
    try {
      // Handle formats like "2x/day", "3 times weekly", "1 daily at 8AM, 2PM"
      final times = <AdministrationTime>[];
      final segments = timesText.split(RegExp(r'[,;]')).map((s) => s.trim());

      for (var segment in segments) {
        // Parse frequency and unit
        final freqMatch = RegExp(
          r'^(\d+)\s*(x|times)?\s*[/]?\s*(hour|day|week|month)',
        ).firstMatch(segment.toLowerCase());
        // Parse specific times if any
        final timeMatch = RegExp(
          r'at\s+([\d\sAPMapm,]+)$',
        ).firstMatch(segment.toLowerCase());

        if (freqMatch != null) {
          times.add(
            AdministrationTime(
              frequency: int.parse(freqMatch.group(1)!),
              unit: _parseTimeUnit(freqMatch.group(3)!),
              specificTimes: timeMatch?.group(1)?.trim(),
            ),
          );
        } else {
          // Fallback for simple formats
          times.add(
            AdministrationTime(
              frequency: 1,
              unit: TimeUnit.day,
              specificTimes:
                  segment.contains('at')
                      ? segment.split('at').last.trim()
                      : null,
            ),
          );
        }
      }

      return times;
    } catch (e) {
      print('Error parsing times: $e');
      return [AdministrationTime(frequency: 1, unit: TimeUnit.day)];
    }
  }

  TimeUnit _parseTimeUnit(String unit) {
    switch (unit.toLowerCase()) {
      case 'hour':
        return TimeUnit.hour;
      case 'day':
        return TimeUnit.day;
      case 'week':
        return TimeUnit.week;
      case 'month':
        return TimeUnit.month;
      default:
        return TimeUnit.day;
    }
  }
}
