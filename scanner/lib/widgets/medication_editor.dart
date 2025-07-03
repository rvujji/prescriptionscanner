import 'package:flutter/material.dart';
import '../models/medication.dart';
import 'times_edit.dart';

class MedicationEditor extends StatefulWidget {
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
  State<MedicationEditor> createState() => _MedicationEditorState();
}

class _MedicationEditorState extends State<MedicationEditor> {
  late TextEditingController _quantityController;
  late TextEditingController _customUnitController;
  late TextEditingController _timesController;
  late TextEditingController _durationNumberController;
  TimeUnit? _durationUnit;

  @override
  void initState() {
    super.initState();
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
    final number = int.tryParse(_durationNumberController.text);
    final duration =
        (_durationUnit == null || number == null)
            ? DurationPeriod.forever()
            : DurationPeriod(number: number, unit: _durationUnit);
    widget.onChanged(widget.medication.copyWith(duration: duration));
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
              onChanged:
                  (value) =>
                      widget.onChanged(widget.medication.copyWith(name: value)),
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
                      final quantity = double.tryParse(value) ?? 0;
                      widget.onChanged(
                        widget.medication.copyWith(
                          dosage: widget.medication.dosage.copyWith(
                            quantity: quantity,
                          ),
                        ),
                      );
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
                        widget.onChanged(
                          widget.medication.copyWith(
                            dosage: widget.medication.dosage.copyWith(
                              unit: unit,
                            ),
                          ),
                        );
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
                  onChanged:
                      (value) => widget.onChanged(
                        widget.medication.copyWith(
                          dosage: widget.medication.dosage.copyWith(
                            customUnit: value,
                          ),
                        ),
                      ),
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
                onPressed: widget.onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTimes() async {
    final result = await showDialog<List<AdministrationTime>>(
      context: context,
      builder:
          (context) => TimeEditorDialog(initialTimes: widget.medication.times),
    );

    if (result != null) {
      widget.onChanged(widget.medication.copyWith(times: result));
      _timesController.text = _formatTimes(result);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _customUnitController.dispose();
    _timesController.dispose();
    _durationNumberController.dispose();
    super.dispose();
  }
}
