import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/visit_model.dart';
import '../../data/models/vitals_model.dart';
import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';

class CreateVisitPage extends StatefulWidget {
  const CreateVisitPage({super.key});

  @override
  State<CreateVisitPage> createState() => _CreateVisitPageState();
}

class _CreateVisitPageState extends State<CreateVisitPage> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _reasonController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _weightController = TextEditingController();
  final _crtController = TextEditingController();

  final DateTime _visitDate = DateTime.now();
  String _status = 'completed';

  @override
  void dispose() {
    _patientIdController.dispose();
    _reasonController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    _temperatureController.dispose();
    _heartRateController.dispose();
    _respiratoryRateController.dispose();
    _weightController.dispose();
    _crtController.dispose();
    super.dispose();
  }

  void _onCreate() {
    if (_formKey.currentState!.validate()) {
      final visit = VisitModel(
        id: 0,
        patientId: int.parse(_patientIdController.text.trim()),
        staffId: 0,
        visitDate: _visitDate,
        reason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        diagnosis: _diagnosisController.text.trim().isEmpty
            ? null
            : _diagnosisController.text.trim(),
        treatment: _treatmentController.text.trim().isEmpty
            ? null
            : _treatmentController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        status: _status,
      );

      VitalsModel? vitals;
      if (_temperatureController.text.isNotEmpty ||
          _heartRateController.text.isNotEmpty ||
          _respiratoryRateController.text.isNotEmpty) {
        vitals = VitalsModel(
          temperature: _temperatureController.text.isNotEmpty
              ? double.tryParse(_temperatureController.text.trim())
              : null,
          heartRate: _heartRateController.text.isNotEmpty
              ? int.tryParse(_heartRateController.text.trim())
              : null,
          respiratoryRate: _respiratoryRateController.text.isNotEmpty
              ? int.tryParse(_respiratoryRateController.text.trim())
              : null,
          weight: _weightController.text.isNotEmpty
              ? double.tryParse(_weightController.text.trim())
              : null,
          capillaryRefillTime: _crtController.text.isNotEmpty
              ? int.tryParse(_crtController.text.trim())
              : null,
        );
      }

      context
          .read<VisitBloc>()
          .add(CreateVisitEvent(visit: visit, vitals: vitals));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Visit')),
      body: BlocListener<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Visit created successfully')),
            );
            Navigator.of(context).pop();
          } else if (state is VisitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _patientIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Patient ID *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Patient ID is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(labelText: 'Reason'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _diagnosisController,
                  decoration: const InputDecoration(labelText: 'Diagnosis'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _treatmentController,
                  decoration: const InputDecoration(labelText: 'Treatment'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                        value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(
                        value: 'in_progress', child: Text('In Progress')),
                    DropdownMenuItem(
                        value: 'scheduled', child: Text('Scheduled')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
                const SizedBox(height: 24),
                Text('Vitals',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _temperatureController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Temperature (°C)',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _heartRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Heart Rate (bpm)',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _respiratoryRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Respiratory Rate (/min)',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _crtController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Capillary Refill Time (s)',
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<VisitBloc, VisitState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            state is VisitLoading ? null : _onCreate,
                        child: state is VisitLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Visit'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
