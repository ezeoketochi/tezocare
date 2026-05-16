import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

class EditPatientPage extends StatefulWidget {
  final String patientId;

  const EditPatientPage({super.key, required this.patientId});

  @override
  State<EditPatientPage> createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  @override
  void initState() {
    super.initState();
    context.read<PatientBloc>().add(
          GetPatientDetailEvent(id: widget.patientId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Patient')),
      body: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, state) {
          if (state is PatientLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PatientError) {
            return Center(child: Text(state.message));
          }
          if (state is PatientDetailLoaded) {
            return const Center(child: Text('Edit patient form'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
