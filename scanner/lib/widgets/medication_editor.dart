import 'package:flutter/material.dart';
import '../models/medication.dart';
import 'times_edit.dart';
import 'dart:developer' as developer;

class MedicationEditor extends StatefulWidget {
  final Medication medication;
  final VoidCallback onRemove;
  final ValueChanged<Medication> onChanged;
  final Function(String)? onScheduleUpdate; // Add this callback

  const MedicationEditor({
    super.key,
    required this.medication,
    required this.onRemove,
    required this.onChanged,
    this.onScheduleUpdate, // Add this parameter
  });

  @override
  State<MedicationEditor> createState() => _MedicationEditorState();
}

class _MedicationEditorState extends State<MedicationEditor> {
  late TextEditingController _quantityController;
  late TextEditingController _customUnitController;
  late TextEditingController _timesController;
  late TextEditingController _durationNumberController;
  TimeUnit? _durationUnit;
  final String _logTag = 'MedicationEditor';

  @override
  void initState() {
    super.initState();
    developer.log(
      'Initializing MedicationEditor for ${widget.medication.name}',
      name: _logTag,
    );

    _quantityController = TextEditingController(
      text: widget.medication.dosage.quantity.toString(),
    );
    _customUnitController = TextEditingController(
      text: widget.medication.dosage.customUnit ?? '',
    );
    _timesController = TextEditingController(
      text: _formatTimes(widget.medication.times),
    );
    _durationNumberController = TextEditingController(
      text: widget.medication.duration.number?.toString() ?? '',
    );
    _durationUnit = widget.medication.duration.unit;
  }

  String _formatTimes(List<AdministrationTime> times) {
    return times
        .map(
          (t) =>
              '${t.frequency}/${t.unit.name} at ${t.specificTimes.join(', ')}',
        )
        .join(', ');
  }

  void _updateDuration() {
    try {
      final number = int.tryParse(_durationNumberController.text);
      final duration =
          (_durationUnit == null || number == null)
              ? DurationPeriod.forever()
              : DurationPeriod(number: number, unit: _durationUnit);

      developer.log(
        'Updating duration for ${widget.medication.name}',
        name: _logTag,
      );

      final updatedMedication = widget.medication.copyWith(duration: duration);
      widget.onChanged(updatedMedication);

      // Trigger schedule update if this medication is part of a prescription
      if (widget.onScheduleUpdate != null) {
        developer.log(
          'Triggering schedule update for medication change',
          name: _logTag,
        );
        widget.onScheduleUpdate!(widget.medication.id);
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error updating duration: $e',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.medication.name,
              decoration: const InputDecoration(labelText: 'Medication Name'),
              onChanged: (value) {
                developer.log(
                  'Name changed for medication ${widget.medication.id}',
                  name: _logTag,
                );
                final updatedMedication = widget.medication.copyWith(
                  name: value,
                );
                widget.onChanged(updatedMedication);

                if (widget.onScheduleUpdate != null) {
                  widget.onScheduleUpdate!(widget.medication.id);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    onChanged: (value) {
                      try {
                        final quantity = double.tryParse(value) ?? 0;
                        developer.log(
                          'Dosage quantity changed for ${widget.medication.name}',
                          name: _logTag,
                        );

                        final updatedMedication = widget.medication.copyWith(
                          dosage: widget.medication.dosage.copyWith(
                            quantity: quantity,
                          ),
                        );
                        widget.onChanged(updatedMedication);
                      } catch (e, stackTrace) {
                        developer.log(
                          'Error updating quantity: $e',
                          name: _logTag,
                          error: e,
                          stackTrace: stackTrace,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<DosageUnit>(
                    value: widget.medication.dosage.unit,
                    items:
                        DosageUnit.values
                            .map(
                              (unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit.name),
                              ),
                            )
                            .toList(),
                    onChanged: (unit) {
                      if (unit != null) {
                        developer.log(
                          'Dosage unit changed to ${unit.name} for ${widget.medication.name}',
                          name: _logTag,
                        );

                        final updatedMedication = widget.medication.copyWith(
                          dosage: widget.medication.dosage.copyWith(unit: unit),
                        );
                        widget.onChanged(updatedMedication);

                        if (widget.onScheduleUpdate != null) {
                          widget.onScheduleUpdate!(widget.medication.id);
                        }
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Unit'),
                  ),
                ),
              ],
            ),
            if (widget.medication.dosage.unit == DosageUnit.other)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextFormField(
                  controller: _customUnitController,
                  decoration: const InputDecoration(labelText: 'Custom Unit'),
                  onChanged: (value) {
                    developer.log(
                      'Custom unit changed for ${widget.medication.name}',
                      name: _logTag,
                    );

                    final updatedMedication = widget.medication.copyWith(
                      dosage: widget.medication.dosage.copyWith(
                        customUnit: value,
                      ),
                    );
                    widget.onChanged(updatedMedication);
                  },
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _timesController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Dose Times',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editTimes,
                ),
              ),
              onTap: _editTimes,
            ),
            const SizedBox(height: 16),
            const Text('Duration'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'For'),
                    onChanged: (_) => _updateDuration(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<TimeUnit>(
                    value: _durationUnit,
                    items: [
                      ...TimeUnit.values.map(
                        (unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit.name),
                        ),
                      ),
                      const DropdownMenuItem<TimeUnit>(
                        value: null,
                        child: Text('Forever'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _durationUnit = value);
                      _updateDuration();
                    },
                    decoration: const InputDecoration(labelText: ''),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  developer.log(
                    'Removing medication ${widget.medication.name}',
                    name: _logTag,
                  );
                  if (widget.onScheduleUpdate != null) {
                    widget.onScheduleUpdate!(widget.medication.id);
                  }
                  widget.onRemove();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTimes() async {
    try {
      developer.log(
        'Editing times for ${widget.medication.name}',
        name: _logTag,
      );

      final result = await showDialog<List<AdministrationTime>>(
        context: context,
        builder:
            (context) =>
                TimeEditorDialog(initialTimes: widget.medication.times),
      );

      if (result != null) {
        developer.log(
          'Times updated for ${widget.medication.name}',
          name: _logTag,
        );

        final updatedMedication = widget.medication.copyWith(times: result);
        widget.onChanged(updatedMedication);
        _timesController.text = _formatTimes(result);

        if (widget.onScheduleUpdate != null) {
          developer.log(
            'Triggering schedule update for time change',
            name: _logTag,
          );
          widget.onScheduleUpdate!(widget.medication.id);
        }
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error editing times: $e',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void dispose() {
    developer.log(
      'Disposing MedicationEditor for ${widget.medication.name}',
      name: _logTag,
    );
    _quantityController.dispose();
    _customUnitController.dispose();
    _timesController.dispose();
    _durationNumberController.dispose();
    super.dispose();
  }
}
