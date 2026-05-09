import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/medication_bloc.dart';
import '../bloc/medication_event.dart';
import '../bloc/medication_state.dart';

class MedicationsPage extends StatefulWidget {
  final String? patientId;

  const MedicationsPage({super.key, this.patientId});

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  final _patientIdController = TextEditingController();

  @override
  void dispose() {
    _patientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TezoCare - Medications')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _patientIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter Patient ID',
                      labelText: 'Patient ID',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_patientIdController.text.isNotEmpty) {
                      context.read<MedicationBloc>().add(
                            GetPatientMedicationsEvent(
                              patientId:
                                  int.parse(_patientIdController.text.trim()),
                            ),
                          );
                    }
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<MedicationBloc, MedicationState>(
              builder: (context, state) {
                if (state is MedicationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MedicationError) {
                  return Center(child: Text(state.message));
                }
                if (state is MedicationsLoaded) {
                  if (state.medications.isEmpty) {
                    return const Center(
                      child: Text('No medications found'),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.medications.length,
                    itemBuilder: (context, index) {
                      final medication = state.medications[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(medication.name[0].toUpperCase()),
                          ),
                          title: Text(medication.name),
                          subtitle: Text(
                            '${medication.dosage ?? ""} ${medication.frequency ?? ""}',
                          ),
                          trailing: medication.isActive
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : const Icon(Icons.cancel, color: Colors.red),
                        ),
                      );
                    },
                  );
                }
                return const Center(
                  child: Text('Enter a Patient ID to view medications'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/medications/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
