import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/services/app_toast.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/tag_input_field.dart';
import '../../data/models/patient_model.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

class CreatePatientPage extends StatefulWidget {
  const CreatePatientPage({super.key});

  @override
  State<CreatePatientPage> createState() => _CreatePatientPageState();
}

class _CreatePatientPageState extends State<CreatePatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  DateTime _dob = DateTime(2000, 1, 1);
  String _gender = 'male';
  String _bloodGroup = 'A+';
  List<String> _allergies = [];
  List<String> _chronicConditions = [];

  final _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final _genders = ['male', 'female', 'other'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _onCreate() {
    if (_formKey.currentState!.validate()) {
      final patient = PatientModel(
        id: '',
        fullName:
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        dob: _dob,
        gender: _gender,
        bloodGroup: _bloodGroup,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        emergencyContactName: _emergencyNameController.text.trim().isEmpty
            ? null
            : _emergencyNameController.text.trim(),
        emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty
            ? null
            : _emergencyPhoneController.text.trim(),
        allergies: _allergies.isNotEmpty ? _allergies.join(', ') : null,
        chronicConditions: _chronicConditions.isNotEmpty
            ? _chronicConditions.join(', ')
            : null,
        isActive: true,
      );
      context.read<PatientBloc>().add(CreatePatientEvent(patient: patient));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Patient')),
      body: BlocConsumer<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state is PatientCreated) {
            AppToast.success(context, title: 'Patient registered successfully');
            context.pop();
          } else if (state is PatientError) {
            AppToast.error(context, title: state.message);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: AppTextStyles.titleMedium,
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLabel(
                                'First Name',
                                isRequired: true,
                                child: AppTextField(
                                  controller: _firstNameController,
                                  hint: 'Enter first name',
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildLabel(
                                'Last Name',
                                isRequired: true,
                                child: AppTextField(
                                  controller: _lastNameController,
                                  hint: 'Enter last name',
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLabel(
                                'Date of Birth',
                                isRequired: true,
                                child: AppTextField(
                                  controller: TextEditingController(
                                    text:
                                        '${_dob.year}-${_dob.month.toString().padLeft(2, '0')}-${_dob.day.toString().padLeft(2, '0')}',
                                  ),
                                  hint: 'Tap to select date',
                                  isReadOnly: true,
                                  onTap: _pickDate,
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildLabel(
                                'Gender',
                                isRequired: true,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _gender,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: const BorderSide(
                                        color: AppColors.divider,
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: const BorderSide(
                                        color: AppColors.divider,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 18.h,
                                    ),
                                  ),
                                  items: _genders
                                      .map(
                                        (g) => DropdownMenuItem(
                                          value: g,
                                          child: Text(
                                            g[0].toUpperCase() + g.substring(1),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _gender = v);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLabel(
                                'Blood Group',
                                child: DropdownButtonFormField<String>(
                                  initialValue: _bloodGroup,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: const BorderSide(
                                        color: AppColors.divider,
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: const BorderSide(
                                        color: AppColors.divider,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 18.h,
                                    ),
                                  ),
                                  items: _bloodGroups
                                      .map(
                                        (bg) => DropdownMenuItem(
                                          value: bg,
                                          child: Text(bg),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _bloodGroup = v);
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildLabel(
                                'Phone',
                                isRequired: true,
                                child: AppTextField(
                                  controller: _phoneController,
                                  hint: 'Enter phone number',
                                  keyboardType: TextInputType.phone,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildLabel(
                          'Address',
                          child: AppTextField(
                            controller: _addressController,
                            hint: 'Enter address (optional)',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Contact',
                          style: AppTextStyles.titleMedium,
                        ),
                        SizedBox(height: 20.h),
                        Column(
                          children: [
                            _buildLabel(
                              'Contact Name',
                              child: AppTextField(
                                controller: _emergencyNameController,
                                hint: 'Emergency contact name',
                              ),
                            ),
                            SizedBox(height: 12.h),
                            _buildLabel(
                              'Contact Phone',
                              child: AppTextField(
                                controller: _emergencyPhoneController,
                                hint: 'Emergency contact phone',
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medical Information',
                          style: AppTextStyles.titleMedium,
                        ),
                        SizedBox(height: 20.h),
                        _buildLabel(
                          'Allergies',
                          child: TagInputField(
                            tags: _allergies,
                            onTagsChanged: (tags) =>
                                setState(() => _allergies = tags),
                            hint: 'Type an allergy and press Add',
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildLabel(
                          'Chronic Conditions',
                          child: TagInputField(
                            tags: _chronicConditions,
                            onTagsChanged: (tags) =>
                                setState(() => _chronicConditions = tags),
                            hint: 'Type a condition and press Add',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  AppButton(
                    label: 'Register Patient',
                    onPressed: state is PatientLoading ? null : _onCreate,
                    isLoading: state is PatientLoading,
                    isDisabled: state is PatientLoading,
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(
    String text, {
    bool isRequired = false,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(text, style: AppTextStyles.titleSmall),
            if (isRequired)
              Text(
                ' *',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            if (!isRequired) Text(' (optional)', style: AppTextStyles.caption),
          ],
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}
