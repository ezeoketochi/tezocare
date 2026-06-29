import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../../domain/entities/notification.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<NotificationBloc>().add(const GetNotificationsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.headlineMedium),
        centerTitle: false,
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: AppTextStyles.titleMedium,
          unselectedLabelStyle: AppTextStyles.bodyMedium,
          tabs: const [
            Tab(text: 'Un-read'),
            Tab(text: 'Read'),
          ],
        ),
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            context.read<NotificationBloc>().add(
              const ClearNotificationMessages(),
            );
          }
        },
        builder: (context, state) {
          if (state.status == NotificationLoadStatus.loading) {
            return const _LoadingState();
          }
          if (state.status == NotificationLoadStatus.error) {
            return _ErrorState(
              onRetry: () => context.read<NotificationBloc>().add(
                const GetNotificationsEvent(),
              ),
            );
          }
          if (state.status == NotificationLoadStatus.loaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _NotificationList(
                  notifications: state.activeNotifications,
                  emptyMessage: 'No new notifications',
                  emptyIcon: Icons.notifications_off_outlined,
                  showStatus: false,
                  onDismiss: (n) {
                    context.read<NotificationBloc>().add(
                      MarkAsReadEvent(notificationId: n.id),
                    );
                  },
                  onRead: (n) {
                    context.read<NotificationBloc>().add(
                      MarkAsReadEvent(notificationId: n.id),
                    );
                  },
                ),
                _NotificationList(
                  notifications: state.historyNotifications,
                  emptyMessage: 'No notification history',
                  emptyIcon: Icons.history_outlined,
                  showStatus: true,
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [AppLoading.followUpListShimmer()],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Something went wrong',
        message: 'Failed to load notifications',
        actionLabel: 'Retry',
        onAction: onRetry,
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final List<StaffNotification> notifications;
  final String emptyMessage;
  final IconData emptyIcon;
  final bool showStatus;
  final void Function(StaffNotification)? onDismiss;
  final void Function(StaffNotification)? onRead;

  const _NotificationList({
    required this.notifications,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.showStatus,
    this.onDismiss,
    this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: AppEmptyState(icon: emptyIcon, title: emptyMessage, message: ''),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationBloc>().add(const GetNotificationsEvent());
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final card = _NotificationCard(
            notification: notification,
            showStatus: showStatus,
            onRead: onRead != null ? () => onRead!(notification) : null,
          );

          if (onDismiss != null) {
            return Dismissible(
              key: ValueKey(notification.id),
              direction: DismissDirection.horizontal,
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
              onDismissed: (_) => onDismiss!(notification),
              child: card,
            );
          }

          return card;
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final StaffNotification notification;
  final bool showStatus;
  final VoidCallback? onRead;

  const _NotificationCard({
    required this.notification,
    required this.showStatus,
    this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final typeIcon = _iconForType(notification.type);
    final typeColor = _colorForType(notification.type);
    final timeAgo = _formatTimeAgo(notification.createdAt);

    return Container(
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
        onTap: () => _showDetail(context),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(typeIcon, color: typeColor, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.message,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12.sp,
                          color: AppColors.textHint,
                        ),
                        SizedBox(width: 4.w),
                        Text(timeAgo, style: AppTextStyles.caption),
                        if (notification.patientName != null) ...[
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.person_outline,
                            size: 12.sp,
                            color: AppColors.textHint,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              notification.patientName!,
                              style: AppTextStyles.caption,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        if (showStatus) ...[
                          const Spacer(),
                          _StatusBadge(status: notification.status),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDetail(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _NotificationDetailSheet(notification: notification),
    );
    onRead?.call();
  }

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.refill:
        return Icons.medication_outlined;
      case NotificationType.followup:
        return Icons.event_note_rounded;
      case NotificationType.test:
        return Icons.bug_report_outlined;
      case NotificationType.other:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.refill:
        return AppColors.warning;
      case NotificationType.followup:
        return AppColors.primary;
      case NotificationType.test:
        return AppColors.info;
      case NotificationType.other:
        return AppColors.textSecondary;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final NotificationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case NotificationStatus.sent:
        return StatusChip(text: 'Sent', variant: StatusChipVariant.completed);
      case NotificationStatus.pending:
        return StatusChip(text: 'Pending', variant: StatusChipVariant.active);
      case NotificationStatus.failed:
        return StatusChip(text: 'Failed', variant: StatusChipVariant.referred);
      case NotificationStatus.read:
        return StatusChip(text: 'Read', variant: StatusChipVariant.completed);
    }
  }
}

class _NotificationDetailSheet extends StatelessWidget {
  final StaffNotification notification;

  const _NotificationDetailSheet({required this.notification});

  @override
  Widget build(BuildContext context) {
    final typeIcon = _iconForType(notification.type);
    final typeColor = _colorForType(notification.type);

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
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
                    'Notification Detail',
                    style: AppTextStyles.headlineSmall,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                    Center(
                      child: Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(typeIcon, color: typeColor, size: 24.sp),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTimeAgo(notification.createdAt),
                            style: AppTextStyles.caption,
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: const BoxDecoration(
                              color: AppColors.textHint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _typeLabel(notification.type),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        notification.message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ),
                    if (notification.patientName != null) ...[
                      SizedBox(height: 16.h),
                      _detailRow('Patient', notification.patientName!),
                    ],
                    SizedBox(height: 16.h),
                    _detailRow(
                      'Status',
                      notification.status.name.toUpperCase(),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.refill:
        return Icons.medication_outlined;
      case NotificationType.followup:
        return Icons.event_note_rounded;
      case NotificationType.test:
        return Icons.bug_report_outlined;
      case NotificationType.other:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.refill:
        return AppColors.warning;
      case NotificationType.followup:
        return AppColors.primary;
      case NotificationType.test:
        return AppColors.info;
      case NotificationType.other:
        return AppColors.textSecondary;
    }
  }

  String _typeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.refill:
        return 'Refill Reminder';
      case NotificationType.followup:
        return 'Follow-up Reminder';
      case NotificationType.test:
        return 'Test Notification';
      case NotificationType.other:
        return 'Notification';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
