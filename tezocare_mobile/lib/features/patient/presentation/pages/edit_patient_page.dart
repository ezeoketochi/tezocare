import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../../features/dashboard/presentation/bloc/dashboard_event.dart';
import '../../domain/entities/patient.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

class EditPatientPage extends StatefulWidget {
  final String patientId;

  const EditPatientPage({super.key, required this.patientId});

  @override
  State<EditPatientPage> createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _occupationController = TextEditingController();
  final _allergyController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  String _gender = 'male';
  DateTime? _dateOfBirth;
  String? _bloodGroup;
  String? _genotype;
  List<String> _allergies = [];

  static const _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  static const _genotypes = ['AA', 'AS', 'SS', 'AC', 'SC'];

  @override
  void initState() {
    super.initState();
    context.read<PatientBloc>().add(
      GetPatientDetailEvent(id: widget.patientId),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _occupationController.dispose();
    _allergyController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _initForm(Patient patient) {
    if (_firstNameController.text.isNotEmpty) return;
    _firstNameController.text = patient.firstName;
    _lastNameController.text = patient.lastName;
    _phoneController.text = patient.phone ?? '';
    _addressController.text = patient.address ?? '';
    _stateController.text = patient.state ?? '';
    _cityController.text = patient.city ?? '';
    _occupationController.text = patient.occupation ?? '';
    _gender = patient.gender;
    _dateOfBirth = patient.dateOfBirth;
    _bloodGroup =
        patient.bloodGroup != null && _bloodGroups.contains(patient.bloodGroup)
        ? patient.bloodGroup
        : null;
    _genotype =
        patient.genotype != null && _genotypes.contains(patient.genotype)
        ? patient.genotype
        : null;
    _allergies = List.from(patient.allergies);
    _emergencyNameController.text = patient.emergencyContactName ?? '';
    _emergencyPhoneController.text = patient.emergencyContactPhone ?? '';
  }

  void _addAllergy() {
    final text = _allergyController.text.trim();
    if (text.isNotEmpty && !_allergies.contains(text)) {
      setState(() => _allergies.add(text));
      _allergyController.clear();
    }
  }

  void _removeAllergy(String allergy) {
    setState(() => _allergies.remove(allergy));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final state = context.read<PatientBloc>().state;
    if (state is! PatientDetailLoaded) return;

    final isLoading = state.isBackgroundUpdating;

    final original = state.patient;
    final updated = Patient(
      id: original.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _dateOfBirth,
      gender: _gender,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      state: _stateController.text.trim().isEmpty
          ? null
          : _stateController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      occupation: _occupationController.text.trim().isEmpty
          ? null
          : _occupationController.text.trim(),
      bloodGroup: _bloodGroup,
      genotype: _genotype,
      allergies: _allergies,
      chronicConditions: original.chronicConditions,
      emergencyContactName: _emergencyNameController.text.trim().isEmpty
          ? null
          : _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty
          ? null
          : _emergencyPhoneController.text.trim(),
      registeredBy: original.registeredBy,
      isActive: original.isActive,
    );
    try {
      context.read<PatientBloc>().add(UpdatePatientEvent(patient: updated));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientBloc, PatientState>(
      listenWhen: (previous, current) =>
          previous is PatientDetailLoaded && current is PatientDetailLoaded,
      listener: (context, state) {
        final currentState = state as PatientDetailLoaded;

        // If the BLoC explicitly says the save was successful, pop the screen!
        if (currentState.saveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Changes saved successfully!')),
          );
          Navigator.pop(context);
        }

        if (!currentState.isBackgroundUpdating &&
            currentState.backgroundError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${currentState.backgroundError}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Patient'),
          centerTitle: true,
          // actions: [TextButton(onPressed: _save, child: const Text('Save'))],
        ),
        body: BlocBuilder<PatientBloc, PatientState>(
          builder: (context, state) {
            if (state is PatientLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is PatientError) {
              return Center(child: Text(state.message));
            }
            if (state is PatientDetailLoaded) {
              _initForm(state.patient);
              return _buildForm();
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return BlocBuilder<PatientBloc, PatientState>(
      builder: (context, state) {
        // 1. Fallback handling if the state isn't loaded yet
        if (state is! PatientDetailLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Safely extract your background loading state flags
        final isLoading = state.isBackgroundUpdating;

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard('Basic Information', [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildGenderField(),
                  SizedBox(height: 16.h),
                  _buildDateOfBirthField(),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                  ),
                ]),
                SizedBox(height: 16.h),
                _buildSectionCard('Location & Occupation', [
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    maxLines: 2,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _stateController,
                          label: 'State',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildTextField(
                          controller: _cityController,
                          label: 'City',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    controller: _occupationController,
                    label: 'Occupation',
                  ),
                ]),
                SizedBox(height: 16.h),
                _buildSectionCard('Medical Info', [
                  _buildDropdownField(
                    label: 'Blood Group',
                    value: _bloodGroup,
                    items: _bloodGroups,
                    onChanged: (v) => setState(() => _bloodGroup = v),
                  ),
                  SizedBox(height: 16.h),
                  _buildDropdownField(
                    label: 'Genotype',
                    value: _genotype,
                    items: _genotypes,
                    onChanged: (v) => setState(() => _genotype = v),
                  ),
                ]),
                SizedBox(height: 16.h),
                _buildAllergiesSection(),
                SizedBox(height: 16.h),
                _buildSectionCard('Emergency Contact', [
                  _buildTextField(
                    controller: _emergencyNameController,
                    label: 'Contact Name',
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    controller: _emergencyPhoneController,
                    label: 'Contact Phone',
                    keyboardType: TextInputType.phone,
                  ),
                ]),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: isLoading ? "Saving Changes..." : "Save Changes",
                    // 3. Disable the button completely if isLoading is true to prevent double submissions
                    onPressed: isLoading ? null : _save,
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(title, style: AppTextStyles.titleLarge),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: AppTextStyles.labelMedium),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _gender,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _gender = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date of Birth', style: AppTextStyles.labelMedium),
        SizedBox(height: 8.h),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dateOfBirth != null
                      ? '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}'
                      : 'Select date',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _dateOfBirth != null
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18.sp,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Select $label',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildAllergiesSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text('Allergies', style: AppTextStyles.titleLarge),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_allergies.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _allergies
                          .map<Widget>(
                            (a) => Chip(
                              label: Text(a),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => _removeAllergy(a),
                              backgroundColor: AppColors.dangerLight,
                              labelStyle: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.danger,
                              ),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44.h,
                        child: TextField(
                          controller: _allergyController,
                          decoration: InputDecoration(
                            hintText: 'Add allergy',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _addAllergy(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton.filled(
                      onPressed: _addAllergy,
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
