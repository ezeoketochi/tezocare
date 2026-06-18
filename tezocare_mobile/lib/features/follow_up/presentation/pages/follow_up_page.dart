import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/widgets/app_tab_filter.dart';
import '../../../../shared/widgets/app_day_filter.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_event.dart';
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
  String? _activeFilter;
  int? _selectedDays;

  static const _filters = <String?>[null, 'pending_contact', 'due', 'overdue'];
  static const _filterLabels = ['All', 'Pending', 'Due', 'Overdue'];

  @override
  void initState() {
    super.initState();
    context.read<FollowUpBloc>().add(const GetDueFollowUpsEvent());
  }

  void _onFilterChanged(int index) {
    final filter = _filters[index];
    if (filter == _activeFilter) return;
    setState(() => _activeFilter = filter);
    _fetch();
  }

  void _onDaysChanged(int? days) {
    setState(() => _selectedDays = days);
    _fetch();
  }

  void _fetch() {
    context.read<FollowUpBloc>().add(
      GetDueFollowUpsEvent(days: _selectedDays),
    );
  }

  List<DueFollowUp> _filteredFollowUps(List<DueFollowUp> followUps) {
    if (_activeFilter == null) return followUps;
    return followUps.where((f) {
      switch (_activeFilter) {
        case 'pending':
          return f.followupStatus == 'upcoming';
        case 'due':
          return f.followupStatus == 'due_today';
        case 'overdue':
          return f.followupStatus == 'overdue';
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FollowUpBloc, FollowUpState>(
      listenWhen: (previous, current) =>
          previous is FollowUpStateContainer &&
          current is FollowUpStateContainer &&
          previous.actionStatus != current.actionStatus,
      // current.successMessage != null,
      listener: (context, state) {
        if (state is FollowUpStateContainer && state.successMessage != null) {
          try {
            context.read<DashboardBloc>().add(const GetDashboardStatsEvent());
          } catch (_) {}
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
          context.read<FollowUpBloc>().add(const ClearFollowUpError());
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
              AppTabFilter(
                labels: _filterLabels,
                selectedIndex: _filters.indexOf(_activeFilter),
                onChanged: _onFilterChanged,
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
                      if (state is FollowUpStateContainer &&
                          state.status == FollowUpStatus.loading) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(20.w),
                              child: AppLoading.followUpListShimmer(),
                            ),
                          ],
                        );
                      }
                      if (state is FollowUpStateContainer &&
                          state.status == FollowUpStatus.error) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 80.h),
                            AppEmptyState(
                              icon: Icons.error_outline_rounded,
                              title: 'Something went wrong',
                              message: state.errorMessage!,
                              actionLabel: 'Retry',
                              onAction: () => context.read<FollowUpBloc>().add(
                                GetDueFollowUpsEvent(days: _selectedDays),
                              ),
                            ),
                          ],
                        );
                      }
                      if (state is FollowUpStateContainer &&
                          state.status == FollowUpStatus.loaded) {
                        final filtered = _filteredFollowUps(state.followUps);
                        if (filtered.isEmpty) {
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
                            _buildSummaryRow(state, filtered),
                            ...filtered.map(
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

  Widget _buildSummaryRow(FollowUpStateContainer state, List<DueFollowUp> filtered) {
    final overdue = filtered.where((f) => f.followupStatus == 'overdue').length;
    final dueToday = filtered.where((f) => f.followupStatus == 'due_today').length;
    final upcoming = filtered.where((f) => f.followupStatus == 'upcoming').length;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          _summaryChip(
            '$overdue',
            'Overdue',
            AppColors.dangerLight,
            AppColors.danger,
          ),
          SizedBox(width: 8.w),
          _summaryChip(
            '$dueToday',
            'Due Today',
            AppColors.warningLight,
            AppColors.warning,
          ),
          SizedBox(width: 8.w),
          _summaryChip(
            '$upcoming',
            'Upcoming',
            AppColors.infoLight,
            AppColors.primary,
          ),
          const Spacer(),
          Text('${filtered.length} total', style: AppTextStyles.bodySmall),
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
    final followUpBloc = context.read<FollowUpBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalRouteContext) {
        return BlocProvider.value(
          value: followUpBloc,
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              final formKey = GlobalKey<FormState>();
              final outcomeController = TextEditingController();

              return BlocListener<FollowUpBloc, FollowUpState>(
                listenWhen: (previous, current) =>
                    previous is FollowUpStateContainer &&
                    current is FollowUpStateContainer &&
                    previous.actionStatus != current.actionStatus,
                listener: (listenerContext, state) {
                  if (state is FollowUpStateContainer &&
                      state.actionStatus == ActionStatus.success) {
                    Navigator.pop(sheetContext);
                  }
                },

                child: BlocBuilder<FollowUpBloc, FollowUpState>(
                  builder: (blocContext, state) {
                    final isSaving =
                        state is FollowUpStateContainer &&
                        state.actionStatus == ActionStatus.loading;

                    return Container(
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12.h),
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
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Follow-up Detail',
                                      style: AppTextStyles.headlineSmall,
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pop(sheetContext),
                                      child: Container(
                                        width: 32.w,
                                        height: 32.w,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryLight,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 18.sp,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Flexible(
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _detailRow('Patient', followUp.patientName),
                                      _detailRow('Scheduled', followUp.scheduledDate),
                                      if (followUp.suspectedDiagnosis != null)
                                        _detailRow(
                                          'Diagnosis',
                                          followUp.suspectedDiagnosis!,
                                        ),
                                      if (followUp.attendingStaff != null)
                                        _detailRow('Staff', followUp.attendingStaff!),
                                      SizedBox(height: 16.h),
                                      TextFormField(
                                        controller: outcomeController,
                                        enabled: !isSaving,
                                        decoration: InputDecoration(
                                          labelText: 'Outcome',
                                          hintText: 'Enter follow-up outcome',
                                          filled: true,
                                          fillColor: AppColors.inputFill,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                            borderSide: const BorderSide(
                                              color: AppColors.border,
                                              width: 1.5,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                            borderSide: const BorderSide(
                                              color: AppColors.border,
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                            borderSide: const BorderSide(
                                              color: AppColors.primary,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        maxLines: 3,
                                        validator: (value) =>
                                            value == null || value.trim().isEmpty
                                            ? 'Please provide an update outcome'
                                            : null,
                                      ),
                                      SizedBox(height: 16.h),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 45.h,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                    ),
                                    onPressed: isSaving
                                        ? null
                                        : () {
                                            if (formKey.currentState!.validate()) {
                                              blocContext.read<FollowUpBloc>().add(
                                                MarkFollowUpDoneEvent(
                                                  visitId: followUp.visitId,
                                                  outcome: outcomeController.text
                                                      .trim(),
                                                ),
                                              );
                                            }
                                          },
                                    child: isSaving
                                        ? SizedBox(
                                            height: 20.h,
                                            width: 20.w,
                                            child: const CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Mark as Done',
                                            style: AppTextStyles.labelLarge,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
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
