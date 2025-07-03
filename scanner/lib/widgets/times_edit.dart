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
  final _specificTimesControllers = <int, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _times = List.from(widget.initialTimes);

    if (_times.isEmpty) {
      _times.add(
        AdministrationTime(frequency: 1, unit: TimeUnit.day, specificTimes: []),
      );
    }

    for (int i = 0; i < _times.length; i++) {
      final joinedTimes = _times[i].specificTimes.join(', ');
      _specificTimesControllers[i] = TextEditingController(text: joinedTimes);
    }
  }

  @override
  void dispose() {
    for (final controller in _specificTimesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Dose Times'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._times.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              final controller = _specificTimesControllers[index]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: time.frequency.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Every',
                            ),
                            onChanged: (value) {
                              final freq = int.tryParse(value) ?? 1;
                              _times[index] = time.copyWith(frequency: freq);
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
                            decoration: const InputDecoration(labelText: ''),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _specificTimesControllers.remove(index);
                              _times.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'at (e.g., 08:00, 13:00)',
                      ),
                      onChanged: (value) {
                        final times =
                            value
                                .split(',')
                                .map((t) => t.trim())
                                .where((t) => t.isNotEmpty)
                                .toList();
                        _times[index] = _times[index].copyWith(
                          specificTimes: times,
                        );
                      },
                    ),
                    const Divider(),
                  ],
                ),
              );
            }),
            TextButton(
              onPressed: () {
                final newIndex = _times.length;
                setState(() {
                  _times.add(
                    AdministrationTime(
                      frequency: 1,
                      unit: TimeUnit.day,
                      specificTimes: [],
                    ),
                  );
                  _specificTimesControllers[newIndex] = TextEditingController();
                });
              },
              child: const Text('+ Add Another Time'),
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
