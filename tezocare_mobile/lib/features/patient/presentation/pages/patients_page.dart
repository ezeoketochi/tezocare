import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final _filters = ['All', 'Active', 'Follow-up Pending'];

  @override
  void initState() {
    super.initState();
    context.read<PatientBloc>().add(const GetPatientsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patients')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
            child: AppSearchBar(
              controller: _searchController,
              hint: 'Search patients...',
              onChanged: (query) {
                if (query.length >= 2) {
                  context
                      .read<PatientBloc>()
                      .add(SearchPatientsEvent(query: query));
                } else if (query.isEmpty) {
                  context
                      .read<PatientBloc>()
                      .add(const GetPatientsEvent());
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedFilter = filter);
                      context.read<PatientBloc>().add(
                        filter == 'All'
                            ? const GetPatientsEvent()
                            : SearchPatientsEvent(query: filter),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        filter,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: BlocBuilder<PatientBloc, PatientState>(
              builder: (context, state) {
                if (state is PatientLoading) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: AppLoading.shimmerList(),
                  );
                }
                if (state is PatientError) {
                  return AppEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Something went wrong',
                    message: state.message,
                    actionLabel: 'Retry',
                    onAction: () =>
                        context.read<PatientBloc>().add(const GetPatientsEvent()),
                  );
                }
                if (state is PatientsLoaded) {
                  if (state.patients.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'No patients found',
                      message: _searchController.text.isNotEmpty
                          ? 'No patients match your search'
                          : 'Start by registering a new patient',
                      actionLabel:
                          _searchController.text.isNotEmpty ? null : 'Add Patient',
                      onAction: _searchController.text.isNotEmpty
                          ? null
                          : () => context.push(RouteNames.createPatient),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: state.patients.length,
                    itemBuilder: (context, index) {
                      final patient = state.patients[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: AppCard(
                          onTap: () => context.push(
                            '${RouteNames.patients}/${patient.id}',
                          ),
                          child: Row(
                            children: [
                              AppAvatar(
                                name: patient.fullName,
                                size: AvatarSize.medium,
                              ),
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
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Text(
                                          '${patient.gender} \u2022 ${_calculateAge(patient.dob)} yrs',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                        if (patient.createdAt != null) ...[
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Reg: ${_formatDate(patient.createdAt!)}',
                                            style: AppTextStyles.caption,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              StatusChip(
                                text: patient.isActive ? 'Active' : 'Inactive',
                                variant: patient.isActive
                                    ? StatusChipVariant.active
                                    : StatusChipVariant.completed,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        onPressed: () => context.push(RouteNames.createPatient),
        child: const Icon(Icons.add),
      ),
    );
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
