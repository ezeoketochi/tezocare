import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';

class VisitDetailPage extends StatefulWidget {
  final String visitId;

  const VisitDetailPage({super.key, required this.visitId});

  @override
  State<VisitDetailPage> createState() => _VisitDetailPageState();
}

class _VisitDetailPageState extends State<VisitDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<VisitBloc>().add(
          GetVisitDetailEvent(id: int.parse(widget.visitId)),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visit Detail')),
      body: BlocBuilder<VisitBloc, VisitState>(
        builder: (context, state) {
          if (state is VisitLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VisitError) {
            return Center(child: Text(state.message));
          }
          if (state is VisitDetailLoaded) {
            final visit = state.visit;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visit Information',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Divider(),
                          _buildDetailRow(
                            'Patient',
                            visit.patientName ?? 'ID: ${visit.patientId}',
                          ),
                          _buildDetailRow(
                            'Staff',
                            visit.staffName ?? 'ID: ${visit.staffId}',
                          ),
                          _buildDetailRow(
                            'Date',
                            visit.visitDate
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                          ),
                          _buildDetailRow('Status', visit.status),
                        ],
                      ),
                    ),
                  ),
                  if (visit.reason != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reason',
                              style:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                            const Divider(),
                            Text(visit.reason!),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (visit.diagnosis != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Diagnosis',
                              style:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                            const Divider(),
                            Text(visit.diagnosis!),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (visit.treatment != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Treatment',
                              style:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                            const Divider(),
                            Text(visit.treatment!),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (visit.notes != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes',
                              style:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                            const Divider(),
                            Text(visit.notes!),
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
