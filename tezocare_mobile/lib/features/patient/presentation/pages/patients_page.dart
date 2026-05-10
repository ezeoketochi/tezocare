import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PatientBloc>().add(const GetPatientsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TezoCare - Patients')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patients...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<PatientBloc>()
                              .add(const GetPatientsEvent());
                        },
                      )
                    : null,
              ),
              onChanged: (query) {
                if (query.length >= 2) {
                  context
                      .read<PatientBloc>()
                      .add(SearchPatientsEvent(query: query));
                } else if (query.isEmpty) {
                  context
                      .read<PatientBloc>()
                      .add(const GetPatientsEvent());
                }
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<PatientBloc, PatientState>(
              builder: (context, state) {
                if (state is PatientLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PatientError) {
                  return Center(child: Text(state.message));
                }
                if (state is PatientsLoaded) {
                  if (state.patients.isEmpty) {
                    return const Center(child: Text('No patients found'));
                  }
                  return ListView.builder(
                    itemCount: state.patients.length,
                    itemBuilder: (context, index) {
                      final patient = state.patients[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(patient.name[0].toUpperCase()),
                          ),
                          title: Text(patient.name),
                          subtitle: Text(
                            '${patient.species}${patient.breed != null ? ' - ${patient.breed}' : ''}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push(
                              '/patients/detail/${patient.id}',
                            );
                          },
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/patients/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
