import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../bloc/refill_bloc.dart';
import '../bloc/refill_event.dart';
import '../bloc/refill_state.dart';
import '../../domain/entities/due_refill.dart';

class DueRefillsPage extends StatefulWidget {
  const DueRefillsPage({super.key});

  @override
  State<DueRefillsPage> createState() => _DueRefillsPageState();
}

class _DueRefillsPageState extends State<DueRefillsPage> {
  @override
  void initState() {
    super.initState();
    context.read<RefillBloc>().add(const GetDueRefillsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: Text('Due Refills', style: AppTextStyles.headlineMedium),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<RefillBloc>().add(const GetDueRefillsEvent());
                },
                child: BlocBuilder<RefillBloc, RefillState>(
                  builder: (context, state) {
                    if (state is RefillLoading) {
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
                    if (state is RefillError) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 80.h),
                          AppEmptyState(
                            icon: Icons.error_outline_rounded,
                            title: 'Something went wrong',
                            message: state.message,
                            actionLabel: 'Retry',
                            onAction: () => context
                                .read<RefillBloc>()
                                .add(const GetDueRefillsEvent()),
                          ),
                        ],
                      );
                    }
                    if (state is RefillLoaded) {
                      if (state.refills.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 80.h),
                            const AppEmptyState(
                              icon: Icons.check_circle_outline,
                              title: 'No Refills Due',
                              message: 'All medications are up to date',
                            ),
                          ],
                        );
                      }
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(bottom: 20.h),
                        children: [
                          _buildSummaryRow(state),
                          ...state.refills.map(
                            (r) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: _RefillCard(refill: r),
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
    );
  }

  Widget _buildSummaryRow(RefillLoaded state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          _summaryChip('${state.overdue}', 'Overdue', AppColors.dangerLight, AppColors.danger),
          SizedBox(width: 8.w),
          _summaryChip('${state.dueToday}', 'Due Today', AppColors.warningLight, AppColors.warning),
          SizedBox(width: 8.w),
          _summaryChip('${state.upcoming}', 'Upcoming', AppColors.infoLight, AppColors.primary),
          const Spacer(),
          Text('${state.total} total', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _summaryChip(String value, String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTextStyles.labelMedium.copyWith(color: textColor)),
          SizedBox(width: 4.w),
          Text(label, style: AppTextStyles.caption.copyWith(color: textColor)),
        ],
      ),
    );
  }
}

class _RefillCard extends StatelessWidget {
  final DueRefill refill;

  const _RefillCard({required this.refill});

  @override
  Widget build(BuildContext context) {
    final isOverdue = refill.refillStatus == 'overdue';
    final isDueToday = refill.refillStatus == 'due_today';

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
                        : Icons.medication_outlined,
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
                        refill.drugName.isNotEmpty ? refill.drugName : 'Medication',
                        style: AppTextStyles.titleMedium,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        refill.patientName,
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
                if (refill.dose.isNotEmpty) ...[
                  _infoChip(Icons.straighten, refill.dose),
                  SizedBox(width: 8.w),
                ],
                if (refill.frequency.isNotEmpty) ...[
                  _infoChip(Icons.schedule, refill.frequency),
                  SizedBox(width: 8.w),
                ],
                if (refill.duration.isNotEmpty) ...[
                  _infoChip(Icons.date_range, refill.duration),
                ],
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 6.w),
                Text(
                  'Refill: ${refill.refillDate}',
                  style: AppTextStyles.bodySmall,
                ),
                SizedBox(width: 16.w),
                if (refill.prescribedBy != null) ...[
                  Icon(Icons.person_outline, size: 14.sp, color: AppColors.textSecondary),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      refill.prescribedBy!,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: AppColors.primary),
          SizedBox(width: 4.w),
          Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
