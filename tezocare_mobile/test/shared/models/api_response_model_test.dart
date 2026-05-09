import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tezocare_mobile/shared/models/api_response_model.dart';

void main() {
  group('ApiResponseModel', () {
    test('fromJson creates model with data', () {
      final json = {
        'success': true,
        'message': 'Success',
        'data': {'id': 1, 'name': 'test'},
      };
      final model = ApiResponseModel<Map<String, dynamic>>.fromJson(
        json,
        (data) => data as Map<String, dynamic>,
      );
      expect(model.success, true);
      expect(model.message, 'Success');
      expect(model.data, {'id': 1, 'name': 'test'});
      expect(model.errors, null);
    });

    test('fromJson handles null data', () {
      final json = {
        'success': false,
        'message': 'Error occurred',
      };
      final model = ApiResponseModel<Map<String, dynamic>>.fromJson(
        json,
        null,
      );
      expect(model.success, false);
      expect(model.message, 'Error occurred');
      expect(model.data, null);
    });

    test('fromJson defaults success to false', () {
      final model = ApiResponseModel<Map<String, dynamic>>.fromJson({}, null);
      expect(model.success, false);
    });

    test('toJson produces correct map', () {
      final model = ApiResponseModel<Map<String, dynamic>>(
        success: true,
        message: 'OK',
        data: {'value': 'result'},
      );
      final json = model.toJson((data) => data);
      expect(json['success'], true);
      expect(json['message'], 'OK');
      expect(json['data'], {'value': 'result'});
    });

    test('toJson excludes null fields', () {
      final model = ApiResponseModel<Map<String, dynamic>>(success: false);
      final json = model.toJson(null);
      expect(json.containsKey('message'), false);
      expect(json.containsKey('data'), false);
      expect(json.containsKey('errors'), false);
    });

    test('json round-trip preserves data', () {
      final original = ApiResponseModel<Map<String, dynamic>>(
        success: true,
        message: 'Test',
        data: {'key': 'value'},
      );
      final json = original.toJson(
        (data) => data,
      );
      final decoded = ApiResponseModel<Map<String, dynamic>>.fromJson(
        json,
        (data) => data as Map<String, dynamic>,
      );
      expect(decoded.success, original.success);
      expect(decoded.message, original.message);
      expect(decoded.data, original.data);
    });
  });
}
