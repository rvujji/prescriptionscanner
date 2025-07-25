// scanner/lib/services/scanner_service.dart
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:logging/logging.dart';
import 'hive_service.dart';
import '../models/prescription.dart';
import '../models/medication.dart';

final Logger _logger = Logger('PrescriptionParser');

abstract class PrescriptionScanner {
  Future<String?> scanImage(String imagePath);
}

class MLKitPrescriptionScanner implements PrescriptionScanner {
  @override
  Future<String?> scanImage(String imagePath) async {
    final textRecognizer = TextRecognizer();
    try {
      _logger.info('Starting OCR for image: $imagePath');
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);
      _logger.info(
        'OCR successful. Extracted text length: ${recognizedText.text.length}',
      );
      return recognizedText.text;
    } catch (e, stack) {
      _logger.severe('OCR failed for $imagePath: $e', e, stack);
      return null;
    } finally {
      textRecognizer.close();
      _logger.fine('TextRecognizer closed');
    }
  }
}

class PrescriptionParser {
  Prescription parseFromText(String text, String imagePath) {
    _logger.info('Parsing prescription from text (length: ${text.length})');
    final lines = text.split('\n');
    String patientName = '';
    String doctorName = '';
    final medications = <Medication>[];

    for (var line in lines) {
      _logger.fine('Processing line: $line');
      if (line.toLowerCase().contains('patient')) {
        patientName =
            line
                .replaceAll(RegExp(r'Patient\s*:?', caseSensitive: false), '')
                .trim();
        _logger.info('Detected patient name: $patientName');
      } else if (line.toLowerCase().contains('dr.')) {
        doctorName = line.trim();
        _logger.info('Detected doctor name: $doctorName');
      } else if (line.toLowerCase().contains('mg') ||
          line.toLowerCase().contains('ml') ||
          line.toLowerCase().contains('tablet')) {
        final med = _parseMedicationLine(line);
        medications.add(med);
        _logger.info('Parsed medication: ${med.name}');
      }
    }

    final prescription = Prescription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      patientName: patientName.isNotEmpty ? patientName : 'Unknown Patient',
      doctorName: doctorName.isNotEmpty ? doctorName : 'Unknown Doctor',
      medications: medications,
      notes: 'Automatically scanned prescription',
      imagePath: imagePath,
      userId: HiveService.getLoggedInUser()?.id ?? 'unknown',
      isSynced: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _logger.info(
      'Completed parsing prescription with ${medications.length} medications',
    );
    return prescription;
  }

  Medication _parseMedicationLine(String line) {
    _logger.fine('Parsing medication line: $line');
    final parts = line.split(RegExp(r'\s+'));
    final name = parts.isNotEmpty ? parts[0] : 'Unknown';

    final dosage = _parseDosage(parts.length > 1 ? parts[1] : '1 tablet');
    final times = _parseTimes(parts.length > 2 ? parts[2] : '1 per day');
    final duration = _parseDuration(parts.length > 3 ? parts[3] : '7 days');

    return Medication(
      name: name,
      dosage: dosage,
      times: times,
      duration: duration,
      frontImagePath: null,
      backImagePath: null,
      isSynced: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  DurationPeriod _parseDuration(String text) {
    try {
      final match = RegExp(
        r'(\d+)\s*(day|week|month|hour)s?',
        caseSensitive: false,
      ).firstMatch(text.toLowerCase());
      if (match != null) {
        final value = int.parse(match.group(1)!);
        final unit = _parseTimeUnit(match.group(2)!);
        _logger.fine('Parsed duration: $value ${unit.name}');
        return DurationPeriod(number: value, unit: unit);
      }
    } catch (e) {
      _logger.warning('Error parsing duration: $e');
    }

    _logger.warning('Using default duration: 7 days');
    return DurationPeriod(number: 7, unit: TimeUnit.day);
  }

  Dosage _parseDosage(String dosageText) {
    try {
      final regex = RegExp(
        r'^(\d+)(mg|ml|g|tablet|cap|drop|puff)s?$',
        caseSensitive: false,
      );
      final match = regex.firstMatch(dosageText);

      if (match != null) {
        final quantity = double.parse(match.group(1)!);
        final unit = match.group(2)!.toLowerCase();
        _logger.fine('Parsed dosage: $quantity $unit');
        return Dosage(
          quantity: quantity,
          unit: _parseDosageUnit(unit),
          customUnit: unit == 'other' ? dosageText : null,
        );
      }

      final split = dosageText.split(RegExp(r'(?<=\d)(?=\D)'));
      if (split.length == 2) {
        return Dosage(
          quantity: double.parse(split[0]),
          unit: _parseDosageUnit(split[1]),
          customUnit: null,
        );
      }
    } catch (e) {
      _logger.warning('Error parsing dosage "$dosageText": $e');
    }

    _logger.warning('Defaulting dosage for "$dosageText" to 1 tablet');
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
        _logger.warning('Unknown dosage unit: $unit');
        return DosageUnit.other;
    }
  }

  List<AdministrationTime> _parseTimes(String timesText) {
    final times = <AdministrationTime>[];
    final segments = timesText.split(RegExp(r'[,;]')).map((s) => s.trim());

    for (var segment in segments) {
      final freqMatch = RegExp(
        r'^(\d+)\s*(x|times)?\s*[/]?\s*(hour|day|week|month)',
      ).firstMatch(segment.toLowerCase());

      final timeMatch = RegExp(
        r'at\s+([\d:, ]+)',
        caseSensitive: false,
      ).firstMatch(segment);
      List<String> specificTimes = [];

      if (timeMatch != null) {
        specificTimes =
            timeMatch
                .group(1)!
                .split(RegExp(r'[,\s]+'))
                .where((t) => t.trim().isNotEmpty)
                .map((t) => _normalizeTimeTo24Hr(t.trim()))
                .toList();
      }

      if (freqMatch != null) {
        final at = AdministrationTime(
          frequency: int.parse(freqMatch.group(1)!),
          unit: _parseTimeUnit(freqMatch.group(3)!),
          specificTimes: specificTimes,
        );
        _logger.fine(
          'Parsed time segment: ${at.frequency}/${at.unit.name} at ${specificTimes.join(', ')}',
        );
        times.add(at);
      } else {
        _logger.warning('Unrecognized time format: "$segment"');
        times.add(
          AdministrationTime(
            frequency: 1,
            unit: TimeUnit.day,
            specificTimes: specificTimes,
          ),
        );
      }
    }

    return times;
  }

  String _normalizeTimeTo24Hr(String timeStr) {
    try {
      final format = RegExp(
        r'\d{1,2}(:\d{2})?\s*(am|pm)?',
        caseSensitive: false,
      );
      if (format.hasMatch(timeStr)) {
        final time = DateTime.parse("1970-01-01 ${_convertTo24Hr(timeStr)}:00");
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      _logger.warning('Failed to normalize time: "$timeStr" → $e');
    }
    return timeStr;
  }

  String _convertTo24Hr(String input) {
    final format = RegExp(
      r'(\d{1,2})(:(\d{2}))?\s*(am|pm)',
      caseSensitive: false,
    );
    final match = format.firstMatch(input.toLowerCase());
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = match.group(3) != null ? int.parse(match.group(3)!) : 0;
      final period = match.group(4);

      if (period == 'pm' && hour != 12) hour += 12;
      if (period == 'am' && hour == 12) hour = 0;

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    return input;
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
        _logger.warning('Unknown time unit: $unit');
        return TimeUnit.day;
    }
  }
}
