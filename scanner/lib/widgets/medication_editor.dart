import 'package:flutter/material.dart';
import '../models/medication.dart';

class MedicationEditor extends StatelessWidget {
  final Medication medication;
  final VoidCallback onRemove;
  final ValueChanged<Medication> onChanged;

  const MedicationEditor({
    super.key,
    required this.medication,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              initialValue: medication.name,
              decoration: const InputDecoration(labelText: 'Medication Name'),
              onChanged: (value) => onChanged(medication.copyWith(name: value)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: medication.dosage,
                    decoration: const InputDecoration(labelText: 'Dosage'),
                    onChanged:
                        (value) =>
                            onChanged(medication.copyWith(dosage: value)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: medication.frequency,
                    decoration: const InputDecoration(labelText: 'Frequency'),
                    onChanged:
                        (value) =>
                            onChanged(medication.copyWith(frequency: value)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: medication.duration,
              decoration: const InputDecoration(labelText: 'Duration'),
              onChanged:
                  (value) => onChanged(medication.copyWith(duration: value)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
