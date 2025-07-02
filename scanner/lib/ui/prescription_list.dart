import 'package:flutter/material.dart';
import '../models/prescription.dart';
import 'image_viewer.dart';

class PrescriptionListScreen extends StatelessWidget {
  final List<Prescription> prescriptions;

  const PrescriptionListScreen({super.key, required this.prescriptions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanned Prescriptions')),
      body: ListView.builder(
        itemCount: prescriptions.length,
        itemBuilder: (context, index) {
          final prescription = prescriptions[index];
          return PrescriptionCard(prescription: prescription);
        },
      ),
    );
  }
}

class PrescriptionCard extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionCard({super.key, required this.prescription});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient: ${prescription.patientName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Doctor: ${prescription.doctorName}'),
            Text(
              'Date: ${prescription.date.toLocal().toString().split(' ')[0]}',
            ),
            const SizedBox(height: 16),
            const Text(
              'Medications:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...prescription.medications.map(
              (med) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  '- ${med.name} (${med.dosage}), ${med.frequency} for ${med.duration}',
                ),
              ),
            ),
            if (prescription.imagePath != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.image),
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ImageViewerScreen(
                                imagePath: prescription.imagePath!,
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
}
