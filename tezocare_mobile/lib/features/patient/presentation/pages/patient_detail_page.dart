import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_section_header.dart';
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
          GetPatientDetailEvent(id: widget.patientId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, state) {
          if (state is PatientLoading) {
            return Center(child: AppLoading.fullScreen());
          }
          if (state is PatientError) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Something went wrong',
              message: state.message,
              actionLabel: 'Retry',
              onAction: () => context.read<PatientBloc>().add(
                    GetPatientDetailEvent(id: widget.patientId),
                  ),
            );
          }
          if (state is PatientDetailLoaded) {
            final patient = state.patient;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(patient),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(patient),
                        SizedBox(height: 16.h),
                        _buildContactSection(patient),
                        if (patient.allergies != null ||
                            patient.chronicConditions != null) ...[
                          SizedBox(height: 16.h),
                          _buildMedicalSection(patient),
                        ],
                        SizedBox(height: 16.h),
                        _buildMedicationsSection(patient),
                        SizedBox(height: 16.h),
                        _buildVitalsSection(patient),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(patient) {
    final initials = patient.fullName.isNotEmpty
        ? patient.fullName.split(' ').map((n) => n[0]).take(2).join()
        : '?';
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.splashGradient,
      ),
      padding: EdgeInsets.only(top: 60.h, bottom: 32.h),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundColor: AppColors.white,
            child: Text(
              initials.toUpperCase(),
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            patient.fullName,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${patient.gender} \u2022 ${_formatDate(patient.dob)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            patient.phone,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(patient) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: 'Personal Information'),
          SizedBox(height: 8.h),
          _infoRow('Gender', patient.gender),
          _infoRow('Date of Birth', _formatDate(patient.dob)),
          _infoRow('Blood Group', patient.bloodGroup ?? 'N/A'),
          _infoRow(
            'Registered',
            patient.createdAt != null
                ? _formatDate(patient.createdAt!)
                : 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(patient) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: 'Contact & Emergency'),
          SizedBox(height: 8.h),
          _infoRow('Phone', patient.phone),
          if (patient.address != null)
            _infoRow('Address', patient.address!),
          if (patient.emergencyContactName != null)
            _infoRow('Emergency Contact', patient.emergencyContactName!),
          if (patient.emergencyContactPhone != null)
            _infoRow('Emergency Phone', patient.emergencyContactPhone!),
        ],
      ),
    );
  }

  Widget _buildMedicalSection(patient) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: 'Medical Information'),
          SizedBox(height: 8.h),
          if (patient.allergies != null && patient.allergies!.isNotEmpty)
            _infoRow('Allergies', patient.allergies!),
          if (patient.chronicConditions != null &&
              patient.chronicConditions!.isNotEmpty)
            _infoRow('Chronic Conditions', patient.chronicConditions!),
        ],
      ),
    );
  }

  Widget _buildMedicationsSection(patient) {
    if (patient.medications.isEmpty && patient.nextRefill == null) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(title: 'Medications'),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'No medications recorded',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Medications',
            actionLabel: patient.medications.isNotEmpty ? '${patient.medications.length} total' : null,
          ),
          if (patient.nextRefill != null) ...[
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.accentPale,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.accentLight),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 20.sp,
                      color: AppColors.accent,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Refill Due',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${patient.nextRefill!.drugName} - ${_formatDate(patient.nextRefill!.nextRefillDate)}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: 8.h),
          ...patient.medications.map((med) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPale,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.medication_outlined,
                        size: 20.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med.drugName,
                            style: AppTextStyles.titleMedium,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${med.dosage} \u2022 ${med.frequency}',
                            style: AppTextStyles.bodySmall,
                          ),
                          if (med.nextRefillDate != null) ...[
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12.sp,
                                  color: AppColors.textTertiary,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Refill: ${_formatDate(med.nextRefillDate!)}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    AppBadge(
                      text: med.isActive ? 'Active' : 'Inactive',
                      variant: med.isActive
                          ? BadgeVariant.active
                          : BadgeVariant.inactive,
                    ),
                  ],
                ),
                if (med != patient.medications.last)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Divider(
                      color: AppColors.divider,
                      height: 1,
                    ),
                  ),
              ],
            ),
          )),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildVitalsSection(patient) {
    if (patient.vitals.isEmpty) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(title: 'Vital Signs'),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'No vital signs recorded',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    final latest = patient.vitals.first;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: 'Vital Signs'),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 12.h,
              children: [
                if (latest.bloodPressureSystolic != null)
                  _vitalChip(
                    'BP',
                    '${latest.bloodPressureSystolic}/${latest.bloodPressureDiastolic ?? '?'}',
                    Icons.favorite_outlined,
                    AppColors.coral,
                  ),
                if (latest.heartRate != null)
                  _vitalChip(
                    'HR',
                    '${latest.heartRate} bpm',
                    Icons.favorite_border_rounded,
                    AppColors.primary,
                  ),
                if (latest.temperature != null)
                  _vitalChip(
                    'Temp',
                    '${latest.temperature!.toStringAsFixed(1)}°C',
                    Icons.thermostat_outlined,
                    AppColors.gold,
                  ),
                if (latest.weight != null)
                  _vitalChip(
                    'Weight',
                    '${latest.weight!.toStringAsFixed(1)} kg',
                    Icons.monitor_weight_outlined,
                    AppColors.accent,
                  ),
                if (latest.glucose != null)
                  _vitalChip(
                    'Glucose',
                    '${latest.glucose!.toStringAsFixed(1)}',
                    Icons.bloodtype_outlined,
                    AppColors.info,
                  ),
                if (latest.spo2 != null)
                  _vitalChip(
                    'SpO₂',
                    '${latest.spo2}%',
                    Icons.air_rounded,
                    AppColors.success,
                  ),
              ],
            ),
          ),
          if (latest.recordedAt != null) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
              child: Text(
                'Last recorded: ${_formatDateTime(latest.recordedAt!)}',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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

  Widget _vitalChip(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: (MediaQuery.of(context).size.width - 76.w) / 3,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20.sp, color: color),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
