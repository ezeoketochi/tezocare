import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_day_filter.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/due_refill.dart';
import '../bloc/refill_bloc.dart';
import '../bloc/refill_event.dart';
import '../bloc/refill_state.dart';

class DueRefillsPage extends StatefulWidget {
  const DueRefillsPage({super.key});

  @override
  State<DueRefillsPage> createState() => _DueRefillsPageState();
}

class _DueRefillsPageState extends State<DueRefillsPage> {
  String? _activeFilter;
  int? _selectedDays;

  static const _filters = <String?>[null, 'pending_contact', 'due_overdue'];
  static const _filterLabels = ['All', 'Pending Contact', 'Due & Overdue'];

  @override
  void initState() {
    super.initState();
    context.read<RefillBloc>().add(const GetDueRefillsEvent());
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

  Future<void> _fetch() async {
    context.read<RefillBloc>().add(
      GetDueRefillsEvent(filter: _activeFilter, days: _selectedDays),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
              child: Text('Due Refills', style: AppTextStyles.headlineMedium),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildSegmentedFilter(),
            ),
            AppDayFilter(
              selectedDays: _selectedDays,
              onChanged: _onDaysChanged,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetch,
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
                            onAction: _fetch,
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
                              child: _RefillCard(
                                refill: r,
                                onContacted: () => context
                                    .read<RefillBloc>()
                                    .add(MarkAsContacted(refillId: r.refillId)),
                                onRefilled: () => context
                                    .read<RefillBloc>()
                                    .add(MarkAsRefilled(refillId: r.refillId)),
                              ),
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

  Widget _buildSegmentedFilter() {
    final selectedIndex = _filters.indexOf(_activeFilter);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: List.generate(_filterLabels.length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onFilterChanged(i),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _filterLabels[i],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryRow(RefillLoaded state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          _summaryChip(
            '${state.outreach}',
            'Outreach',
            AppColors.warningLight,
            AppColors.warning,
          ),
          SizedBox(width: 8.w),
          _summaryChip(
            '${state.dueToday}',
            'Due Today',
            AppColors.chipActiveBg,
            AppColors.chipActiveText,
          ),
          SizedBox(width: 8.w),
          _summaryChip(
            '${state.overdue}',
            'Overdue',
            AppColors.dangerLight,
            AppColors.danger,
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

class _RefillCard extends StatelessWidget {
  final DueRefill refill;
  final VoidCallback onContacted;
  final VoidCallback onRefilled;

  const _RefillCard({
    required this.refill,
    required this.onContacted,
    required this.onRefilled,
  });

  bool get _isOutreach => refill.escalatedStatus == 'Phase 1 (Outreach)';
  bool get _isDueToday => refill.escalatedStatus == 'Phase 2 (Due Today)';
  bool get _isOverdue => refill.escalatedStatus == 'Phase 3 (Overdue)';
  bool get _isContacted => refill.contactStatus == 'contacted';

  @override
  Widget build(BuildContext context) {
    final statusColor = _isOverdue
        ? AppColors.danger
        : _isDueToday
        ? AppColors.chipActiveText
        : AppColors.warning;

    String statusText;
    Color tagColor;
    Color tagTextColor;
    if (_isOverdue) {
      statusText = 'Overdue';
      tagColor = AppColors.dangerLight;
      tagTextColor = AppColors.danger;
    } else if (_isDueToday) {
      statusText = 'Due Today';
      tagColor = AppColors.chipActiveBg;
      tagTextColor = AppColors.chipActiveText;
    } else if (_isOutreach) {
      statusText = _isContacted ? 'Contacted' : 'Pending Contact';
      tagColor = _isContacted ? AppColors.successLight : AppColors.warningLight;
      tagTextColor = _isContacted ? AppColors.success : AppColors.warning;
    } else {
      statusText = 'Upcoming';
      tagColor = AppColors.primarySurface;
      tagTextColor = AppColors.primary;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: _isDueToday
            ? Border.all(color: AppColors.chipActiveText, width: 1.5)
            : _isOverdue
            ? Border.all(color: AppColors.danger, width: 1.5)
            : null,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isOverdue
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
                        refill.patientName,
                        style: AppTextStyles.titleMedium,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        refill.drugName.isNotEmpty
                            ? refill.drugName
                            : 'Medication',
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.caption.copyWith(
                      color: tagTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (refill.sig.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                refill.sig,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Refill: ${refill.refillDate}',
                  style: AppTextStyles.bodySmall,
                ),
                if (refill.daysUntilRefill > 0) ...[
                  SizedBox(width: 8.w),
                  Text(
                    '(${refill.daysUntilRefill} days)',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const Spacer(),
                if (refill.prescribedBy != null)
                  Text(
                    refill.prescribedBy!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (_isOutreach) {
      return Row(
        children: [
          _buildCommunicationButtons(context),
          const Spacer(),
          if (!_isContacted)
            TextButton.icon(
              onPressed: onContacted,
              icon: Icon(Icons.check_circle_outline, size: 16.sp),
              label: Text(
                'Mark Contacted',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 14.sp, color: AppColors.success),
                  SizedBox(width: 4.w),
                  Text(
                    'Contacted',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    if (_isDueToday) {
      return SizedBox(
        width: double.infinity,
        child: AppButton(
          label: 'Mark as Refilled',
          prefixIcon: Icon(
            Icons.check_circle,
            size: 18.sp,
            color: AppColors.white,
          ),
          onPressed: onRefilled,
        ),
      );
    }

    if (_isOverdue) {
      return SizedBox(
        width: double.infinity,
        child: AppButton(
          variant: AppButtonVariant.outline,
          label: 'Mark as Refilled',
          prefixIcon: Icon(
            Icons.check_circle_outline,
            size: 18.sp,
            color: AppColors.primary,
          ),
          onPressed: onRefilled,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCommunicationButtons(BuildContext context) {
    final phone = refill.patientPhone;
    if (phone == null || phone.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconButton(
          icon: Icons.phone_rounded,
          tooltip: 'Call patient',
          onTap: () => _launchPhone(context, phone),
        ),
        SizedBox(width: 8.w),
        _iconButton(
          icon: Icons.chat_rounded,
          tooltip: 'WhatsApp',
          onTap: () => _launchWhatsApp(context, phone),
        ),
      ],
    );
  }

  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 18.sp, color: AppColors.primary),
        padding: EdgeInsets.zero,
        tooltip: tooltip,
      ),
    );
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      onContacted();
    }
  }

  Future<void> _launchWhatsApp(BuildContext context, String phone) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      onContacted();
    }
  }
}
