import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/services/app_toast.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/tag_input_field.dart';
import '../../data/models/visit_model.dart';
import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';
import '../../domain/entities/visit.dart';

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
const sigRoutes = [
  'orally',
  'topical',
  'IV',
  'IM',
  'sublingual',
  'inhaled',
  'rectal',
  'vaginal',
];
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

  void dispose() {
    drugNameController.dispose();
    doseAmountController.dispose();
    frequencyController.dispose();
    durationAmountController.dispose();
    instructionsController.dispose();
  }
}

class EditVisitPage extends StatefulWidget {
  final String visitId;

  const EditVisitPage({super.key, required this.visitId});

  @override
  State<EditVisitPage> createState() => _EditVisitPageState();
}

class _EditVisitPageState extends State<EditVisitPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _isInitialized = false;

  DateTime _visitDate = DateTime.now();

  final _complaints = <ComplaintEntry>[ComplaintEntry()];
  List<String> _pastMeds = [];
  List<String> _currentMeds = [];
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitBloc>().add(GetVisitDetailEvent(id: widget.visitId));
    });
  }

  void _initForm(Visit visit) {
    if (_isInitialized) return;
    _isInitialized = true;

    _visitDate = visit.visitDate;

    _complaints.clear();
    if (visit.chiefComplaints.isNotEmpty) {
      for (final c in visit.chiefComplaints) {
        _complaints.add(
          ComplaintEntry(
            complaint: c.complaint ?? '',
            duration: c.duration ?? '',
          ),
        );
      }
    } else {
      _complaints.add(ComplaintEntry());
    }

    final mh = visit.medicationHistory;
    if (mh != null) {
      _pastMeds.addAll(mh.pastMedications);
      _currentMeds.addAll(mh.currentMedications);
      _adherence = mh.adherence;
      _nonAdherenceReason = mh.nonAdherenceReason;
      if (_nonAdherenceReason != null) {
        _nonAdherenceController.text = _nonAdherenceReason!;
      }
    }

    final v = visit.vitals;
    if (v != null) {
      _bpSystolicController.text = v.bloodPressureSystolic?.toString() ?? '';
      _bpDiastolicController.text = v.bloodPressureDiastolic?.toString() ?? '';
      _heartRateController.text = v.heartRate?.toString() ?? '';
      _temperatureController.text = v.temperature?.toString() ?? '';
      _spo2Controller.text = v.spo2?.toString() ?? '';
      _respiratoryRateController.text = v.respiratoryRate?.toString() ?? '';
      _weightController.text = v.weight?.toString() ?? '';
      _heightController.text = v.height?.toString() ?? '';
      _glucoseController.text = v.glucose?.toString() ?? '';
      _glucoseTypeFasting = v.glucoseType != 'Random';
      _bmi = v.bmi;
    }

    _testResults.clear();
    if (visit.testResults.isNotEmpty) {
      for (final t in visit.testResults) {
        _testResults.add(
          TestResultEntry(name: t.testName ?? '', result: t.result ?? ''),
        );
      }
    } else {
      _testResults.add(TestResultEntry());
    }

    final ca = visit.clinicalAssessment;
    if (ca != null) {
      _diagnosisController.text = ca.diagnosis ?? '';
      _severity = ca.severity;
      _pharmacistNotesController.text = ca.pharmacistNotes ?? '';
    }

    _dispensedMeds.clear();
    if (visit.medicationsDispensed.isNotEmpty) {
      for (final m in visit.medicationsDispensed) {
        _dispensedMeds.add(
          DispensedMedication(
            drugName: m.drugName ?? '',
            doseAmount: m.doseAmount?.toString() ?? '',
            doseUnit: m.doseUnit ?? 'tablet',
            route: m.route ?? 'orally',
            frequencyCode: m.frequencyCode ?? 'BD',
            frequency: m.frequency ?? '',
            durationAmount: m.durationAmount?.toString() ?? '',
            durationUnit: m.durationUnit ?? 'days',
            instructions: m.instructions ?? '',
            dateDispensed: m.dateDispensed,
            needsRefill: m.refillDate != null,
            refillDate: m.refillDate,
            isRecurrent: m.isRecurrent,
            recurrenceIntervalDays: m.recurrenceIntervalDays,
          ),
        );
      }
    } else {
      _dispensedMeds.add(DispensedMedication());
    }

    _counsellingController.text = visit.counsellingAdvice ?? '';

    final fu = visit.followUp;
    if (fu != null) {
      _followUpRequired = fu.required;
      _followUpDate = fu.scheduledDate;
      _followUpRecurrent = fu.isRecurrent;
      _followUpIntervalDays = fu.recurrenceIntervalDays;
    }

    final ref = visit.referral;
    if (ref != null) {
      _referPatient = ref.isReferred;
      _referralDestinationController.text = ref.destination ?? '';
      _referralReasonController.text = ref.reason ?? '';
    }

    // setState(() {});
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
      m.dispose();
    }
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final chiefComplaints = _complaints
        .where((c) => c.complaintController.text.isNotEmpty)
        .map(
          (c) => ChiefComplaintItemModel(
            complaint: c.complaintController.text,
            duration: c.durationController.text.isNotEmpty
                ? c.durationController.text
                : null,
          ),
        )
        .toList();

    final medicationHistory =
        _pastMeds.isNotEmpty || _currentMeds.isNotEmpty || _adherence != null
        ? MedicationHistoryDataModel(
            pastMedications: _pastMeds,
            currentMedications: _currentMeds,
            adherence: _adherence,
            nonAdherenceReason: _adherence == 'No' ? _nonAdherenceReason : null,
          )
        : null;

    final bpSys = int.tryParse(_bpSystolicController.text);
    final bpDia = int.tryParse(_bpDiastolicController.text);
    final vitals =
        (bpSys != null ||
            bpDia != null ||
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
        .map(
          (t) => TestResultItemModel(
            testName: t.nameController.text,
            result: t.resultController.text.isNotEmpty
                ? t.resultController.text
                : null,
          ),
        )
        .toList();

    final clinicalAssessment =
        _diagnosisController.text.isNotEmpty ||
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
            recurrenceIntervalDays: m.needsRefill
                ? m.recurrenceIntervalDays
                : null,
          );
        })
        .toList();

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
            isReferred: true,
            destination: _referralDestinationController.text.isNotEmpty
                ? _referralDestinationController.text
                : null,
            reason: _referralReasonController.text.isNotEmpty
                ? _referralReasonController.text
                : null,
          )
        : null;

    final blocState = context.read<VisitBloc>().state;
    if (blocState is! VisitDetailLoaded) return;
    final visit = blocState.visit;

    final updated = VisitModel(
      id: visit.id,
      patientId: visit.patientId,
      staffId: visit.staffId,
      visitNumber: visit.visitNumber,
      visitDate: _visitDate,
      status: visit.status,
      chiefComplaints: chiefComplaints,
      medicationHistory: medicationHistory,
      vitals: vitals,
      testResults: testResults,
      clinicalAssessment: clinicalAssessment,
      medicationsDispensed: medicationsDispensed,
      counsellingAdvice: _counsellingController.text.isNotEmpty
          ? _counsellingController.text
          : null,
      followUp: followUp,
      referral: referral,
    );

    context.read<VisitBloc>().add(
      UpdateVisitEvent(id: widget.visitId, visit: updated),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Visit')),
      body: BlocConsumer<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitUpdated) {
            AppToast.success(context, title: 'Visit updated');
            context.pop();
          } else if (state is VisitError) {
            AppToast.error(context, title: state.message);
          }
        },
        builder: (context, state) {
          if (state is VisitLoading && !_isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VisitError && !_isInitialized) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: AppTextStyles.bodyMedium),
                  SizedBox(height: 16.h),
                  AppButton(
                    label: 'Retry',
                    onPressed: () => context.read<VisitBloc>().add(
                      GetVisitDetailEvent(id: widget.visitId),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is VisitDetailLoaded) {
            final visit = state.visit;
            if (!_isInitialized) _initForm(visit);

            final isSaving = state.isBackgroundUpdating;

            return AbsorbPointer(
              absorbing: isSaving,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isSaving) ...[
                        const LinearProgressIndicator(
                          color: AppColors.primary,
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(height: 12.h),
                      ],

                      _buildSectionHeader('Visit Info'),
                      _buildDivider(),
                      SizedBox(height: 12.h),
                      _buildDatePicker(),
                      SizedBox(height: 24.h),

                      _buildSectionHeader('Chief Complaints'),
                      _buildDivider(),
                      SizedBox(height: 8.h),
                      ..._complaints.asMap().entries.map((entry) {
                        final i = entry.key;
                        final c = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: AppTextField(
                                  controller: c.complaintController,
                                  hint: 'e.g. headache',
                                  label: 'Complaint',
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  controller: c.durationController,
                                  hint: 'e.g. 3 days',
                                  label: 'Duration',
                                ),
                              ),
                              if (_complaints.length > 1)
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: AppColors.danger,
                                  ),
                                  onPressed: () =>
                                      setState(() => _complaints.removeAt(i)),
                                ),
                            ],
                          ),
                        );
                      }),
                      AppButton(
                        label: 'Add Complaint',
                        variant: AppButtonVariant.outline,
                        onPressed: () =>
                            setState(() => _complaints.add(ComplaintEntry())),
                        height: 36.h,
                      ),
                      SizedBox(height: 24.h),

                      _buildSectionHeader('Medication History'),
                      _buildDivider(),
                      SizedBox(height: 12.h),
                      TagInputField(
                        hint: 'Type and press Enter',
                        tags: _pastMeds,
                        onTagsChanged: (v) => setState(() => _pastMeds = v),
                      ),
                      SizedBox(height: 12.h),
                      TagInputField(
                        hint: 'Type and press Enter',
                        tags: _currentMeds,
                        onTagsChanged: (v) => setState(() => _currentMeds = v),
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        value: _adherence,
                        decoration: _dropdownDecoration('Adherence'),
                        items: const [
                          DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                          DropdownMenuItem(value: 'No', child: Text('No')),
                          DropdownMenuItem(
                            value: 'Partial',
                            child: Text('Partial'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _adherence = v),
                      ),
                      if (_adherence == 'No') ...[
                        SizedBox(height: 8.h),
                        AppTextField(
                          controller: _nonAdherenceController,
                          hint: 'Reason for non-adherence',
                          label: 'Non-adherence Reason',
                        ),
                      ],
                      SizedBox(height: 24.h),

                      _buildSectionHeader('Vitals'),
                      _buildDivider(),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _bpSystolicController,
                              hint: 'e.g. 120',
                              label: 'BP Systolic',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: AppTextField(
                              controller: _bpDiastolicController,
                              hint: 'e.g. 80',
                              label: 'BP Diastolic',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _heartRateController,
                              hint: 'e.g. 72',
                              label: 'Heart Rate',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: AppTextField(
                              controller: _temperatureController,
                              hint: 'e.g. 36.5',
                              label: 'Temperature (°C)',
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _spo2Controller,
                              hint: 'e.g. 98',
                              label: 'SpO₂',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: AppTextField(
                              controller: _respiratoryRateController,
                              hint: 'e.g. 16',
                              label: 'Respiratory Rate',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _weightController,
                              hint: 'e.g. 70',
                              label: 'Weight (kg)',
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (_) => _calculateBmi(),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: AppTextField(
                              controller: _heightController,
                              hint: 'e.g. 175',
                              label: 'Height (cm)',
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (_) => _calculateBmi(),
                            ),
                          ),
                        ],
                      ),
                      if (_bmi != null) ...[
                        SizedBox(height: 8.h),
                        AppTextField(
                          controller: TextEditingController(
                            text: _bmi!.toStringAsFixed(1),
                          ),
                          label: 'BMI (auto-calc)',
                          isReadOnly: true,
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _glucoseController,
                              hint: 'e.g. 5.5',
                              label: 'Blood Glucose',
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _glucoseTypeFasting ? 'Fasting' : 'Random',
                              decoration: _dropdownDecoration('Type'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Fasting',
                                  child: Text('Fasting'),
                                ),
                                DropdownMenuItem(
                                  value: 'Random',
                                  child: Text('Random'),
                                ),
                              ],
                              onChanged: (v) => setState(
                                () => _glucoseTypeFasting = v == 'Fasting',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      _buildSectionHeader('Test Results'),
                      _buildDivider(),
                      SizedBox(height: 8.h),
                      ..._testResults.asMap().entries.map((entry) {
                        final i = entry.key;
                        final t = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: AppTextField(
                                  controller: t.nameController,
                                  hint: 'Test name',
                                  label: 'Test',
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                flex: 3,
                                child: AppTextField(
                                  controller: t.resultController,
                                  hint: 'Result',
                                  label: 'Result',
                                ),
                              ),
                              if (_testResults.length > 1)
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: AppColors.danger,
                                  ),
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
                      _buildDivider(),
                      SizedBox(height: 12.h),
                      AppTextField(
                        controller: _diagnosisController,
                        hint: 'Suspected diagnosis',
                        label: 'Diagnosis',
                      ),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<String>(
                        value: _severity,
                        decoration: _dropdownDecoration('Severity'),
                        items: const [
                          DropdownMenuItem(value: 'Mild', child: Text('Mild')),
                          DropdownMenuItem(
                            value: 'Moderate',
                            child: Text('Moderate'),
                          ),
                          DropdownMenuItem(
                            value: 'Severe',
                            child: Text('Severe'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _severity = v),
                      ),
                      SizedBox(height: 8.h),
                      AppTextField(
                        controller: _pharmacistNotesController,
                        hint: 'Pharmacist notes',
                        label: 'Notes',
                        maxLines: 3,
                      ),
                      SizedBox(height: 24.h),

                      _buildSectionHeader('Medications Dispensed'),
                      _buildDivider(),
                      SizedBox(height: 8.h),
                      ..._dispensedMeds.asMap().entries.map((entry) {
                        final i = entry.key;
                        final m = entry.value;
                        return _buildMedicationCard(m, i);
                      }),
                      AppButton(
                        label: 'Add Medication',
                        variant: AppButtonVariant.outline,
                        onPressed: () => setState(
                          () => _dispensedMeds.add(DispensedMedication()),
                        ),
                        height: 36.h,
                      ),
                      SizedBox(height: 24.h),

                      _buildSectionHeader('Counselling & Advice'),
                      _buildDivider(),
                      SizedBox(height: 12.h),
                      AppTextField(
                        controller: _counsellingController,
                        hint: 'Enter counselling notes and advice',
                        maxLines: 4,
                      ),
                      SizedBox(height: 24.h),

                      _buildSectionHeader('Follow-up'),
                      _buildDivider(),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Text(
                            'Follow-up required',
                            style: AppTextStyles.titleSmall,
                          ),
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
                            Text(
                              'Recurrent follow-up',
                              style: AppTextStyles.titleSmall,
                            ),
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
                                horizontal: 14.w,
                                vertical: 10.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            hint: Text(
                              'Select interval',
                              style: AppTextStyles.bodySmall,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 7,
                                child: Text('Every 7 days'),
                              ),
                              DropdownMenuItem(
                                value: 14,
                                child: Text('Every 14 days'),
                              ),
                              DropdownMenuItem(
                                value: 30,
                                child: Text('Every 30 days'),
                              ),
                              DropdownMenuItem(
                                value: 90,
                                child: Text('Every 90 days'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null)
                                setState(() => _followUpIntervalDays = v);
                            },
                          ),
                        ],
                      ],
                      SizedBox(height: 24.h),

                      _buildSectionHeader('Referral'),
                      _buildDivider(),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Text(
                            'Refer patient',
                            style: AppTextStyles.titleSmall,
                          ),
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
                            child: AppButton(
                              label: 'Cancel',
                              variant: AppButtonVariant.outline,
                              onPressed: () => context.pop(),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: BlocBuilder<VisitBloc, VisitState>(
                              builder: (context, state) {
                                final isLoading = state is VisitLoading;
                                return AppButton(
                                  label: 'Save Changes',
                                  onPressed: isLoading ? null : _onSave,
                                  isLoading: isLoading,
                                );
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
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMedicationCard(DispensedMedication m, int index) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: m.drugNameController,
            hint: 'Drug name',
            label: 'Drug Name',
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AppTextField(
                  controller: m.doseAmountController,
                  hint: 'e.g. 1',
                  label: 'Dose',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              SizedBox(width: 5.w),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: m.doseUnit,
                  decoration: _dropdownDecoration('Unit'),
                  items: sigDoseUnits
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => m.doseUnit = v);
                  },
                ),
              ),
              SizedBox(width: 5.w),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: m.route,
                  decoration: _dropdownDecoration('Route'),
                  items: sigRoutes
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => m.route = v);
                  },
                ),
              ),
              SizedBox(width: 5.w),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: m.frequencyCode,
                  decoration: _dropdownDecoration('Freq'),
                  items: sigFrequencyCodes
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        m.frequencyCode = v;
                        final label = sigFrequencyMap[v];
                        if (label != null) m.frequencyController.text = label;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
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
          SizedBox(height: 5.h),
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
                  decoration: _dropdownDecoration('Unit'),
                  items: sigDurationUnits
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
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
                text: m.totalQuantity.toString(),
              ),
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
              Text(
                'Needs Refill',
                style: AppTextStyles.titleSmall.copyWith(fontSize: 12.sp),
              ),
              Spacer(),
              Switch(
                value: m.needsRefill,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() {
                  m.needsRefill = v;
                  if (v && m.refillDate == null) {
                    m.refillDate = DateTime.now().add(const Duration(days: 30));
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
                Text(
                  'Recurrent refill',
                  style: AppTextStyles.titleSmall.copyWith(fontSize: 12.sp),
                ),
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
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                ),
                hint: Text('Select interval', style: AppTextStyles.bodySmall),
                items: const [
                  DropdownMenuItem(value: 7, child: Text('Every 7 days')),
                  DropdownMenuItem(value: 14, child: Text('Every 14 days')),
                  DropdownMenuItem(value: 30, child: Text('Every 30 days')),
                  DropdownMenuItem(value: 90, child: Text('Every 90 days')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => m.recurrenceIntervalDays = v);
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
                onPressed: () => setState(() => _dispensedMeds.removeAt(index)),
                child: Text(
                  'Remove',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ),
            ),
        ],
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

  Widget _buildDivider() {
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
          suffixIcon: Icon(
            Icons.calendar_today_outlined,
            size: 18.sp,
            color: AppColors.primary,
          ),
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
          suffixIcon: Icon(
            Icons.calendar_today_outlined,
            size: 18.sp,
            color: AppColors.primary,
          ),
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
          suffixIcon: Icon(
            Icons.calendar_today_outlined,
            size: 18.sp,
            color: AppColors.primary,
          ),
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
          suffixIcon: Icon(
            Icons.calendar_today_outlined,
            size: 18.sp,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.white,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      hintText: label,
      hintStyle: AppTextStyles.bodySmall,
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
