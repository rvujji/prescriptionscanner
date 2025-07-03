import 'package:flutter/material.dart';
import '../models/medication.dart';

class TimeEditorDialog extends StatefulWidget {
  final List<AdministrationTime> initialTimes;

  const TimeEditorDialog({super.key, required this.initialTimes});

  @override
  State<TimeEditorDialog> createState() => _TimeEditorDialogState();
}

class _TimeEditorDialogState extends State<TimeEditorDialog> {
  late List<AdministrationTime> _times;

  @override
  void initState() {
    super.initState();
    _times = List.from(widget.initialTimes);
    if (_times.isEmpty) {
      _times.add(AdministrationTime(frequency: 1, unit: TimeUnit.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Administration Times'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._times.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: time.frequency.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Frequency',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _times[index] = time.copyWith(
                              frequency: int.tryParse(value) ?? 1,
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<TimeUnit>(
                        value: time.unit,
                        items:
                            TimeUnit.values.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit.name),
                              );
                            }).toList(),
                        onChanged: (unit) {
                          if (unit != null) {
                            setState(() {
                              _times[index] = time.copyWith(unit: unit);
                            });
                          }
                        },
                        decoration: const InputDecoration(labelText: 'Unit'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(() => _times.removeAt(index)),
                    ),
                  ],
                ),
              );
            }),
            TextButton(
              onPressed:
                  () => setState(() {
                    _times.add(
                      AdministrationTime(frequency: 1, unit: TimeUnit.day),
                    );
                  }),
              child: const Text('+ Add Another Time'),
            ),
            const Divider(),
            const Text('Specific Times (optional):'),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'e.g., 8:00 AM, 2:00 PM, 8:00 PM',
              ),
              onChanged: (value) {
                if (_times.isNotEmpty) {
                  setState(() {
                    _times[0] = _times[0].copyWith(specificTimes: value);
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _times),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
