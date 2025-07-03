import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:logging/logging.dart'; // Import the logging package
import '../models/prescription.dart';
import '../services/prescription_service.dart';
import '../widgets/prescription_card.dart';
import 'prescription_add.dart';

// Create a logger for this specific screen
final Logger _prescriptionListLogger = Logger('PrescriptionListScreen');

class PrescriptionListScreen extends StatefulWidget {
  final List<Prescription> initialPrescriptions;
  final List<CameraDescription> cameras;

  const PrescriptionListScreen({
    super.key,
    required this.initialPrescriptions,
    required this.cameras,
  });

  @override
  State<PrescriptionListScreen> createState() => _PrescriptionListScreenState();
}

class _PrescriptionListScreenState extends State<PrescriptionListScreen> {
  late List<Prescription> _prescriptions;
  final PrescriptionService _service = PrescriptionService();

  @override
  void initState() {
    super.initState();
    _prescriptionListLogger.info(
      'initState called for PrescriptionListScreen.',
    );
    _prescriptions = List.from(widget.initialPrescriptions);
    _prescriptionListLogger.info(
      'Initial prescriptions loaded: ${_prescriptions.length} items.',
    );
    for (var p in _prescriptions) {
      _prescriptionListLogger.fine(
        '  - Initial Prescription ID: ${p.id}, Patient: ${p.patientName}',
      );
    }
  }

  @override
  void didUpdateWidget(covariant PrescriptionListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This is useful if initialPrescriptions might change after initState
    if (widget.initialPrescriptions != oldWidget.initialPrescriptions) {
      _prescriptionListLogger.info(
        'didUpdateWidget: initialPrescriptions changed.',
      );
      setState(() {
        _prescriptions = List.from(widget.initialPrescriptions);
      });
      _prescriptionListLogger.info(
        'Updated prescriptions list to new initialPrescriptions: ${_prescriptions.length} items.',
      );
    }
  }

  @override
  void dispose() {
    _prescriptionListLogger.info('dispose called for PrescriptionListScreen.');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _prescriptionListLogger.info(
      'build called for PrescriptionListScreen. Currently showing ${_prescriptions.length} prescriptions.',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _prescriptionListLogger.info('Add button pressed.');
              _navigateToAddPage();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _prescriptions.length,
        itemBuilder: (context, index) {
          _prescriptionListLogger.fine(
            'Building item at index: $index, ID: ${_prescriptions[index].id}',
          );
          return Dismissible(
            key: Key(_prescriptions[index].id),
            background: Container(color: Colors.red),
            onDismissed: (_) {
              _prescriptionListLogger.info(
                'Dismissed item at index: $index, ID: ${_prescriptions[index].id}',
              );
              _deletePrescription(index);
            },
            child: PrescriptionCard(
              prescription: _prescriptions[index],
              onSave: (p) {
                _prescriptionListLogger.info(
                  'PrescriptionCard onSave callback received for ID: ${p.id}',
                );
                _savePrescription(p);
              },
              onDelete: (p) {
                _prescriptionListLogger.info(
                  'PrescriptionCard onDelete callback received for ID: ${p.id}',
                );
                final indexToDelete = _prescriptions.indexOf(p);
                if (indexToDelete != -1) {
                  _deletePrescription(indexToDelete);
                } else {
                  _prescriptionListLogger.warning(
                    'Attempted to delete a prescription not found in current list: ID ${p.id}',
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _navigateToAddPage() async {
    final newPrescription = await Navigator.push<Prescription>(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionAddPage(cameras: widget.cameras),
      ),
    );

    if (newPrescription != null) {
      // Use copyWith to ensure we're saving a new instance
      await _savePrescription(newPrescription.copyWith());
      await _refreshPrescriptions();
    }
  }

  Future<void> _savePrescription(Prescription prescription) async {
    _prescriptionListLogger.info(
      'Attempting to save prescription: ID ${prescription.id}, Patient: ${prescription.patientName}',
    );
    try {
      await _service.savePrescription(prescription);
      _prescriptionListLogger.info(
        'Prescription saved to service successfully: ID ${prescription.id}',
      );
      setState(() {
        final index = _prescriptions.indexWhere((p) => p.id == prescription.id);
        if (index != -1) {
          _prescriptions[index] = prescription;
          _prescriptionListLogger.info(
            'Updated existing prescription in list at index $index: ID ${prescription.id}',
          );
        } else {
          _prescriptions.insert(0, prescription);
          _prescriptionListLogger.info(
            'Added new prescription to list: ID ${prescription.id}',
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription saved successfully')),
      );
      _prescriptionListLogger.info(
        'SnackBar shown: Prescription saved successfully.',
      );
    } catch (e, st) {
      _prescriptionListLogger.severe(
        'Error saving prescription: ID ${prescription.id}',
        e,
        st,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving prescription: $e')));
      _prescriptionListLogger.warning(
        'SnackBar shown: Error saving prescription.',
      );
    }
  }

  Future<void> _deletePrescription(int index) async {
    if (index < 0 || index >= _prescriptions.length) {
      _prescriptionListLogger.warning(
        'Attempted to delete at invalid index: $index. Current list length: ${_prescriptions.length}',
      );
      return;
    }
    final prescription = _prescriptions[index];
    _prescriptionListLogger.info(
      'Attempting to delete prescription at index $index: ID ${prescription.id}, Patient: ${prescription.patientName}',
    );
    try {
      await _service.deletePrescription(prescription.id);
      _prescriptionListLogger.info(
        'Prescription deleted from service: ID ${prescription.id}',
      );
      setState(() => _prescriptions.removeAt(index));
      _prescriptionListLogger.info(
        'Prescription removed from local list at index $index.',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted ${prescription.patientName}\'s prescription'),
        ),
      );
      _prescriptionListLogger.info('SnackBar shown: Deleted prescription.');
    } catch (e, st) {
      _prescriptionListLogger.severe(
        'Error deleting prescription: ID ${prescription.id}',
        e,
        st,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting prescription: $e')),
      );
      _prescriptionListLogger.warning(
        'SnackBar shown: Error deleting prescription.',
      );
    }
  }

  Future<void> _refreshPrescriptions() async {
    final prescriptions = await _service.getAllPrescriptions();
    setState(() {
      _prescriptions = prescriptions;
    });
  }
}
