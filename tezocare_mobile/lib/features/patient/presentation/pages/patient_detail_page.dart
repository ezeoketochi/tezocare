import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

class PatientDetailPage extends StatefulWidget {
  final String patientId;

  const PatientDetailPage({super.key, required this.patientId});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<PatientBloc>().add(
          GetPatientDetailEvent(id: int.parse(widget.patientId)),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Detail')),
      body: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, state) {
          if (state is PatientLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PatientError) {
            return Center(child: Text(state.message));
          }
          if (state is PatientDetailLoaded) {
            final patient = state.patient;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          child: Text(
                            patient.name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          patient.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          patient.species,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Details',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Divider(),
                          _buildDetailRow('Breed', patient.breed ?? 'N/A'),
                          _buildDetailRow('Color', patient.color ?? 'N/A'),
                          _buildDetailRow('Gender', patient.gender ?? 'N/A'),
                          _buildDetailRow(
                            'Date of Birth',
                            patient.dateOfBirth?.toLocal().toString().split(' ')[0] ??
                                'N/A',
                          ),
                          _buildDetailRow(
                            'Weight',
                            patient.weight != null
                                ? '${patient.weight} kg'
                                : 'N/A',
                          ),
                          _buildDetailRow(
                            'Microchip',
                            patient.microchipId ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Owner Information',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Divider(),
                          _buildDetailRow(
                            'Name',
                            patient.ownerName ?? 'N/A',
                          ),
                          _buildDetailRow(
                            'Phone',
                            patient.ownerPhone ?? 'N/A',
                          ),
                          _buildDetailRow(
                            'Email',
                            patient.ownerEmail ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (patient.notes != null && patient.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Divider(),
                            Text(patient.notes!),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
