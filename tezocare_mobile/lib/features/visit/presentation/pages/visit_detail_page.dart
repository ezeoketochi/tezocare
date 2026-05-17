import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty_state.dart';
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
            return Center(child: AppLoading.fullScreen());
          }
          if (state is VisitError) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Something went wrong',
              message: state.message,
              actionLabel: 'Retry',
              onAction: () => context
                  .read<VisitBloc>()
                  .add(GetVisitDetailEvent(id: int.parse(widget.visitId))),
            );
          }
          if (state is VisitDetailLoaded) {
            final visit = state.visit;
            return SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(visit),
                  SizedBox(height: 20.h),
                  _buildSection(
                    'Visit Info',
                    [
                      _detailRow('Date', _formatDate(visit.visitDate)),
                      _detailRow('Visit Number', visit.visitNumber.isNotEmpty ? visit.visitNumber : '#${visit.id}'),
                      _detailRow('Status', visit.status),
                      if (visit.patientName != null)
                        _detailRow('Patient', visit.patientName!),
                      if (visit.staffName != null)
                        _detailRow('Staff', visit.staffName!),
                    ],
                  ),
                  if (visit.chiefComplaints.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    _buildSection(
                      'Chief Complaints',
                      visit.chiefComplaints.map((c) =>
                        _detailRow(
                          c.complaint ?? '',
                          c.duration != null ? 'Duration: ${c.duration}' : '',
                        ),
                      ).toList(),
                    ),
                  ],
                  if (visit.clinicalAssessment != null) ...[
                    SizedBox(height: 16.h),
                    _buildSection(
                      'Clinical Assessment',
                      [
                        if (visit.clinicalAssessment!.diagnosis != null)
                          _detailRow('Diagnosis', visit.clinicalAssessment!.diagnosis!),
                        if (visit.clinicalAssessment!.severity != null)
                          _detailRow('Severity', visit.clinicalAssessment!.severity!),
                        if (visit.clinicalAssessment!.pharmacistNotes != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Text(
                              visit.clinicalAssessment!.pharmacistNotes!,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (visit.vitals != null) ...[
                    SizedBox(height: 16.h),
                    _buildSection(
                      'Vitals',
                      [
                        if (visit.vitals!.bloodPressureSystolic != null)
                          _detailRow('BP', '${visit.vitals!.bloodPressureSystolic}/${visit.vitals!.bloodPressureDiastolic ?? "?"}'),
                        if (visit.vitals!.heartRate != null)
                          _detailRow('Heart Rate', '${visit.vitals!.heartRate} bpm'),
                        if (visit.vitals!.temperature != null)
                          _detailRow('Temperature', '${visit.vitals!.temperature} °C'),
                        if (visit.vitals!.spo2 != null)
                          _detailRow('SpO2', '${visit.vitals!.spo2} %'),
                        if (visit.vitals!.weight != null)
                          _detailRow('Weight', '${visit.vitals!.weight} kg'),
                        if (visit.vitals!.bmi != null)
                          _detailRow('BMI', visit.vitals!.bmi!.toStringAsFixed(1)),
                        if (visit.vitals!.glucose != null)
                          _detailRow('Glucose', '${visit.vitals!.glucose} (${visit.vitals!.glucoseType ?? "N/A"})'),
                      ],
                    ),
                  ],
                  if (visit.medicationsDispensed.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    _buildSection(
                      'Medications Dispensed',
                      visit.medicationsDispensed.map((m) =>
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Text(
                            '${m.drugName ?? ""} ${m.dose ?? ""} ${m.frequency ?? ""}',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ).toList(),
                    ),
                  ],
                  if (visit.counsellingAdvice != null && visit.counsellingAdvice!.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    _buildSection(
                      'Counselling & Advice',
                      [Text(visit.counsellingAdvice!, style: AppTextStyles.bodyMedium)],
                    ),
                  ],
                  if (visit.followUp != null && visit.followUp!.required) ...[
                    SizedBox(height: 16.h),
                    _buildSection(
                      'Follow-up',
                      [if (visit.followUp!.date != null)
                        _detailRow('Date', _formatDate(visit.followUp!.date!))],
                    ),
                  ],
                  if (visit.referral != null && visit.referral!.destination != null) ...[
                    SizedBox(height: 16.h),
                    _buildSection(
                      'Referral',
                      [
                        _detailRow('Destination', visit.referral!.destination!),
                        if (visit.referral!.reason != null)
                          _detailRow('Reason', visit.referral!.reason!),
                      ],
                    ),
                  ],
                  SizedBox(height: 24.h),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatusHeader(visit) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                visit.reason ?? 'Visit #${visit.id}',
                style: AppTextStyles.headlineSmall,
              ),
              SizedBox(height: 4.h),
              Text(
                _formatDate(visit.visitDate),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        StatusChip(
          text: visit.status,
          variant: _statusVariant(visit.status),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              title,
              style: AppTextStyles.titleLarge,
            ),
          ),
          ...children.map((child) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: child,
              )),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  StatusChipVariant _statusVariant(String status) {
    switch (status) {
      case 'completed':
        return StatusChipVariant.completed;
      case 'follow_up':
      case 'follow-up':
        return StatusChipVariant.followUpPending;
      case 'referred':
        return StatusChipVariant.referred;
      default:
        return StatusChipVariant.active;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
