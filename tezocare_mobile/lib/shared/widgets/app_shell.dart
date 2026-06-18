import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes/app_router.dart';
import '../../config/routes/route_names.dart';
import '../../config/themes/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../injection_container.dart';
import 'app_avatar.dart';

class AppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    sl<NotificationService>().setNavigationHandler(_navigateFromData);
  }

  void _navigateFromData(Map<String, dynamic> data) {
    if (!mounted) return;
    final type = data['type'] as String?;
    if (type == 'refill') {
      context.go(RouteNames.dueRefills);
    } else if (type == 'followup') {
      context.go(RouteNames.followUp);
    }
  }

  static const _tabs = [
    ('Home', Icons.home_rounded),
    ('Patients', Icons.people_rounded),
    ('Due-Refills', Icons.medication_rounded),
    ('Follow-ups', Icons.phone),
    ('Profile', Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final staffName = authState is AuthAuthenticated
        ? authState.staff.name
        : 'Staff';

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => current is AuthUnauthenticated,
        listener: (context, state) {
          AppRouter.authRefreshNotifier.value++;
          context.go(RouteNames.login);
        },
        child: widget.navigationShell,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (index) {
                final isActive = index == widget.navigationShell.currentIndex;
                return _buildTabItem(index, isActive, staffName);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, bool isActive, String staffName) {
    final label = _tabs[index].$1;
    final icon = _tabs[index].$2;

    return GestureDetector(
      onTap: () {
        if (index != widget.navigationShell.currentIndex) {
          widget.navigationShell.goBranch(index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (index == 4)
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(color: AppColors.primary, width: 2)
                      : Border.all(color: Colors.transparent, width: 2),
                ),
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: AppAvatar(name: staffName, size: AvatarSize.small),
                ),
              )
            else
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryLight
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22.sp,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'Satoshi',
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
