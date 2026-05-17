import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../config/themes/app_colors.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import 'app_avatar.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  static const _tabs = [
    ('Home', Icons.home_rounded),
    ('Patients', Icons.people_rounded),
    ('Medications', Icons.medication_rounded),
    ('Profile', Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final staffName = authState is AuthAuthenticated ? authState.staff.name : 'Staff';

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 64.h,
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
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
                final isActive = index == navigationShell.currentIndex;
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
        if (index != navigationShell.currentIndex) {
          navigationShell.goBranch(index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (index == 3)
              AppAvatar(
                name: staffName,
                size: AvatarSize.small,
              )
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
