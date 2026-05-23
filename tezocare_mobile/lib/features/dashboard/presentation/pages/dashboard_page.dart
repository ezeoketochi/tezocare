import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/entities/staff.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/widgets/app_section_header.dart';
import '../../../../shared/widgets/app_stat_card.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../patient/domain/entities/patient.dart';
import '../../../patient/presentation/bloc/patient_bloc.dart';
import '../../../patient/presentation/bloc/patient_event.dart';
import '../../../patient/presentation/bloc/patient_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const GetDashboardStatsEvent());
    context.read<PatientBloc>().add(const GetPatientsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final staff = authState is AuthAuthenticated ? authState.staff : null;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(
                  const GetDashboardStatsEvent(),
                );
                context.read<PatientBloc>().add(const GetPatientsEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(staff),
                    if (state is DashboardLoading)
                      _buildLoadingState()
                    else if (state is DashboardError)
                      _buildErrorState(state)
                    else if (state is DashboardLoaded)
                      _buildContent(state)
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(Staff? staff) {
    final greeting = _getGreeting();
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    staff?.name ?? 'Welcome',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textOnDark,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 20.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(children: [AppLoading.shimmerList(count: 4)]),
    );
  }

  Widget _buildErrorState(DashboardError state) {
    return AppEmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Something went wrong',
      message: state.message,
      actionLabel: 'Retry',
      onAction: () =>
          context.read<DashboardBloc>().add(const GetDashboardStatsEvent()),
    );
  }

  Widget _buildContent(DashboardLoaded state) {
    final stats = state.stats;
    final statIcons = [
      Icons.people_rounded,
      Icons.calendar_today_rounded,
      Icons.refresh_rounded,
      Icons.medication_outlined,
    ];
    final statLabels = [
      'Total Patients',
      'Visits Today',
      'Follow-ups Pending',
      'Refills Pending',
    ];
    final statValues = [
      stats.totalPatients.toString(),
      stats.visitsToday.toString(),
      stats.followUpsPending.toString(),
      stats.refillsDueSoon.length.toString(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) {
              return AppStatCard(
                value: statValues[index],
                label: statLabels[index],
                icon: statIcons[index],
              );
            },
          ),
        ),
        SizedBox(height: 20.h),
        _buildRecentPatients(),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildRecentPatients() {
    return BlocBuilder<PatientBloc, PatientState>(
      builder: (context, state) {
        if (state is PatientsLoaded && state.patients.isNotEmpty) {
          final recent = state.patients.take(5).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSectionHeader(
                title: 'Recent Patients',
                actionLabel: 'See all',
                onAction: () => context.go('/patients'),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: recent.map((patient) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: _buildPatientCard(patient),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return GestureDetector(
      onTap: () => context.push('/patients/${patient.id}'),
      child: Container(
        padding: EdgeInsets.all(14.w),
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
        child: Row(
          children: [
            AppAvatar(name: patient.fullName, size: AvatarSize.medium),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  if (patient.chronicConditions.isNotEmpty)
                    Text(
                      patient.chronicConditions.join(', '),
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (patient.createdAt != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      'Registered: ${_formatDate(patient.createdAt!)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
