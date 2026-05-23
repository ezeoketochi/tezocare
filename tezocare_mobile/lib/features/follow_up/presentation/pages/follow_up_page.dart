import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/widgets/app_day_filter.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_event.dart';
import '../../../visit/presentation/bloc/visit_bloc.dart';
import '../../../visit/presentation/bloc/visit_event.dart';
import '../bloc/follow_up_bloc.dart';
import '../bloc/follow_up_event.dart';
import '../bloc/follow_up_state.dart';
import '../../domain/entities/due_follow_up.dart';

class FollowUpPage extends StatefulWidget {
  const FollowUpPage({super.key});

  @override
  State<FollowUpPage> createState() => _FollowUpPageState();
}

class _FollowUpPageState extends State<FollowUpPage> {
  int? _selectedDays;

  @override
  void initState() {
    super.initState();
    context.read<FollowUpBloc>().add(const GetDueFollowUpsEvent());
  }

  void _onDaysChanged(int? days) {
    setState(() => _selectedDays = days);
    context.read<FollowUpBloc>().add(GetDueFollowUpsEvent(days: days));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FollowUpBloc, FollowUpState>(
      listenWhen: (previous, current) => current is FollowUpMarkedDone,
      listener: (context, state) {
        if (state is FollowUpMarkedDone) {
          try {
            context.read<DashboardBloc>().add(const GetDashboardStatsEvent());
          } catch (_) {}
          try {
            context.read<VisitBloc>().add(GetVisitDetailEvent(id: state.visitId));
          } catch (_) {}
          try {
            context.read<VisitBloc>().add(GetPatientVisitsEvent(patientId: state.patientId));
          } catch (_) {}
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Follow-up marked as done')),
          );
        }
      },
      child: Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: Text(
                'Due Follow-ups',
                style: AppTextStyles.headlineMedium,
              ),
            ),
            AppDayFilter(
              selectedDays: _selectedDays,
              onChanged: _onDaysChanged,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<FollowUpBloc>().add(
                    GetDueFollowUpsEvent(days: _selectedDays),
                  );
                },
                child: BlocBuilder<FollowUpBloc, FollowUpState>(
                  builder: (context, state) {
                    if (state is FollowUpLoading) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(20.w),
                            child: AppLoading.shimmerList(),
                          ),
                        ],
                      );
                    }
                    if (state is FollowUpError) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 80.h),
                          AppEmptyState(
                            icon: Icons.error_outline_rounded,
                            title: 'Something went wrong',
                            message: state.message,
                            actionLabel: 'Retry',
                            onAction: () => context.read<FollowUpBloc>().add(
                              const GetDueFollowUpsEvent(),
                            ),
                          ),
                        ],
                      );
                    }
                    if (state is FollowUpLoaded) {
                      if (state.followUps.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 80.h),
                            const AppEmptyState(
                              icon: Icons.check_circle_outline,
                              title: 'All caught up',
                              message: 'No follow-ups due at this time',
                            ),
                          ],
                        );
                      }
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(bottom: 20.h),
                        children: [
                          _buildSummaryRow(state),
                          ...state.followUps.map(
                            (fu) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: _FollowUpCard(followUp: fu),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSummaryRow(FollowUpLoaded state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          _summaryChip(
            '${state.overdue}',
            'Overdue',
            AppColors.dangerLight,
            AppColors.danger,
          ),
          SizedBox(width: 8.w),
          _summaryChip(
            '${state.dueToday}',
            'Due Today',
            AppColors.warningLight,
            AppColors.warning,
          ),
          SizedBox(width: 8.w),
          _summaryChip(
            '${state.upcoming}',
            'Upcoming',
            AppColors.infoLight,
            AppColors.primary,
          ),
          const Spacer(),
          Text('${state.total} total', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _summaryChip(
    String value,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(color: textColor),
          ),
          SizedBox(width: 4.w),
          Text(label, style: AppTextStyles.caption.copyWith(color: textColor)),
        ],
      ),
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  final DueFollowUp followUp;

  const _FollowUpCard({required this.followUp});

  @override
  Widget build(BuildContext context) {
    final isOverdue = followUp.followupStatus == 'overdue';
    final isDueToday = followUp.followupStatus == 'due_today';

    Color statusColor;
    String statusText;
    if (isOverdue) {
      statusColor = AppColors.danger;
      statusText = 'Overdue';
    } else if (isDueToday) {
      statusColor = AppColors.warning;
      statusText = 'Due Today';
    } else {
      statusColor = AppColors.primary;
      statusText = 'Upcoming';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => _showFollowUpDetail(context),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOverdue
                          ? Icons.warning_rounded
                          : Icons.event_note_rounded,
                      color: statusColor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          followUp.patientName,
                          style: AppTextStyles.titleMedium,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Visit: ${followUp.visitId.split('-').first}...',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    text: statusText,
                    variant: isOverdue
                        ? StatusChipVariant.referred
                        : isDueToday
                        ? StatusChipVariant.active
                        : StatusChipVariant.followUpPending,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Scheduled: ${followUp.scheduledDate}',
                    style: AppTextStyles.bodySmall,
                  ),
                  SizedBox(width: 16.w),
                  if (followUp.attendingStaff != null) ...[
                    Icon(
                      Icons.person_outline,
                      size: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        followUp.attendingStaff!,
                        style: AppTextStyles.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              if (followUp.suspectedDiagnosis != null &&
                  followUp.suspectedDiagnosis!.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        followUp.suspectedDiagnosis!,
                        style: AppTextStyles.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (followUp.medicationsDispensed.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: followUp.medicationsDispensed
                      .map<Widget>(
                        (m) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '${m.drugName} ${m.dose}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFollowUpDetail(BuildContext context) {
    final outcomeController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            12.h,
            20.w,
            MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text('Follow-up Detail', style: AppTextStyles.headlineSmall),
              SizedBox(height: 12.h),
              _detailRow('Patient', followUp.patientName),
              _detailRow('Scheduled', followUp.scheduledDate),
              if (followUp.suspectedDiagnosis != null)
                _detailRow('Diagnosis', followUp.suspectedDiagnosis!),
              if (followUp.attendingStaff != null)
                _detailRow('Staff', followUp.attendingStaff!),
              SizedBox(height: 16.h),
              TextField(
                controller: outcomeController,
                decoration: InputDecoration(
                  labelText: 'Outcome',
                  hintText: 'Enter follow-up outcome',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () {
                    if (outcomeController.text.trim().isNotEmpty) {
                      context.read<FollowUpBloc>().add(
                        MarkFollowUpDoneEvent(
                          visitId: followUp.visitId,
                          outcome: outcomeController.text.trim(),
                        ),
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text('Mark as Done', style: AppTextStyles.labelLarge),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
