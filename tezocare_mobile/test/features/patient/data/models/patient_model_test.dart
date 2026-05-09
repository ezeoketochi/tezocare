import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tezocare_mobile/features/patient/data/models/patient_model.dart';
import 'package:tezocare_mobile/features/patient/domain/entities/patient.dart';

void main() {
  final testDate = DateTime.parse('2025-01-15T08:30:00.000');
  final testJson = {
    'id': 1,
    'name': 'Buddy',
    'species': 'Canine',
    'breed': 'Golden Retriever',
    'color': 'Golden',
    'gender': 'male',
    'date_of_birth': '2020-06-01T00:00:00.000',
    'weight': 30.5,
    'microchip_id': '985112345678901',
    'owner_id': 1,
    'owner_name': 'John Doe',
    'owner_phone': '+1234567890',
    'owner_email': 'john@example.com',
    'notes': 'Friendly dog',
    'is_active': true,
    'created_at': '2025-01-15T08:30:00.000',
    'updated_at': '2025-01-15T08:30:00.000',
  };
  final testModel = PatientModel(
    id: 1,
    name: 'Buddy',
    species: 'Canine',
    breed: 'Golden Retriever',
    color: 'Golden',
    gender: 'male',
    dateOfBirth: DateTime.parse('2020-06-01T00:00:00.000'),
    weight: 30.5,
    microchipId: '985112345678901',
    ownerId: 1,
    ownerName: 'John Doe',
    ownerPhone: '+1234567890',
    ownerEmail: 'john@example.com',
    notes: 'Friendly dog',
    isActive: true,
    createdAt: testDate,
    updatedAt: testDate,
  );

  group('PatientModel', () {
    test('fromJson creates model correctly', () {
      final model = PatientModel.fromJson(testJson);
      expect(model.id, 1);
      expect(model.name, 'Buddy');
      expect(model.species, 'Canine');
      expect(model.breed, 'Golden Retriever');
      expect(model.color, 'Golden');
      expect(model.gender, 'male');
      expect(model.dateOfBirth, DateTime.parse('2020-06-01T00:00:00.000'));
      expect(model.weight, 30.5);
      expect(model.microchipId, '985112345678901');
      expect(model.ownerId, 1);
      expect(model.ownerName, 'John Doe');
      expect(model.ownerPhone, '+1234567890');
      expect(model.ownerEmail, 'john@example.com');
      expect(model.notes, 'Friendly dog');
      expect(model.isActive, true);
      expect(model.createdAt, testDate);
      expect(model.updatedAt, testDate);
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 2,
        'name': 'Mittens',
        'species': 'Feline',
        'is_active': false,
      };
      final model = PatientModel.fromJson(json);
      expect(model.breed, null);
      expect(model.color, null);
      expect(model.gender, null);
      expect(model.dateOfBirth, null);
      expect(model.weight, null);
      expect(model.microchipId, null);
      expect(model.ownerId, null);
      expect(model.ownerName, null);
      expect(model.ownerPhone, null);
      expect(model.ownerEmail, null);
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
      final recreated = PatientModel.fromJson(decoded);
      expect(recreated, testModel);
    });

    test('PatientModel is a Patient entity', () {
      expect(testModel, isA<Patient>());
    });
  });
}
