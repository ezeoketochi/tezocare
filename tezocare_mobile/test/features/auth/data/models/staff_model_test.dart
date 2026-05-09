import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tezocare_mobile/features/auth/data/models/staff_model.dart';
import 'package:tezocare_mobile/features/auth/domain/entities/staff.dart';

void main() {
  final testDate = DateTime.parse('2025-01-01T10:00:00.000');
  final testJson = {
    'id': 1,
    'name': 'Dr. Smith',
    'email': 'smith@tezocare.com',
    'role': 'veterinarian',
    'is_active': true,
    'created_at': '2025-01-01T10:00:00.000',
  };
  final testModel = StaffModel(
    id: 1,
    name: 'Dr. Smith',
    email: 'smith@tezocare.com',
    role: 'veterinarian',
    isActive: true,
    createdAt: testDate,
  );

  group('StaffModel', () {
    test('fromJson creates model correctly', () {
      final model = StaffModel.fromJson(testJson);
      expect(model.id, 1);
      expect(model.name, 'Dr. Smith');
      expect(model.email, 'smith@tezocare.com');
      expect(model.role, 'veterinarian');
      expect(model.isActive, true);
      expect(model.createdAt, testDate);
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 2,
        'name': 'Jane',
        'email': 'jane@tezocare.com',
        'is_active': false,
      };
      final model = StaffModel.fromJson(json);
      expect(model.role, null);
      expect(model.createdAt, null);
      expect(model.isActive, false);
    });

    test('toJson produces correct map', () {
      final json = testModel.toJson();
      expect(json, testJson);
    });

    test('toJson handles null optional fields', () {
      final model = StaffModel(
        id: 2,
        name: 'Jane',
        email: 'jane@tezocare.com',
        isActive: false,
      );
      final json = model.toJson();
      expect(json['role'], null);
      expect(json['created_at'], null);
    });

    test('json round-trip produces equal model', () {
      final jsonString = jsonEncode(testModel.toJson());
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final recreated = StaffModel.fromJson(decoded);
      expect(recreated, testModel);
    });

    test('StaffModel is a Staff entity', () {
      expect(testModel, isA<Staff>());
    });

    test('props are correct', () {
      expect(testModel.props, [
        1,
        'Dr. Smith',
        'smith@tezocare.com',
        'veterinarian',
        true,
        testDate,
      ]);
    });
  });
}
