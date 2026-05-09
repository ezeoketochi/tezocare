import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tezocare_mobile/features/dashboard/data/models/refill_model.dart';
import 'package:tezocare_mobile/features/dashboard/domain/entities/refill.dart';

void main() {
  final lastRefillDate = DateTime.parse('2025-03-01T00:00:00.000');
  final nextRefillDate = DateTime.parse('2025-03-28T00:00:00.000');
  final testJson = {
    'id': 1,
    'medication_id': 1,
    'medication_name': 'Amoxicillin',
    'patient_id': 1,
    'patient_name': 'Buddy',
    'last_refill_date': '2025-03-01T00:00:00.000',
    'next_refill_date': '2025-03-28T00:00:00.000',
    'is_overdue': false,
  };
  final testModel = RefillModel(
    id: 1,
    medicationId: 1,
    medicationName: 'Amoxicillin',
    patientId: 1,
    patientName: 'Buddy',
    lastRefillDate: lastRefillDate,
    nextRefillDate: nextRefillDate,
    isOverdue: false,
  );

  group('RefillModel', () {
    test('fromJson creates model correctly', () {
      final model = RefillModel.fromJson(testJson);
      expect(model.id, 1);
      expect(model.medicationId, 1);
      expect(model.medicationName, 'Amoxicillin');
      expect(model.patientId, 1);
      expect(model.patientName, 'Buddy');
      expect(model.lastRefillDate, lastRefillDate);
      expect(model.nextRefillDate, nextRefillDate);
      expect(model.isOverdue, false);
    });

    test('fromJson defaults is_overdue to false', () {
      final json = {
        'id': 1,
        'medication_id': 1,
        'medication_name': 'Metacam',
        'patient_id': 1,
        'patient_name': 'Mittens',
        'last_refill_date': '2025-03-01T00:00:00.000',
        'next_refill_date': '2025-03-28T00:00:00.000',
      };
      final model = RefillModel.fromJson(json);
      expect(model.isOverdue, false);
    });

    test('toJson produces correct map', () {
      final json = testModel.toJson();
      expect(json, testJson);
    });

    test('json round-trip produces equal model', () {
      final jsonString = jsonEncode(testModel.toJson());
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final recreated = RefillModel.fromJson(decoded);
      expect(recreated, testModel);
    });

    test('RefillModel is a Refill entity', () {
      expect(testModel, isA<Refill>());
    });
  });
}
