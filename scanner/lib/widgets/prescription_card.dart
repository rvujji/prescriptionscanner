import 'package:flutter/material.dart';
import '../models/prescription.dart';
import '../models/medication.dart';
import 'medication_editor.dart';
import 'image_preview.dart';

class PrescriptionCard extends StatefulWidget {
  final Prescription prescription;
  final Function(Prescription) onSave;
  final Function(Prescription) onDelete;

  const PrescriptionCard({
    super.key,
    required this.prescription,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<PrescriptionCard> createState() => _PrescriptionCardState();
}

class _PrescriptionCardState extends State<PrescriptionCard> {
  late Prescription _editablePrescription;
  bool _isExpanded = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _editablePrescription = widget.prescription.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: IconButton(
          icon: const Icon(Icons.image),
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
        ),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: _buildTrailing(),
        onExpansionChanged:
            (expanded) => setState(() => _isExpanded = expanded),
        children: [
          if (_isExpanded)
            ImagePreview(imagePath: _editablePrescription.imagePath),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return _isEditing
        ? TextFormField(
          initialValue: _editablePrescription.patientName,
          decoration: const InputDecoration(labelText: 'Patient Name'),
          onChanged: (value) {
            setState(() {
              _editablePrescription = _editablePrescription.copyWith(
                patientName: value,
              );
            });
          },
        )
        : Text(
          _editablePrescription.patientName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
  }

  Widget _buildSubtitle() {
    return _isEditing
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: _editablePrescription.doctorName,
              decoration: const InputDecoration(labelText: 'Doctor Name'),
              onChanged: (value) {
                setState(() {
                  _editablePrescription = _editablePrescription.copyWith(
                    doctorName: value,
                  );
                });
              },
            ),
            TextFormField(
              initialValue: _editablePrescription.date.toString().split(' ')[0],
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Date'),
              onTap: () => _selectDate(context),
            ),
          ],
        )
        : Text(
          'Dr. ${_editablePrescription.doctorName} • ${_editablePrescription.date.toString().split(' ')[0]}',
        );
  }

  Widget _buildTrailing() {
    return _isEditing
        ? IconButton(
          icon: const Icon(Icons.save, color: Colors.green),
          onPressed: _saveChanges,
        )
        : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${_editablePrescription.medications.length} meds'),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          ],
        );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing) ...[
            TextFormField(
              initialValue: _editablePrescription.notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
              onChanged: (value) {
                setState(() {
                  _editablePrescription = _editablePrescription.copyWith(
                    notes: value,
                  );
                });
              },
            ),
            const SizedBox(height: 16),
            _buildMedicationsEditor(),
          ] else ...[
            if (_editablePrescription.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Notes: ${_editablePrescription.notes}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            const Text(
              'Medications:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ..._editablePrescription.medications.map(
              (med) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.medication, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            med.format(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medications:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        ..._editablePrescription.medications.map(
          (med) => MedicationEditor(
            medication: med,
            onRemove:
                () => setState(() {
                  _editablePrescription.medications.remove(med);
                }),
            onChanged:
                (updatedMed) => setState(() {
                  final index = _editablePrescription.medications.indexOf(med);
                  _editablePrescription.medications[index] = updatedMed;
                }),
          ),
        ),
        TextButton(
          onPressed:
              () => setState(() {
                _editablePrescription.medications.add(
                  Medication(
                    name: 'New Medication',
                    dosage: Dosage(quantity: 1, unit: DosageUnit.tablet),
                    times: [
                      AdministrationTime(
                        frequency: 1,
                        unit: TimeUnit.day,
                        specificTimes: ['08:00'],
                      ),
                    ],
                    duration: DurationPeriod(number: 7, unit: TimeUnit.day),
                  ),
                );
              }),
          child: const Text('+ Add Medication'),
        ),
      ],
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

  void _saveChanges() {
    widget.onSave(_editablePrescription);
    setState(() => _isEditing = false);
  }
}
