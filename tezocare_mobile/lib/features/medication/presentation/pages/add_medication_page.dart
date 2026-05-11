import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/services/app_toast.dart';
import '../../data/models/medication_model.dart';
import '../bloc/medication_bloc.dart';
import '../bloc/medication_event.dart';
import '../bloc/medication_state.dart';

class AddMedicationPage extends StatefulWidget {
  final String? patientId;

  const AddMedicationPage({super.key, this.patientId});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _routeController = TextEditingController();
  final _prescribedByController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _patientIdController.dispose();
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _routeController.dispose();
    _prescribedByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onAdd() {
    if (_formKey.currentState!.validate()) {
      final medication = MedicationModel(
        id: 0,
        patientId: int.parse(_patientIdController.text.trim()),
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim().isEmpty
            ? null
            : _dosageController.text.trim(),
        frequency: _frequencyController.text.trim().isEmpty
            ? null
            : _frequencyController.text.trim(),
        route: _routeController.text.trim().isEmpty
            ? null
            : _routeController.text.trim(),
        prescribedBy: _prescribedByController.text.trim().isEmpty
            ? null
            : _prescribedByController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isActive: true,
      );
      context
          .read<MedicationBloc>()
          .add(AddMedicationEvent(medication: medication));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      body: BlocListener<MedicationBloc, MedicationState>(
        listener: (context, state) {
          if (state is MedicationAdded) {
            AppToast.success(context, title: 'Medication added successfully');
            context.pop();
          } else if (state is MedicationError) {
            AppToast.error(context, title: state.message);
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
                  decoration:
                      const InputDecoration(labelText: 'Patient ID *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Patient ID is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Medication Name *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Medication name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(labelText: 'Dosage'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _frequencyController,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _routeController,
                  decoration:
                      const InputDecoration(labelText: 'Administration Route'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _prescribedByController,
                  decoration:
                      const InputDecoration(labelText: 'Prescribed By'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 32),
                BlocBuilder<MedicationBloc, MedicationState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            state is MedicationLoading ? null : _onAdd,
                        child: state is MedicationLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Add Medication'),
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
