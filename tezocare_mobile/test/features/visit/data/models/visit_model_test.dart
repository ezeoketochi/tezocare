import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tezocare_mobile/features/visit/data/models/visit_model.dart';
import 'package:tezocare_mobile/features/visit/domain/entities/visit.dart';

void main() {
  final testDate = DateTime.parse('2025-03-10T14:00:00.000');
  final testJson = {
    'id': 1,
    'patient_id': 1,
    'patient_name': 'Buddy',
    'staff_id': 1,
    'staff_name': 'Dr. Smith',
    'visit_date': '2025-03-10T14:00:00.000',
    'reason': 'Annual checkup',
    'diagnosis': 'Healthy',
    'treatment': 'Vaccination',
    'notes': 'All good',
    'status': 'completed',
    'created_at': '2025-03-10T14:00:00.000',
    'updated_at': '2025-03-10T14:00:00.000',
  };
  final testModel = VisitModel(
    id: 1,
    patientId: 1,
    patientName: 'Buddy',
    staffId: 1,
    staffName: 'Dr. Smith',
    visitDate: testDate,
    reason: 'Annual checkup',
    diagnosis: 'Healthy',
    treatment: 'Vaccination',
    notes: 'All good',
    status: 'completed',
    createdAt: testDate,
    updatedAt: testDate,
  );

  group('VisitModel', () {
    test('fromJson creates model correctly', () {
      final model = VisitModel.fromJson(testJson);
      expect(model.id, 1);
      expect(model.patientId, 1);
      expect(model.patientName, 'Buddy');
      expect(model.staffId, 1);
      expect(model.staffName, 'Dr. Smith');
      expect(model.visitDate, testDate);
      expect(model.reason, 'Annual checkup');
      expect(model.diagnosis, 'Healthy');
      expect(model.treatment, 'Vaccination');
      expect(model.notes, 'All good');
      expect(model.status, 'completed');
      expect(model.createdAt, testDate);
      expect(model.updatedAt, testDate);
    });

    test('fromJson defaults status to completed', () {
      final json = {
        'id': 2,
        'patient_id': 1,
        'staff_id': 1,
        'visit_date': '2025-03-10T14:00:00.000',
      };
      final model = VisitModel.fromJson(json);
      expect(model.status, 'completed');
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 2,
        'patient_id': 1,
        'staff_id': 1,
        'visit_date': '2025-03-10T14:00:00.000',
        'status': 'scheduled',
      };
      final model = VisitModel.fromJson(json);
      expect(model.patientName, null);
      expect(model.staffName, null);
      expect(model.reason, null);
      expect(model.diagnosis, null);
      expect(model.treatment, null);
      expect(model.notes, null);
      expect(model.createdAt, null);
      expect(model.updatedAt, null);
    });

    test('toJson produces correct map', () {
      final json = testModel.toJson();
      expect(json, testJson);
    });

    test('json round-trip produces equal model', () {
      final jsonString = jsonEncode(testModel.toJson());
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final recreated = VisitModel.fromJson(decoded);
      expect(recreated, testModel);
    });

    test('VisitModel is a Visit entity', () {
      expect(testModel, isA<Visit>());
    });
  });
}
