import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/services/app_toast.dart';
import '../../data/models/patient_model.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

class CreatePatientPage extends StatefulWidget {
  const CreatePatientPage({super.key});

  @override
  State<CreatePatientPage> createState() => _CreatePatientPageState();
}

class _CreatePatientPageState extends State<CreatePatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _weightController = TextEditingController();
  final _microchipController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _notesController = TextEditingController();

  String _species = 'Canine';
  String _gender = 'Male';

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onCreate() {
    if (_formKey.currentState!.validate()) {
      final patient = PatientModel(
        id: 0,
        name: _nameController.text.trim(),
        species: _species,
        breed: _breedController.text.trim().isEmpty
            ? null
            : _breedController.text.trim(),
        color: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
        gender: _gender,
        weight: _weightController.text.trim().isEmpty
            ? null
            : double.tryParse(_weightController.text.trim()),
        microchipId: _microchipController.text.trim().isEmpty
            ? null
            : _microchipController.text.trim(),
        ownerName: _ownerNameController.text.trim().isEmpty
            ? null
            : _ownerNameController.text.trim(),
        ownerPhone: _ownerPhoneController.text.trim().isEmpty
            ? null
            : _ownerPhoneController.text.trim(),
        ownerEmail: _ownerEmailController.text.trim().isEmpty
            ? null
            : _ownerEmailController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isActive: true,
      );
      context.read<PatientBloc>().add(CreatePatientEvent(patient: patient));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Patient')),
      body: BlocListener<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state is PatientCreated) {
            AppToast.success(context, title: 'Patient created successfully');
            context.pop();
          } else if (state is PatientError) {
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
                Text('Patient Information',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _species,
                  decoration: const InputDecoration(labelText: 'Species *'),
                  items: const [
                    DropdownMenuItem(value: 'Canine', child: Text('Canine')),
                    DropdownMenuItem(value: 'Feline', child: Text('Feline')),
                    DropdownMenuItem(value: 'Avian', child: Text('Avian')),
                    DropdownMenuItem(value: 'Bovine', child: Text('Bovine')),
                    DropdownMenuItem(
                        value: 'Equine', child: Text('Equine')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _species = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _breedController,
                  decoration: const InputDecoration(labelText: 'Breed'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _gender = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _microchipController,
                  decoration: const InputDecoration(labelText: 'Microchip ID'),
                ),
                const SizedBox(height: 24),
                Text('Owner Information',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ownerNameController,
                  decoration: const InputDecoration(labelText: 'Owner Name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ownerPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Owner Phone'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ownerEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Owner Email'),
                ),
                const SizedBox(height: 24),
                Text('Notes', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Additional notes...',
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<PatientBloc, PatientState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            state is PatientLoading ? null : _onCreate,
                        child: state is PatientLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Patient'),
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
