import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/services/app_toast.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
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
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _chronicConditionsController = TextEditingController();
  DateTime _dob = DateTime(2000, 1, 1);
  String _gender = 'male';
  String _bloodGroup = 'A+';

  final _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final _genders = ['male', 'female', 'other'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _allergiesController.dispose();
    _chronicConditionsController.dispose();
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
        fullName: _nameController.text.trim(),
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
        allergies: _allergiesController.text.trim().isEmpty
            ? null
            : _allergiesController.text.trim(),
        chronicConditions: _chronicConditionsController.text.trim().isEmpty
            ? null
            : _chronicConditionsController.text.trim(),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Full Name', style: AppTextStyles.titleSmall),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _nameController,
                    hint: 'Enter full name',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  SizedBox(height: 16.h),
                  Text('Date of Birth', style: AppTextStyles.titleSmall),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: TextEditingController(
                      text: '${_dob.year}-${_dob.month.toString().padLeft(2, '0')}-${_dob.day.toString().padLeft(2, '0')}',
                    ),
                    hint: 'Tap to select date',
                    isReadOnly: true,
                    onTap: _pickDate,
                    validator: (v) => v == null || v.isEmpty ? 'Date is required' : null,
                  ),
                  SizedBox(height: 16.h),
                  Text('Gender', style: AppTextStyles.titleSmall),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    items: _genders.map((g) => DropdownMenuItem(
                      value: g,
                      child: Text(g[0].toUpperCase() + g.substring(1)),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _gender = v);
                    },
                  ),
                  SizedBox(height: 16.h),
                  Text('Blood Group', style: AppTextStyles.titleSmall),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: _bloodGroup,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    items: _bloodGroups.map((bg) => DropdownMenuItem(
                      value: bg,
                      child: Text(bg),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _bloodGroup = v);
                    },
                  ),
                  SizedBox(height: 16.h),
                  Text('Phone', style: AppTextStyles.titleSmall),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _phoneController,
                    hint: 'Enter phone number',
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Phone is required' : null,
                  ),
                  SizedBox(height: 16.h),
                  Text('Address', style: AppTextStyles.titleSmall),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _addressController,
                    hint: 'Enter address (optional)',
                  ),
                  SizedBox(height: 16.h),
                  Text('Emergency Contact Name', style: AppTextStyles.titleSmall),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _emergencyNameController,
                    hint: 'Emergency contact name (optional)',
                  ),
                  SizedBox(height: 16.h),
                  Text('Emergency Contact Phone', style: AppTextStyles.titleSmall),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _emergencyPhoneController,
                    hint: 'Emergency contact phone (optional)',
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16.h),
                  Text('Allergies', style: AppTextStyles.titleSmall),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _allergiesController,
                    hint: 'List allergies (optional)',
                    maxLines: 2,
                  ),
                  SizedBox(height: 16.h),
                  Text('Chronic Conditions', style: AppTextStyles.titleSmall),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _chronicConditionsController,
                    hint: 'List chronic conditions (optional)',
                    maxLines: 2,
                  ),
                  SizedBox(height: 32.h),
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
}
