import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tezocare_mobile/features/auth/data/models/token_model.dart';
import 'package:tezocare_mobile/features/auth/domain/entities/token.dart';

void main() {
  final testJson = {
    'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
    'refresh_token': 'dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4',
  };
  final testModel = TokenModel(
    accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
    refreshToken: 'dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4',
  );

  group('TokenModel', () {
    test('fromJson creates model correctly', () {
      final model = TokenModel.fromJson(testJson);
      expect(model.accessToken, testJson['access_token']);
      expect(model.refreshToken, testJson['refresh_token']);
    });

    test('toJson produces correct map', () {
      final json = testModel.toJson();
      expect(json, testJson);
    });

    test('json round-trip produces equal model', () {
      final jsonString = jsonEncode(testModel.toJson());
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final recreated = TokenModel.fromJson(decoded);
      expect(recreated, testModel);
    });

    test('TokenModel is a Token entity', () {
      expect(testModel, isA<Token>());
    });

    test('props are correct', () {
      expect(testModel.props, [
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
        'dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4',
      ]);
    });
  });
}
