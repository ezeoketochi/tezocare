import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tezocare_mobile/features/visit/domain/repositories/visit_repository.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../injection_container.dart' as inj;
import '../../../../shared/widgets/status_chip.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../medication/domain/entities/medication.dart';
import '../../../medication/presentation/bloc/medication_bloc.dart';
import '../../../medication/presentation/bloc/medication_event.dart';
import '../../../medication/presentation/bloc/medication_state.dart';
import '../../../visit/domain/usecases/create_visit_usecase.dart';
import '../../../visit/domain/usecases/get_patient_visits_usecase.dart';
import '../../../visit/domain/usecases/get_visit_detail_usecase.dart';
import '../../../visit/domain/usecases/delete_visit_usecase.dart';
import '../../../visit/data/repositories/visit_repository_impl.dart';
import '../../../visit/presentation/bloc/visit_bloc.dart';
import '../../../visit/presentation/bloc/visit_event.dart';
import '../../../visit/presentation/bloc/visit_state.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

class PatientDetailPage extends StatefulWidget {
  final String patientId;

  const PatientDetailPage({super.key, required this.patientId});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<PatientBloc>().add(
      GetPatientDetailEvent(id: widget.patientId),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, state) {
          if (state is PatientLoading) {
            return Center(child: AppLoading.fullScreen());
          }
          if (state is PatientError) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Something went wrong',
              message: state.message,
              actionLabel: 'Retry',
              onAction: () => context.read<PatientBloc>().add(
                GetPatientDetailEvent(id: widget.patientId),
              ),
            );
          }
          if (state is PatientDetailLoaded) {
            final patient = state.patient;

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 200.h,
                    pinned: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await context.push(
                            '/patients/${widget.patientId}/edit',
                          );
                          if (context.mounted) {
                            context.read<PatientBloc>().add(
                              GetPatientDetailEvent(id: widget.patientId),
                            );
                          }
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeader(patient),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        indicatorColor: AppColors.primary,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        labelStyle: AppTextStyles.titleSmall,
                        tabs: const [
                          Tab(text: 'Overview'),
                          Tab(text: 'Visits'),
                          Tab(text: 'Medications'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(patient),
                  _buildVisitsTab(),
                  _buildMedicationsTab(),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(patient) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      padding: EdgeInsets.only(top: 10.h, bottom: 13.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppAvatar(name: patient.fullName, size: AvatarSize.xlarge),
          SizedBox(height: 10.h),
          Text(
            patient.fullName,
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.white),
          ),
          SizedBox(height: 4.h),
          Text(
            '${patient.gender} \u2022 ${patient.dob != null ? _calculateAge(patient.dob!) : 'N/A'} yrs',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          if (patient.chronicConditions.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: patient.chronicConditions
                    .map<Widget>(
                      (c) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          c,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewTab(patient) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text('Demographics', style: AppTextStyles.titleLarge),
                ),
                _divider(),
                _infoRow('Gender', patient.gender),
                _infoRow(
                  'Date of Birth',
                  patient.dob != null ? _formatDate(patient.dob!) : 'N/A',
                ),
                _infoRow('Blood Group', patient.bloodGroup ?? 'N/A'),
                _infoRow('Genotype', patient.genotype ?? 'N/A'),
                _infoRow('Phone', patient.phone ?? 'N/A'),
                _infoRow('Address', patient.address ?? 'N/A'),
                _infoRow('State', patient.state ?? 'N/A'),
                _infoRow('City', patient.city ?? 'N/A'),
                _infoRow('Occupation', patient.occupation ?? 'N/A'),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          if (patient.allergies.isNotEmpty)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text('Allergies', style: AppTextStyles.titleLarge),
                  ),
                  _divider(),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: patient.allergies
                          .map<Widget>(
                            (a) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.dangerLight,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                a,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 16.h),
          if (patient.emergencyContactName != null ||
              patient.emergencyContactPhone != null)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      'Emergency Contact',
                      style: AppTextStyles.titleLarge,
                    ),
                  ),
                  _divider(),
                  _infoRow('Name', patient.emergencyContactName ?? 'N/A'),
                  _infoRow('Phone', patient.emergencyContactPhone ?? 'N/A'),
                ],
              ),
            ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildVisitsTab() {
    return BlocProvider<VisitBloc>(
      create: (context) {
        final bloc = VisitBloc(
          createVisitUseCase: _getCreateVisitUseCase(),
          getPatientVisitsUseCase: _getPatientVisitsUseCase(),
          getVisitDetailUseCase: _getVisitDetailUseCase(),
          deleteVisitUseCase: _getDeleteVisitUseCase(),
          visitRepository: _getVisitRepository(),
        );
        bloc.add(GetPatientVisitsEvent(patientId: widget.patientId));
        return bloc;
      },
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<VisitBloc, VisitState>(
              builder: (context, state) {
                if (state is VisitLoading) {
                  return Padding(
                    padding: EdgeInsets.all(20.w),
                    child: AppLoading.shimmerList(count: 3),
                  );
                }
                if (state is VisitError) {
                  return AppEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Failed to load visits',
                    message: state.message,
                    actionLabel: 'Retry',
                    onAction: () => context.read<VisitBloc>().add(
                      GetPatientVisitsEvent(patientId: widget.patientId),
                    ),
                  );
                }
                if (state is VisitsLoaded) {
                  final visits = state.visits;
                  if (visits.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.medical_services_outlined,
                      title: 'No Visits',
                      message: 'No visits recorded for this patient',
                      actionLabel: 'Create New Visit',
                      onAction: () => context.push(
                        '/visits/create?patientId=${widget.patientId}',
                      ),
                    );
                  }
                  final sorted = List.from(visits)
                    ..sort((a, b) => b.visitDate.compareTo(a.visitDate));
                  return ListView.builder(
                    padding: EdgeInsets.all(20.w),
                    itemCount: sorted.length + 1,
                    itemBuilder: (context, index) {
                      if (index == sorted.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: AppButton(
                            label: 'New Visit',
                            onPressed: () => context.push(
                              '/visits/create?patientId=${widget.patientId}',
                            ),
                          ),
                        );
                      }
                      final visit = sorted[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: AppCard(
                          onTap: () => context.push(
                            '/patients/${widget.patientId}/visits/${visit.id}',
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.medical_services_outlined,
                                  size: 20.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Visit ${visit.visitNumber}',
                                      style: AppTextStyles.titleMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (visit.reason != null) ...[
                                      SizedBox(height: 4.h),
                                      Wrap(
                                        spacing: 6.w,
                                        runSpacing: 4.h,
                                        children: visit.reason!
                                            .map<Widget>(
                                              (r) => Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10.w,
                                                  vertical: 4.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        20.r,
                                                      ),
                                                ),
                                                child: Text(
                                                  r,
                                                  style: AppTextStyles
                                                      .labelMedium
                                                      .copyWith(
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                    SizedBox(height: 2.h),
                                    Text(
                                      _formatDate(visit.visitDate),
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              StatusChip(
                                text: visit.status,
                                variant: _statusVariant(visit.status),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 20.sp,
                                color: AppColors.textHint,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsTab() {
    final patientId = widget.patientId;
    return BlocProvider<MedicationBloc>(
      create: (context) {
        final bloc = MedicationBloc(
          addMedicationUseCase: inj.sl(),
          getPatientMedicationsUseCase: inj.sl(),
          updateMedicationUseCase: inj.sl(),
          deactivateMedicationUseCase: inj.sl(),
        );
        bloc.add(GetPatientMedicationsEvent(patientId: patientId));
        return bloc;
      },
      child: BlocBuilder<MedicationBloc, MedicationState>(
        builder: (context, state) {
          if (state is MedicationLoading) {
            return Padding(
              padding: EdgeInsets.all(20.w),
              child: AppLoading.shimmerList(count: 3),
            );
          }
          if (state is MedicationError) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Failed to load medications',
              message: state.message,
              actionLabel: 'Retry',
              onAction: () => context.read<MedicationBloc>().add(
                GetPatientMedicationsEvent(patientId: patientId),
              ),
            );
          }
          if (state is MedicationsLoaded) {
            final medications = state.medications;
            if (medications.isEmpty) {
              return AppEmptyState(
                icon: Icons.medication_outlined,
                title: 'No Medications Yet',
                message:
                    'Medications are recorded during a visit. '
                    'Start a new visit to add medications for this patient.',
                actionLabel: 'Start New Visit',
                onAction: () =>
                    context.push('/visits/create?patientId=$patientId'),
              );
            }

            final grouped = <String, List<Medication>>{};
            for (final med in medications) {
              final key = med.createdAt?.toIso8601String() ?? 'unknown';
              grouped.putIfAbsent(key, () => []).add(med);
            }

            final sortedKeys = grouped.keys.toList()
              ..sort((a, b) {
                if (a == 'unknown') return 1;
                if (b == 'unknown') return -1;
                return b.compareTo(a);
              });

            for (final key in grouped.keys) {
              grouped[key]!.sort((a, b) => a.name.compareTo(b.name));
            }

            final items = <Widget>[];
            for (final key in sortedKeys) {
              final date = DateTime.tryParse(key);
              items.add(
                Padding(
                  padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                  child: Row(
                    children: [
                      Text(
                        date != null ? _formatVisitDate(date) : 'Unknown',
                        style: AppTextStyles.titleSmall,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                ),
              );
              for (final med in grouped[key]!) {
                items.add(
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _buildMedicationCard(med, patientId),
                  ),
                );
              }
            }

            return ListView(padding: EdgeInsets.all(20.w), children: items);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMedicationCard(Medication med, String patientId) {
    final now = DateTime.now();
    final refillDiff = med.endDate?.difference(now).inDays;

    return AppCard(
      onTap: () => context.push('/patients/$patientId/visits/${med.id}'),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.medication_outlined,
                size: 20.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: AppTextStyles.titleMedium),
                SizedBox(height: 2.h),
                Text(
                  [
                    if (med.dosage != null && med.dosage!.isNotEmpty)
                      med.dosage!,
                    if (med.frequency != null && med.frequency!.isNotEmpty)
                      med.frequency!,
                    if (med.duration != null && med.duration!.isNotEmpty)
                      '${med.duration} days',
                  ].join(' \u2022 '),
                  style: AppTextStyles.bodySmall,
                ),
                if (med.prescribedBy != null &&
                    med.prescribedBy!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Prescribed by: ${med.prescribedBy}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            if (refillDiff != null && refillDiff < 0)
              _refillChip(
                'Refill Overdue',
                AppColors.dangerLight,
                AppColors.danger,
              )
            else if (refillDiff != null && refillDiff <= 3)
              _refillChip(
                'Refill Due Soon',
                AppColors.warningLight,
                AppColors.warning,
              ),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _refillChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatVisitDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: AppColors.border, height: 1);
  }

  StatusChipVariant _statusVariant(String status) {
    switch (status) {
      case 'completed':
        return StatusChipVariant.completed;
      case 'follow_up':
      case 'follow-up':
        return StatusChipVariant.followUpPending;
      case 'referred':
        return StatusChipVariant.referred;
      default:
        return StatusChipVariant.active;
    }
  }

  CreateVisitUseCase _getCreateVisitUseCase() {
    return inj.sl<CreateVisitUseCase>();
  }

  GetPatientVisitsUseCase _getPatientVisitsUseCase() {
    return inj.sl<GetPatientVisitsUseCase>();
  }

  GetVisitDetailUseCase _getVisitDetailUseCase() {
    return inj.sl<GetVisitDetailUseCase>();
  }

  DeleteVisitUseCase _getDeleteVisitUseCase() {
    return inj.sl<DeleteVisitUseCase>();
  }

  VisitRepository _getVisitRepository() {
    return inj.sl<VisitRepository>();
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.white, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height; // ✅ uses actual TabBar height

  @override
  double get minExtent => tabBar.preferredSize.height; // ✅ same

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
