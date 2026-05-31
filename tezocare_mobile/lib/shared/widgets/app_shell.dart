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
    sl<NotificationService>()
        .pendingForegroundNotification
        .addListener(_onForegroundNotification);
  }

  void _onForegroundNotification() {
    if (!mounted) return;
    final msg =
        sl<NotificationService>().pendingForegroundNotification.value;
    if (msg == null) return;

    final data = msg.data;
    final body = msg.notification?.body ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(body),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          onPressed: () => _navigateFromData(context, data),
        ),
      ),
    );
  }

  static void _navigateFromData(
      BuildContext context, Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type == 'refill') {
      context.go(RouteNames.dueRefills);
    } else if (type == 'followup') {
      context.go(RouteNames.followUp);
    }
  }

  @override
  void dispose() {
    sl<NotificationService>()
        .pendingForegroundNotification
        .removeListener(_onForegroundNotification);
    super.dispose();
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 64.h,
          decoration: BoxDecoration(
            color: AppColors.dark,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
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
        width: 64.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (index == 4)
              AppAvatar(name: staffName, size: AvatarSize.small)
            else
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22.sp,
                  color: isActive ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
