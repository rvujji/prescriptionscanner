import 'package:flutter/material.dart';
import '../models/prescription.dart';
import '../services/prescription_service.dart';
import 'prescription_card.dart';

class PrescriptionListScreen extends StatefulWidget {
  final List<Prescription> initialPrescriptions;

  const PrescriptionListScreen({super.key, required this.initialPrescriptions});

  @override
  State<PrescriptionListScreen> createState() => _PrescriptionListScreenState();
}

class _PrescriptionListScreenState extends State<PrescriptionListScreen> {
  late List<Prescription> _prescriptions;
  final PrescriptionService _service = PrescriptionService();

  @override
  void initState() {
    super.initState();
    _prescriptions = List.from(widget.initialPrescriptions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewPrescription,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _prescriptions.length,
        itemBuilder:
            (context, index) => Dismissible(
              key: Key(_prescriptions[index].id),
              background: Container(color: Colors.red),
              onDismissed: (_) => _deletePrescription(index),
              child: PrescriptionCard(
                prescription: _prescriptions[index],
                onSave: _savePrescription,
                onDelete: (p) => _deletePrescription(_prescriptions.indexOf(p)),
              ),
            ),
      ),
    );
  }

  Future<void> _savePrescription(Prescription prescription) async {
    try {
      await _service.savePrescription(prescription);
      setState(() {
        final index = _prescriptions.indexWhere((p) => p.id == prescription.id);
        if (index != -1) {
          _prescriptions[index] = prescription;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving prescription: $e')));
    }
  }

  Future<void> _deletePrescription(int index) async {
    final prescription = _prescriptions[index];
    try {
      await _service.deletePrescription(prescription.id);
      setState(() {
        _prescriptions.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted ${prescription.patientName}\'s prescription'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting prescription: $e')),
      );
    }
  }

  void _addNewPrescription() {
    final newPrescription = Prescription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      patientName: 'New Patient',
      doctorName: 'Dr. Smith',
      medications: [],
      notes: '',
      imagePath: '',
    );
    setState(() {
      _prescriptions.insert(0, newPrescription);
    });
  }
}
