import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tezocare_mobile/features/visit/data/models/vitals_model.dart';
import 'package:tezocare_mobile/features/visit/domain/entities/vitals.dart';

void main() {
  final testDate = DateTime.parse('2025-03-10T14:00:00.000');
  final testJson = {
    'id': 1,
    'visit_id': 1,
    'temperature': 38.5,
    'heart_rate': 90,
    'respiratory_rate': 20,
    'weight': 30.5,
    'mucous_membranes': 'pink',
    'capillary_refill_time': 2,
    'hydration_status': 'normal',
    'other_findings': 'No abnormalities',
    'recorded_at': '2025-03-10T14:00:00.000',
  };
  final testModel = VitalsModel(
    id: 1,
    visitId: 1,
    temperature: 38.5,
    heartRate: 90,
    respiratoryRate: 20,
    weight: 30.5,
    mucousMembranes: 'pink',
    capillaryRefillTime: 2,
    hydrationStatus: 'normal',
    otherFindings: 'No abnormalities',
    recordedAt: testDate,
  );

  group('VitalsModel', () {
    test('fromJson creates model correctly', () {
      final model = VitalsModel.fromJson(testJson);
      expect(model.id, 1);
      expect(model.visitId, 1);
      expect(model.temperature, 38.5);
      expect(model.heartRate, 90);
      expect(model.respiratoryRate, 20);
      expect(model.weight, 30.5);
      expect(model.mucousMembranes, 'pink');
      expect(model.capillaryRefillTime, 2);
      expect(model.hydrationStatus, 'normal');
      expect(model.otherFindings, 'No abnormalities');
      expect(model.recordedAt, testDate);
    });

    test('fromJson handles null fields', () {
      final json = <String, dynamic>{};
      final model = VitalsModel.fromJson(json);
      expect(model.id, null);
      expect(model.visitId, null);
      expect(model.temperature, null);
      expect(model.heartRate, null);
      expect(model.respiratoryRate, null);
      expect(model.weight, null);
      expect(model.mucousMembranes, null);
      expect(model.capillaryRefillTime, null);
      expect(model.hydrationStatus, null);
      expect(model.otherFindings, null);
      expect(model.recordedAt, null);
    });

    test('toJson produces correct map', () {
      final json = testModel.toJson();
      expect(json, testJson);
    });

    test('json round-trip produces equal model', () {
      final jsonString = jsonEncode(testModel.toJson());
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final recreated = VitalsModel.fromJson(decoded);
      expect(recreated, testModel);
    });

    test('VitalsModel is a Vitals entity', () {
      expect(testModel, isA<Vitals>());
    });
  });
}
