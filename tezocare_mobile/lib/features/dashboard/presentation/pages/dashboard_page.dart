import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/widgets/stat_card.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'TezoCare',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.read<AuthBloc>().add(
                            const AuthLogoutRequested(),
                          );
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DashboardError) {
              return Center(
                child: Text(state.message, style: AppTextStyles.bodyMedium),
              );
            }
            if (state is DashboardLoaded) {
              final stats = state.stats;
              final colors = AppColors.statCardColors;
              final statItems = [
                (
                  stats.totalPatients.toString(),
                  'Total Patients',
                  Icons.pets,
                  colors[0],
                ),
                (
                  stats.activeVisits.toString(),
                  'Active Visits',
                  Icons.medical_services,
                  colors[1],
                ),
                (
                  stats.todayAppointments.toString(),
                  "Today's Appointments",
                  Icons.calendar_today,
                  colors[2],
                ),
                (
                  stats.pendingRefills.toString(),
                  'Pending Refills',
                  Icons.refresh,
                  colors[3],
                ),
              ];

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(
                    const GetDashboardStatsEvent(),
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overview', style: AppTextStyles.headlineMedium),
                      SizedBox(height: 16.h),
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.3,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: statItems.length,
                        itemBuilder: (context, index) {
                          final item = statItems[index];
                          return StatCard(
                            value: item.$1,
                            label: item.$2,
                            icon: item.$3,
                            color: item.$4,
                          );
                        },
                      ),
                      SizedBox(height: 24.h),
                      Text('Quick Actions', style: AppTextStyles.titleLarge),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              'Patients',
                              Icons.pets,
                              AppColors.primary,
                              () => context.push('/patients'),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildActionCard(
                              'Visits',
                              Icons.medical_services,
                              AppColors.secondary,
                              () => context.push('/visits/create'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              'Medications',
                              Icons.medication,
                              AppColors.accent,
                              () => context.push('/medications'),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildActionCard(
                              'Add Patient',
                              Icons.person_add,
                              AppColors.success,
                              () => context.push('/patients/create'),
                            ),
                          ),
                        ],
                      ),
                      if (state.refillsDue.isNotEmpty) ...[
                        SizedBox(height: 24.h),
                        Text('Refills Due', style: AppTextStyles.titleLarge),
                        SizedBox(height: 12.h),
                        ...state.refillsDue.map(
                          (refill) => Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [AppColors.cardShadow],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 4.h,
                              ),
                              leading: Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color:
                                      (refill.isOverdue
                                              ? AppColors.error
                                              : AppColors.warning)
                                          .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.refresh,
                                  color: refill.isOverdue
                                      ? AppColors.error
                                      : AppColors.warning,
                                  size: 20.sp,
                                ),
                              ),
                              title: Text(
                                refill.medicationName,
                                style: AppTextStyles.titleMedium,
                              ),
                              subtitle: Text(
                                '${refill.patientName} - Due: ${refill.nextRefillDate.toLocal().toString().split(' ')[0]}',
                                style: AppTextStyles.bodySmall,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
