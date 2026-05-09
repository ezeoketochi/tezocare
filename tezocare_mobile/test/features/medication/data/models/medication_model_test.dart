import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tezocare_mobile/features/medication/data/models/medication_model.dart';
import 'package:tezocare_mobile/features/medication/domain/entities/medication.dart';

void main() {
  final testDate = DateTime.parse('2025-02-01T09:00:00.000');
  final testJson = {
    'id': 1,
    'patient_id': 1,
    'patient_name': 'Buddy',
    'name': 'Amoxicillin',
    'dosage': '500mg',
    'frequency': 'BID',
    'route': 'oral',
    'start_date': '2025-02-01T09:00:00.000',
    'end_date': '2025-02-14T09:00:00.000',
    'prescribed_by': 'Dr. Smith',
    'notes': 'Take with food',
    'is_active': true,
    'created_at': '2025-02-01T09:00:00.000',
    'updated_at': '2025-02-01T09:00:00.000',
  };
  final testModel = MedicationModel(
    id: 1,
    patientId: 1,
    patientName: 'Buddy',
    name: 'Amoxicillin',
    dosage: '500mg',
    frequency: 'BID',
    route: 'oral',
    startDate: testDate,
    endDate: testDate.add(const Duration(days: 13)),
    prescribedBy: 'Dr. Smith',
    notes: 'Take with food',
    isActive: true,
    createdAt: testDate,
    updatedAt: testDate,
  );

  group('MedicationModel', () {
    test('fromJson creates model correctly', () {
      final model = MedicationModel.fromJson(testJson);
      expect(model.id, 1);
      expect(model.patientId, 1);
      expect(model.patientName, 'Buddy');
      expect(model.name, 'Amoxicillin');
      expect(model.dosage, '500mg');
      expect(model.frequency, 'BID');
      expect(model.route, 'oral');
      expect(model.startDate, testDate);
      expect(model.endDate, testDate.add(const Duration(days: 13)));
      expect(model.prescribedBy, 'Dr. Smith');
      expect(model.notes, 'Take with food');
      expect(model.isActive, true);
      expect(model.createdAt, testDate);
      expect(model.updatedAt, testDate);
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 2,
        'patient_id': 1,
        'name': 'Metacam',
        'is_active': false,
      };
      final model = MedicationModel.fromJson(json);
      expect(model.patientName, null);
      expect(model.dosage, null);
      expect(model.frequency, null);
      expect(model.route, null);
      expect(model.startDate, null);
      expect(model.endDate, null);
      expect(model.prescribedBy, null);
      expect(model.notes, null);
      expect(model.createdAt, null);
      expect(model.updatedAt, null);
      expect(model.isActive, false);
    });

    test('toJson produces correct map', () {
      final json = testModel.toJson();
      expect(json, testJson);
    });

    test('json round-trip produces equal model', () {
      final jsonString = jsonEncode(testModel.toJson());
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final recreated = MedicationModel.fromJson(decoded);
      expect(recreated, testModel);
    });

    test('MedicationModel is a Medication entity', () {
      expect(testModel, isA<Medication>());
    });
  });
}
