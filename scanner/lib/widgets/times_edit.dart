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
    try {
      _times = List.from(widget.initialTimes);

      if (_times.isEmpty) {
        _times.add(
          AdministrationTime(
            frequency: 1,
            unit: TimeUnit.day,
            specificTimes: [],
          ),
        );
      }

      for (int i = 0; i < _times.length; i++) {
        final joinedTimes = _times[i].specificTimes.join(', ');
        _specificTimesControllers[i] = TextEditingController(text: joinedTimes);
      }
    } catch (e, stackTrace) {
      debugPrint('Error in initState: $e\n$stackTrace');
      _times = [
        AdministrationTime(frequency: 1, unit: TimeUnit.day, specificTimes: []),
      ];
    }
  }

  @override
  void dispose() {
    try {
      for (final controller in _specificTimesControllers.values) {
        controller.dispose();
      }
    } catch (e, stackTrace) {
      debugPrint('Error disposing controllers: $e\n$stackTrace');
    } finally {
      super.dispose();
    }
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
                              try {
                                final freq = int.tryParse(value) ?? 1;
                                _times[index] = time.copyWith(frequency: freq);
                              } catch (e, stackTrace) {
                                debugPrint(
                                  'Error updating frequency: $e\n$stackTrace',
                                );
                              }
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
                              try {
                                if (unit != null) {
                                  setState(() {
                                    _times[index] = time.copyWith(unit: unit);
                                  });
                                }
                              } catch (e, stackTrace) {
                                debugPrint(
                                  'Error changing time unit: $e\n$stackTrace',
                                );
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            try {
                              setState(() {
                                _specificTimesControllers.remove(index);
                                _times.removeAt(index);
                              });
                            } catch (e, stackTrace) {
                              debugPrint(
                                'Error removing time entry: $e\n$stackTrace',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Times (24-hr)',
                              hintText: 'e.g., 08:00, 13:00',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () => _pickTime(index, controller),
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                ),
              );
            }),
            TextButton(
              onPressed: () {
                try {
                  final newIndex = _times.length;
                  setState(() {
                    _times.add(
                      AdministrationTime(
                        frequency: 1,
                        unit: TimeUnit.day,
                        specificTimes: [],
                      ),
                    );
                    _specificTimesControllers[newIndex] =
                        TextEditingController();
                  });
                } catch (e, stackTrace) {
                  debugPrint('Error adding new time entry: $e\n$stackTrace');
                }
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
          onPressed: () {
            try {
              Navigator.pop(context, _times);
            } catch (e, stackTrace) {
              debugPrint('Error saving times: $e\n$stackTrace');
              Navigator.pop(
                context,
                widget.initialTimes,
              ); // Fallback to original
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickTime(int index, TextEditingController controller) async {
    try {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            ),
      );

      if (picked != null) {
        final formatted = _formatTime(picked);
        final current = controller.text.trim();
        final updatedText =
            current.isEmpty ? formatted : '$current, $formatted';
        setState(() {
          controller.text = updatedText;
          _times[index] = _times[index].copyWith(
            specificTimes: updatedText.split(',').map((e) => e.trim()).toList(),
          );
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error picking time: $e\n$stackTrace');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to set time')));
    }
  }

  String _formatTime(TimeOfDay time) {
    try {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e, stackTrace) {
      debugPrint('Error formatting time: $e\n$stackTrace');
      return '08:00'; // Default fallback
    }
  }
}
