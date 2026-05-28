import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../injection_container.dart' as di;
import '../../../../shared/services/app_toast.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/tag_input_field.dart';
import '../../../../features/refills/presentation/bloc/refill_bloc.dart';
import '../../../../features/refills/presentation/bloc/refill_event.dart';
import '../../../../features/refills/domain/usecases/create_refills_batch_usecase.dart';
import '../../../../features/refills/domain/usecases/get_due_refills_usecase.dart';
import '../../../../features/refills/domain/usecases/mark_refill_contacted_usecase.dart';
import '../../../../features/refills/domain/usecases/mark_refill_fulfilled_usecase.dart';
import '../../data/models/visit_model.dart';
import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';

class ComplaintEntry {
  TextEditingController complaintController;
  TextEditingController durationController;
  ComplaintEntry({String complaint = '', String duration = ''})
      : complaintController = TextEditingController(text: complaint),
        durationController = TextEditingController(text: duration);
}

class TestResultEntry {
  TextEditingController nameController;
  TextEditingController resultController;
  TestResultEntry({String name = '', String result = ''})
      : nameController = TextEditingController(text: name),
          resultController = TextEditingController(text: result);
}

const sigFrequencyCodes = ['OD', 'BD', 'TDS', 'QDS', 'PRN', 'STAT', 'ON', 'OM'];

const sigDoseUnits = ['tablet', 'mg', 'ml', 'capsule', 'drop', 'puff'];

const sigRoutes = ['orally', 'topical', 'IV', 'IM', 'sublingual', 'inhaled', 'rectal', 'vaginal'];

const sigDurationUnits = ['days', 'weeks', 'months'];

const sigFrequencyMap = {
  'OD': 'once daily',
  'BD': 'twice daily',
  'TDS': 'three times daily',
  'QDS': 'four times daily',
  'PRN': 'as needed',
  'STAT': 'immediately',
  'ON': 'once nightly',
  'OM': 'once morning',
};

const sigMultiplierMap = {
  'OD': 1,
  'BD': 2,
  'TDS': 3,
  'QDS': 4,
  'PRN': null,
  'STAT': 1,
  'ON': 1,
  'OM': 1,
};

class DispensedMedication {
  TextEditingController drugNameController;
  TextEditingController doseAmountController;
  String doseUnit;
  String route;
  String frequencyCode;
  TextEditingController frequencyController;
  TextEditingController durationAmountController;
  String durationUnit;
  TextEditingController instructionsController;
  DateTime dateDispensed;
  bool needsRefill;
  DateTime? refillDate;
  bool isRecurrent;
  int? recurrenceIntervalDays;

  DispensedMedication({
    String drugName = '',
    String doseAmount = '',
    this.doseUnit = 'tablet',
    this.route = 'orally',
    this.frequencyCode = 'BD',
    String frequency = '',
    String durationAmount = '',
    this.durationUnit = 'days',
    String instructions = '',
    DateTime? dateDispensed,
    this.needsRefill = false,
    this.refillDate,
    this.isRecurrent = false,
    this.recurrenceIntervalDays,
  }) : drugNameController = TextEditingController(text: drugName),
        doseAmountController = TextEditingController(text: doseAmount),
        frequencyController = TextEditingController(text: frequency),
        durationAmountController = TextEditingController(text: durationAmount),
        instructionsController = TextEditingController(text: instructions),
        dateDispensed = dateDispensed ?? DateTime.now();

  int? get totalQuantity {
    final dose = double.tryParse(doseAmountController.text);
    final duration = int.tryParse(durationAmountController.text);
    if (dose == null || duration == null) return null;
    final mult = sigMultiplierMap[frequencyCode];
    if (mult == null) return null;
    return (dose * mult * duration).round();
  }
}

class CreateVisitPage extends StatefulWidget {
  final String? patientId;

  const CreateVisitPage({super.key, this.patientId});

  @override
  State<CreateVisitPage> createState() => _CreateVisitPageState();
}

class _CreateVisitPageState extends State<CreateVisitPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  DateTime _visitDate = DateTime.now();
  final _visitNumber = 'Auto-generated';

  final _complaints = <ComplaintEntry>[ComplaintEntry()];
  final _pastMeds = <String>[];
  final _currentMeds = <String>[];
  String? _adherence;
  String? _nonAdherenceReason;
  final _nonAdherenceController = TextEditingController();

  final _bpSystolicController = TextEditingController();
  final _bpDiastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _glucoseController = TextEditingController();
  bool _glucoseTypeFasting = true;
  double? _bmi;

  final _testResults = <TestResultEntry>[TestResultEntry()];

  final _diagnosisController = TextEditingController();
  String? _severity;
  final _pharmacistNotesController = TextEditingController();

  final _dispensedMeds = <DispensedMedication>[DispensedMedication()];

  final _counsellingController = TextEditingController();

  bool _followUpRequired = false;
  DateTime? _followUpDate;
  bool _followUpRecurrent = false;
  int? _followUpIntervalDays;

  bool _referPatient = false;
  final _referralDestinationController = TextEditingController();
  final _referralReasonController = TextEditingController();

  late final RefillBloc _refillBloc;
  List<Map<String, dynamic>> _pendingRefillBatch = [];

  @override
  void initState() {
    super.initState();
    _refillBloc = RefillBloc(
      getDueRefillsUseCase: di.sl<GetDueRefillsUseCase>(),
      markRefillContactedUseCase: di.sl<MarkRefillContactedUseCase>(),
      markRefillFulfilledUseCase: di.sl<MarkRefillFulfilledUseCase>(),
      createRefillsBatchUseCase: di.sl<CreateRefillsBatchUseCase>(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nonAdherenceController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _heartRateController.dispose();
    _temperatureController.dispose();
    _spo2Controller.dispose();
    _respiratoryRateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _glucoseController.dispose();
    _diagnosisController.dispose();
    _pharmacistNotesController.dispose();
    _counsellingController.dispose();
    _referralDestinationController.dispose();
    _referralReasonController.dispose();
    for (final c in _complaints) {
      c.complaintController.dispose();
      c.durationController.dispose();
    }
    for (final t in _testResults) {
      t.nameController.dispose();
      t.resultController.dispose();
    }
    for (final m in _dispensedMeds) {
      m.drugNameController.dispose();
      m.doseAmountController.dispose();
      m.frequencyController.dispose();
      m.durationAmountController.dispose();
      m.instructionsController.dispose();
    }
    super.dispose();
  }

  void _onCreate() {
    if (_formKey.currentState!.validate()) {
      final patientId = widget.patientId ?? '';

      final chiefComplaints = _complaints
          .where((c) => c.complaintController.text.isNotEmpty)
          .map((c) => ChiefComplaintItemModel(
                complaint: c.complaintController.text,
                duration: c.durationController.text.isNotEmpty
                    ? c.durationController.text
                    : null,
              ))
          .toList();

      final medicationHistory = _pastMeds.isNotEmpty ||
              _currentMeds.isNotEmpty ||
              _adherence != null
          ? MedicationHistoryDataModel(
              pastMedications: _pastMeds,
              currentMedications: _currentMeds,
              adherence: _adherence,
              nonAdherenceReason:
                  _adherence == 'No' ? _nonAdherenceReason : null,
            )
          : null;

      final bpSys = int.tryParse(_bpSystolicController.text);
      final bpDia = int.tryParse(_bpDiastolicController.text);
      final vitals = (bpSys != null || bpDia != null ||
              _heartRateController.text.isNotEmpty ||
              _temperatureController.text.isNotEmpty ||
              _spo2Controller.text.isNotEmpty ||
              _respiratoryRateController.text.isNotEmpty ||
              _weightController.text.isNotEmpty ||
              _heightController.text.isNotEmpty ||
              _glucoseController.text.isNotEmpty)
          ? VitalsDataModel(
              bloodPressureSystolic: bpSys,
              bloodPressureDiastolic: bpDia,
              heartRate: int.tryParse(_heartRateController.text),
              temperature: double.tryParse(_temperatureController.text),
              spo2: int.tryParse(_spo2Controller.text),
              respiratoryRate: int.tryParse(_respiratoryRateController.text),
              weight: double.tryParse(_weightController.text),
              height: double.tryParse(_heightController.text),
              bmi: _bmi,
              glucose: double.tryParse(_glucoseController.text),
              glucoseType: _glucoseController.text.isNotEmpty
                  ? (_glucoseTypeFasting ? 'Fasting' : 'Random')
                  : null,
            )
          : null;

      final testResults = _testResults
          .where((t) => t.nameController.text.isNotEmpty)
          .map((t) => TestResultItemModel(
                testName: t.nameController.text,
                result: t.resultController.text.isNotEmpty
                    ? t.resultController.text
                    : null,
              ))
          .toList();

      final clinicalAssessment = _diagnosisController.text.isNotEmpty ||
              _severity != null ||
              _pharmacistNotesController.text.isNotEmpty
          ? ClinicalAssessmentDataModel(
              diagnosis: _diagnosisController.text.trim().isNotEmpty
                  ? _diagnosisController.text.trim()
                  : null,
              severity: _severity,
              pharmacistNotes: _pharmacistNotesController.text.isNotEmpty
                  ? _pharmacistNotesController.text.trim()
                  : null,
            )
          : null;

      final medicationsDispensed = _dispensedMeds
          .where((m) => m.drugNameController.text.isNotEmpty)
          .map((m) {
        final doseAmount = double.tryParse(m.doseAmountController.text);
        final durationAmount = int.tryParse(m.durationAmountController.text);
        final freqText = m.frequencyController.text.isNotEmpty
            ? m.frequencyController.text
            : (sigFrequencyMap[m.frequencyCode] ?? '');
        return MedicationDispensedDataModel(
          drugName: m.drugNameController.text,
          doseAmount: doseAmount,
          doseUnit: m.doseUnit.isNotEmpty ? m.doseUnit : null,
          route: m.route.isNotEmpty ? m.route : null,
          frequency: freqText.isNotEmpty ? freqText : null,
          frequencyCode: m.frequencyCode.isNotEmpty ? m.frequencyCode : null,
          durationAmount: durationAmount,
          durationUnit: m.durationUnit.isNotEmpty ? m.durationUnit : null,
          totalQuantity: m.totalQuantity,
          instructions: m.instructionsController.text.isNotEmpty
              ? m.instructionsController.text
              : null,
          dateDispensed: m.dateDispensed,
          refillDate: m.needsRefill ? m.refillDate : null,
          isRecurrent: m.needsRefill ? m.isRecurrent : false,
          recurrenceIntervalDays: m.needsRefill ? m.recurrenceIntervalDays : null,
        );
      }).toList();

      _pendingRefillBatch = _dispensedMeds
          .where((m) =>
              m.drugNameController.text.isNotEmpty && m.needsRefill)
          .map((m) {
        final doseAmount = double.tryParse(m.doseAmountController.text);
        final durationAmount = int.tryParse(m.durationAmountController.text);
        final freqText = m.frequencyController.text.isNotEmpty
            ? m.frequencyController.text
            : (sigFrequencyMap[m.frequencyCode] ?? '');
        return {
          'visit_id': '',
          'patient_id': patientId,
          'drug_name': m.drugNameController.text,
          'dose_amount': doseAmount,
          'dose_unit': m.doseUnit,
          'route': m.route,
          'frequency': freqText,
          'frequency_code': m.frequencyCode,
          'duration_amount': durationAmount,
          'duration_unit': m.durationUnit,
          'total_quantity': m.totalQuantity,
          'instructions': m.instructionsController.text.isNotEmpty
              ? m.instructionsController.text
              : null,
          'refill_date': m.refillDate != null
              ? DateFormat('yyyy-MM-dd').format(m.refillDate!)
              : '',
          'is_recurrent': m.isRecurrent,
          'recurrence_interval_days': m.recurrenceIntervalDays,
        };
      }).toList();

      final followUp = _followUpRequired
          ? FollowUpDataModel(
              required: true,
              scheduledDate: _followUpDate,
              isRecurrent: _followUpRecurrent,
              recurrenceIntervalDays: _followUpIntervalDays,
            )
          : null;

      final referral = _referPatient
          ? ReferralDataModel(
              destination: _referralDestinationController.text.isNotEmpty
                  ? _referralDestinationController.text
                  : null,
              reason: _referralReasonController.text.isNotEmpty
                  ? _referralReasonController.text
                  : null,
            )
          : null;

      final visit = VisitModel(
        id: '',
        patientId: patientId,
        staffId: '',
        visitDate: _visitDate,
        status: 'active',
        visitNumber: _visitNumber,
        chiefComplaints: chiefComplaints,
        medicationHistory: medicationHistory,
        vitals: vitals,
        testResults: testResults,
        clinicalAssessment: clinicalAssessment,
        medicationsDispensed: medicationsDispensed,
        counsellingAdvice: _counsellingController.text.isNotEmpty
            ? _counsellingController.text.trim()
            : null,
        followUp: followUp,
        referral: referral,
      );

      context
          .read<VisitBloc>()
          .add(CreateVisitEvent(visit: visit));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Visit')),
      body:       BlocListener<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitCreated) {
            if (_pendingRefillBatch.isNotEmpty) {
              final visitId = state.visit.id;
              for (final med in _pendingRefillBatch) {
                med['visit_id'] = visitId;
              }
              _refillBloc.add(CreateRefillsBatch(
                medications: _pendingRefillBatch,
              ));
            }
            AppToast.success(context, title: 'Visit created successfully');
            if (context.mounted) context.pop();
          } else if (state is VisitError) {
            AppToast.error(context, title: state.message);
          }
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Visit Info'),
                buildDivider(),
                SizedBox(height: 12.h),
                _buildDatePicker(),
                SizedBox(height: 12.h),
                AppTextField(
                  controller: TextEditingController(text: _visitNumber),
                  label: 'Visit Number',
                  isReadOnly: true,
                ),
                SizedBox(height: 24.h),

                _buildSectionHeader('Chief Complaints'),
                buildDivider(),
                SizedBox(height: 12.h),
                ..._complaints.asMap().entries.map((entry) {
                  final i = entry.key;
                  final c = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: c.complaintController,
                            hint: 'Complaint',
                            label: 'Chief Complaint',
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Complaint is required'
                                : null,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: AppTextField(
                            controller: c.durationController,
                            hint: 'Duration',
                          ),
                        ),
                        if (_complaints.length > 1)
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                size: 20.sp, color: AppColors.danger),
                            onPressed: () => setState(() => _complaints.removeAt(i)),
                          ),
                      ],
                    ),
                  );
                }),
                AppButton(
                  label: 'Add Complaint',
                  variant: AppButtonVariant.outline,
                  onPressed: () => setState(() => _complaints.add(ComplaintEntry())),
                  height: 36.h,
                ),
                SizedBox(height: 24.h),

                _buildSectionHeader('Medication History'),
                buildDivider(),
                SizedBox(height: 12.h),
                Text('Past Medications', style: AppTextStyles.titleSmall),
                SizedBox(height: 8.h),
                TagInputField(
                  tags: _pastMeds,
                  onTagsChanged: (v) => _pastMeds..clear()..addAll(v),
                  hint: 'Add past medication',
                ),
                SizedBox(height: 16.h),
                Text('Current Medications', style: AppTextStyles.titleSmall),
                SizedBox(height: 8.h),
                TagInputField(
                  tags: _currentMeds,
                  onTagsChanged: (v) => _currentMeds..clear()..addAll(v),
                  hint: 'Add current medication',
                ),
                SizedBox(height: 16.h),
                Text('Adherence', style: AppTextStyles.titleSmall),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  value: _adherence,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 10.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide:
                          const BorderSide(color: AppColors.border, width: 1.5),
                    ),
                  ),
                  hint: Text('Select adherence',
                      style: AppTextStyles.bodySmall),
                  items: ['Yes', 'Partially', 'No']
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (v) => setState(() => _adherence = v),
                ),
                if (_adherence == 'No') ...[
                  SizedBox(height: 12.h),
                  AppTextField(
                    controller: _nonAdherenceController,
                    hint: 'Reason for non-adherence',
                    onChanged: (v) => _nonAdherenceReason = v,
                  ),
                ],
                SizedBox(height: 24.h),

                _buildSectionHeader('Vitals'),
                buildDivider(),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _bpSystolicController,
                        label: 'BP Systolic (mmHg)',
                        hint: '120',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppTextField(
                        controller: _bpDiastolicController,
                        label: 'BP Diastolic (mmHg)',
                        hint: '80',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _heartRateController,
                        label: 'Heart Rate (bpm)',
                        hint: '72',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppTextField(
                        controller: _temperatureController,
                        label: 'Temperature (°C)',
                        hint: '36.5',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _spo2Controller,
                        label: 'SpO2 (%)',
                        hint: '98',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppTextField(
                        controller: _respiratoryRateController,
                        label: 'Resp. Rate (breaths/min)',
                        hint: '16',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _weightController,
                        label: 'Weight (kg)',
                        hint: '70',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateBmi(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppTextField(
                        controller: _heightController,
                        label: 'Height (cm)',
                        hint: '175',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateBmi(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Blood Glucose', style: AppTextStyles.titleSmall),
                          SizedBox(height: 4.h),
                          AppTextField(
                            controller: _glucoseController,
                            hint: '5.5',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type', style: AppTextStyles.titleSmall),
                          SizedBox(height: 4.h),
                          ToggleButtons(
                            isSelected: [_glucoseTypeFasting, !_glucoseTypeFasting],
                            onPressed: (i) => setState(
                                () => _glucoseTypeFasting = i == 0),
                            borderRadius: BorderRadius.circular(10.r),
                            selectedColor: AppColors.white,
                            fillColor: AppColors.primary,
                            constraints: BoxConstraints(
                                minWidth: 60.w, minHeight: 36.h),
                            textStyle: AppTextStyles.labelMedium,
                            children: [
                              Text('Fasting'),
                              Text('Random'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_bmi != null) ...[
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: TextEditingController(
                        text: _bmi!.toStringAsFixed(1)),
                    label: 'BMI (auto-calculated)',
                    isReadOnly: true,
                  ),
                ],
                SizedBox(height: 24.h),

                _buildSectionHeader('Test Results'),
                buildDivider(),
                SizedBox(height: 12.h),
                ..._testResults.asMap().entries.map((entry) {
                  final i = entry.key;
                  final t = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: t.nameController,
                            hint: 'Test name',
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: AppTextField(
                            controller: t.resultController,
                            hint: 'Result',
                          ),
                        ),
                        if (_testResults.length > 1)
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                size: 20.sp, color: AppColors.danger),
                            onPressed: () =>
                                setState(() => _testResults.removeAt(i)),
                          ),
                      ],
                    ),
                  );
                }),
                AppButton(
                  label: 'Add Test',
                  variant: AppButtonVariant.outline,
                  onPressed: () =>
                      setState(() => _testResults.add(TestResultEntry())),
                  height: 36.h,
                ),
                SizedBox(height: 24.h),

                _buildSectionHeader('Clinical Assessment'),
                buildDivider(),
                SizedBox(height: 12.h),
                AppTextField(
                  controller: _diagnosisController,
                  label: 'Suspected Diagnosis',
                  hint: 'Enter diagnosis',
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Diagnosis is required'
                      : null,
                ),
                SizedBox(height: 12.h),
                Text('Severity', style: AppTextStyles.titleSmall),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  value: _severity,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 10.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide:
                          const BorderSide(color: AppColors.border, width: 1.5),
                    ),
                  ),
                  hint: Text('Select severity',
                      style: AppTextStyles.bodySmall),
                  items: ['Mild', 'Moderate', 'Severe']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _severity = v),
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  controller: _pharmacistNotesController,
                  label: 'Pharmacist Notes',
                  hint: 'Enter clinical notes',
                  maxLines: 3,
                ),
                SizedBox(height: 24.h),

                _buildSectionHeader('Medications Dispensed'),
                buildDivider(),
                SizedBox(height: 12.h),
                ..._dispensedMeds.asMap().entries.map((entry) {
                  final i = entry.key;
                  final m = entry.value;
                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        AppTextField(
                          controller: m.drugNameController,
                          hint: 'e.g. Amoxicillin',
                          label: 'Drug Name',
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: AppTextField(
                                controller: m.doseAmountController,
                                hint: 'e.g. 2',
                                label: 'Dose Amount',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                value: m.doseUnit,
                                decoration: _sigDropdownDecoration(),
                                hint: Text('Unit', style: AppTextStyles.bodySmall),
                                items: sigDoseUnits
                                    .map((u) => DropdownMenuItem(
                                        value: u, child: Text(u)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => m.doseUnit = v);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: m.route,
                                decoration: _sigDropdownDecoration(),
                                hint: Text('Route', style: AppTextStyles.bodySmall),
                                items: sigRoutes
                                    .map((r) => DropdownMenuItem(
                                        value: r, child: Text(r)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => m.route = v);
                                },
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: m.frequencyCode,
                                decoration: _sigDropdownDecoration(),
                                hint: Text('Freq Code', style: AppTextStyles.bodySmall),
                                items: sigFrequencyCodes
                                    .map((c) => DropdownMenuItem(
                                        value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() {
                                      m.frequencyCode = v;
                                      final label = sigFrequencyMap[v];
                                      if (label != null) {
                                        m.frequencyController.text = label;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: m.frequencyController,
                                hint: 'e.g. twice daily',
                                label: 'Frequency',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: AppTextField(
                                controller: m.durationAmountController,
                                hint: 'e.g. 7',
                                label: 'Duration',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                value: m.durationUnit,
                                decoration: _sigDropdownDecoration(),
                                hint: Text('Unit', style: AppTextStyles.bodySmall),
                                items: sigDurationUnits
                                    .map((u) => DropdownMenuItem(
                                        value: u, child: Text(u)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => m.durationUnit = v);
                                },
                              ),
                            ),
                          ],
                        ),
                        if (m.totalQuantity != null) ...[
                          SizedBox(height: 8.h),
                          AppTextField(
                            controller: TextEditingController(
                                text: m.totalQuantity.toString()),
                            label: 'Total Quantity (auto-calc)',
                            isReadOnly: true,
                          ),
                        ],
                        SizedBox(height: 8.h),
                        _buildMedDatePicker(
                          label: 'Date Dispensed',
                          date: m.dateDispensed,
                          onPicked: (d) => setState(() => m.dateDispensed = d),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Text('Needs Refill',
                                style: AppTextStyles.titleSmall.copyWith(
                                    fontSize: 12.sp)),
                            Spacer(),
                            Switch(
                              value: m.needsRefill,
                              activeThumbColor: AppColors.primary,
                              onChanged: (v) => setState(() {
                                m.needsRefill = v;
                                if (v && m.refillDate == null) {
                                  m.refillDate = DateTime.now().add(
                                      const Duration(days: 30));
                                }
                              }),
                            ),
                          ],
                        ),
                        if (m.needsRefill) ...[
                          SizedBox(height: 8.h),
                          _buildMedRefillPicker(m),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Text('Recurrent refill',
                                  style: AppTextStyles.titleSmall.copyWith(
                                      fontSize: 12.sp)),
                              Spacer(),
                              Switch(
                                value: m.isRecurrent,
                                activeThumbColor: AppColors.primary,
                                onChanged: (v) => setState(() {
                                  m.isRecurrent = v;
                                  if (v) m.recurrenceIntervalDays = 30;
                                }),
                              ),
                            ],
                          ),
                          if (m.isRecurrent) ...[
                            SizedBox(height: 8.h),
                            DropdownButtonFormField<int>(
                              value: m.recurrenceIntervalDays,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.white,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 10.h),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: const BorderSide(
                                      color: AppColors.border, width: 1.5),
                                ),
                              ),
                              hint: Text('Select interval',
                                  style: AppTextStyles.bodySmall),
                              items: const [
                                DropdownMenuItem(
                                    value: 7, child: Text('Every 7 days')),
                                DropdownMenuItem(
                                    value: 14, child: Text('Every 14 days')),
                                DropdownMenuItem(
                                    value: 30, child: Text('Every 30 days')),
                                DropdownMenuItem(
                                    value: 90, child: Text('Every 90 days')),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(
                                      () => m.recurrenceIntervalDays = v);
                                }
                              },
                            ),
                          ],
                        ],
                        SizedBox(height: 8.h),
                        AppTextField(
                          controller: m.instructionsController,
                          hint: 'e.g. take after food',
                          label: 'Instructions',
                        ),
                        if (_dispensedMeds.length > 1)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => setState(
                                  () => _dispensedMeds.removeAt(i)),
                              child: Text('Remove',
                                  style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.danger)),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                AppButton(
                  label: 'Add Medication',
                  variant: AppButtonVariant.outline,
                  onPressed: () => setState(
                      () => _dispensedMeds.add(DispensedMedication())),
                  height: 36.h,
                ),
                SizedBox(height: 24.h),

                _buildSectionHeader('Counselling & Advice'),
                buildDivider(),
                SizedBox(height: 12.h),
                AppTextField(
                  controller: _counsellingController,
                  hint: 'Enter counselling notes and advice',
                  maxLines: 4,
                ),
                SizedBox(height: 24.h),

                _buildSectionHeader('Follow-up'),
                buildDivider(),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text('Follow-up required',
                        style: AppTextStyles.titleSmall),
                    Spacer(),
                    Switch(
                      value: _followUpRequired,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) =>
                          setState(() => _followUpRequired = v),
                    ),
                  ],
                ),
                if (_followUpRequired) ...[
                  SizedBox(height: 12.h),
                  _buildDatePickerGeneric(
                    label: 'Follow-up Date',
                    date: _followUpDate,
                    onPicked: (d) => setState(() => _followUpDate = d),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Text('Recurrent follow-up',
                          style: AppTextStyles.titleSmall),
                      Spacer(),
                      Switch(
                        value: _followUpRecurrent,
                        activeThumbColor: AppColors.primary,
                        onChanged: (v) => setState(() {
                          _followUpRecurrent = v;
                          if (v) _followUpIntervalDays = 30;
                        }),
                      ),
                    ],
                  ),
                  if (_followUpRecurrent) ...[
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<int>(
                      value: _followUpIntervalDays,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 10.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                              color: AppColors.border, width: 1.5),
                        ),
                      ),
                      hint: Text('Select interval',
                          style: AppTextStyles.bodySmall),
                      items: const [
                        DropdownMenuItem(value: 7, child: Text('Every 7 days')),
                        DropdownMenuItem(value: 14, child: Text('Every 14 days')),
                        DropdownMenuItem(value: 30, child: Text('Every 30 days')),
                        DropdownMenuItem(value: 90, child: Text('Every 90 days')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _followUpIntervalDays = v);
                      },
                    ),
                  ],
                ],
                SizedBox(height: 24.h),

                _buildSectionHeader('Referral'),
                buildDivider(),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text('Refer patient', style: AppTextStyles.titleSmall),
                    Spacer(),
                    Switch(
                      value: _referPatient,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => setState(() => _referPatient = v),
                    ),
                  ],
                ),
                if (_referPatient) ...[
                  SizedBox(height: 12.h),
                  AppTextField(
                    controller: _referralDestinationController,
                    label: 'Destination',
                    hint: 'Enter referral destination',
                  ),
                  SizedBox(height: 12.h),
                  AppTextField(
                    controller: _referralReasonController,
                    label: 'Reason',
                    hint: 'Enter referral reason',
                    maxLines: 2,
                  ),
                ],
                SizedBox(height: 32.h),

                Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<VisitBloc, VisitState>(
                        builder: (context, state) {
                          return AppButton(
                            label: 'Complete Visit',
                            onPressed: state is VisitLoading ? null : _onCreate,
                            isLoading: state is VisitLoading,
                            isDisabled: state is VisitLoading,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppButton(
                        label: 'Refer Patient',
                        variant: AppButtonVariant.outline,
                        onPressed: () {
                          setState(() => _referPatient = true);
                          _onCreate();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textHint,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget buildDivider() {
    return Divider(color: AppColors.border, height: 1);
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _visitDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) setState(() => _visitDate = picked);
      },
      child: AbsorbPointer(
        child: AppTextField(
          controller: TextEditingController(
            text: DateFormat('yyyy-MM-dd').format(_visitDate),
          ),
          label: 'Visit Date',
          suffixIcon: Icon(Icons.calendar_today_outlined,
              size: 18.sp, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildMedDatePicker({
    required String label,
    required DateTime date,
    required ValueChanged<DateTime> onPicked,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onPicked(picked);
      },
      child: AbsorbPointer(
        child: AppTextField(
          controller: TextEditingController(
            text: DateFormat('yyyy-MM-dd').format(date),
          ),
          label: label,
          suffixIcon: Icon(Icons.calendar_today_outlined,
              size: 18.sp, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildDatePickerGeneric({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onPicked,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onPicked(picked);
      },
      child: AbsorbPointer(
        child: AppTextField(
          controller: TextEditingController(
            text: date != null ? DateFormat('yyyy-MM-dd').format(date) : '',
          ),
          label: label,
          suffixIcon: Icon(Icons.calendar_today_outlined,
              size: 18.sp, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildMedRefillPicker(DispensedMedication m) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: m.refillDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) setState(() => m.refillDate = picked);
      },
      child: AbsorbPointer(
        child: AppTextField(
          controller: TextEditingController(
            text: m.refillDate != null
                ? DateFormat('yyyy-MM-dd').format(m.refillDate!)
                : '',
          ),
          label: 'Refill Date',
          suffixIcon: Icon(Icons.calendar_today_outlined,
              size: 18.sp, color: AppColors.primary),
        ),
      ),
    );
  }

  InputDecoration _sigDropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.white,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
    );
  }

  void _calculateBmi() {
    final wt = double.tryParse(_weightController.text);
    final ht = double.tryParse(_heightController.text);
    if (wt != null && ht != null && ht > 0) {
      setState(() => _bmi = wt / ((ht / 100) * (ht / 100)));
    }
  }

}
