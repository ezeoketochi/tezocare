import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tezocare_mobile/shared/models/pagination_model.dart';

void main() {
  final testJson = {
    'current_page': 1,
    'last_page': 5,
    'per_page': 20,
    'total': 100,
    'has_more_pages': true,
  };
  final testModel = PaginationModel(
    currentPage: 1,
    lastPage: 5,
    perPage: 20,
    total: 100,
    hasMorePages: true,
  );

  group('PaginationModel', () {
    test('fromJson creates model correctly', () {
      final model = PaginationModel.fromJson(testJson);
      expect(model.currentPage, 1);
      expect(model.lastPage, 5);
      expect(model.perPage, 20);
      expect(model.total, 100);
      expect(model.hasMorePages, true);
    });

    test('fromJson defaults missing fields', () {
      final model = PaginationModel.fromJson({});
      expect(model.currentPage, 1);
      expect(model.lastPage, 1);
      expect(model.perPage, 20);
      expect(model.total, 0);
      expect(model.hasMorePages, false);
    });

    test('toJson produces correct map', () {
      final json = testModel.toJson();
      expect(json, testJson);
    });

    test('json round-trip produces equal model', () {
      final jsonString = jsonEncode(testModel.toJson());
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final recreated = PaginationModel.fromJson(decoded);
      expect(recreated.currentPage, testModel.currentPage);
      expect(recreated.lastPage, testModel.lastPage);
      expect(recreated.perPage, testModel.perPage);
      expect(recreated.total, testModel.total);
      expect(recreated.hasMorePages, testModel.hasMorePages);
    });
  });
}
