import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/prescription.dart';
import '../models/medication.dart';
import 'medication_editor.dart';

class PrescriptionEditorScreen extends StatefulWidget {
  final Prescription prescription;

  const PrescriptionEditorScreen({super.key, required this.prescription});

  @override
  State<PrescriptionEditorScreen> createState() =>
      _PrescriptionEditorScreenState();
}

class _PrescriptionEditorScreenState extends State<PrescriptionEditorScreen> {
  late Prescription _editablePrescription;

  @override
  void initState() {
    super.initState();
    _editablePrescription = widget.prescription.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Prescription'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePrescription,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPatientInfoSection(),
            const SizedBox(height: 20),
            _buildMedicationsSection(),
            const SizedBox(height: 20),
            _buildNotesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Patient Name',
                border: OutlineInputBorder(),
              ),
              initialValue: _editablePrescription.patientName,
              onChanged:
                  (value) => setState(
                    () =>
                        _editablePrescription = _editablePrescription.copyWith(
                          patientName: value,
                        ),
                  ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Doctor Name',
                border: OutlineInputBorder(),
              ),
              initialValue: _editablePrescription.doctorName,
              onChanged:
                  (value) => setState(
                    () =>
                        _editablePrescription = _editablePrescription.copyWith(
                          doctorName: value,
                        ),
                  ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_editablePrescription.date.toString().split(' ')[0]),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ..._editablePrescription.medications.map(
              (med) => MedicationEditor(
                medication: med,
                onRemove:
                    () => setState(() {
                      _editablePrescription.medications.remove(med);
                    }),
                onChanged:
                    (updatedMed) => setState(() {
                      final index = _editablePrescription.medications.indexOf(
                        med,
                      );
                      _editablePrescription.medications[index] = updatedMed;
                    }),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Medication'),
                onPressed:
                    () => setState(() {
                      _editablePrescription.medications.add(
                        Medication(
                          id: const Uuid().v4(),
                          name: 'New Medication',
                          dosage: Dosage(quantity: 1, unit: DosageUnit.tablet),
                          times: [
                            AdministrationTime(
                              frequency: 1,
                              unit: TimeUnit.day,
                              specificTimes: ['08:00'],
                            ),
                          ],
                          duration: DurationPeriod(
                            number: 7,
                            unit: TimeUnit.day,
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Additional notes...',
                border: OutlineInputBorder(),
              ),
              initialValue: _editablePrescription.notes,
              onChanged:
                  (value) => setState(
                    () =>
                        _editablePrescription = _editablePrescription.copyWith(
                          notes: value,
                        ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _editablePrescription.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _editablePrescription.date) {
      setState(() {
        _editablePrescription = _editablePrescription.copyWith(date: picked);
      });
    }
  }

  void _savePrescription() {
    if (_editablePrescription.patientName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter patient name')),
      );
      return;
    }

    Navigator.pop(context, _editablePrescription);
  }
}
