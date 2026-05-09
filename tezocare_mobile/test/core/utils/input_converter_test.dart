import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/core/utils/input_converter.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInteger', () {
    test('returns integer for valid positive string', () {
      final result = inputConverter.stringToUnsignedInteger('123');
      expect(result, Right(123));
    });

    test('returns integer for zero', () {
      final result = inputConverter.stringToUnsignedInteger('0');
      expect(result, Right(0));
    });

    test('returns Left for negative number', () {
      final result = inputConverter.stringToUnsignedInteger('-1');
      expect(
        result,
        Left(ValidationFailure(message: 'Value must be non-negative')),
      );
    });

    test('returns Left for non-numeric string', () {
      final result = inputConverter.stringToUnsignedInteger('abc');
      expect(
        result,
        Left(ValidationFailure(message: 'Invalid number format')),
      );
    });

    test('returns Left for empty string', () {
      final result = inputConverter.stringToUnsignedInteger('');
      expect(
        result,
        Left(ValidationFailure(message: 'Invalid number format')),
      );
    });
  });

  group('stringToDouble', () {
    test('returns double for valid string', () {
      final result = inputConverter.stringToDouble('123.45');
      expect(result, Right(123.45));
    });

    test('returns double for integer string', () {
      final result = inputConverter.stringToDouble('42');
      expect(result, Right(42.0));
    });

    test('returns Left for non-numeric string', () {
      final result = inputConverter.stringToDouble('abc');
      expect(
        result,
        Left(ValidationFailure(message: 'Invalid number format')),
      );
    });

    test('returns Left for empty string', () {
      final result = inputConverter.stringToDouble('');
      expect(
        result,
        Left(ValidationFailure(message: 'Invalid number format')),
      );
    });

    test('returns double for negative value', () {
      final result = inputConverter.stringToDouble('-3.14');
      expect(result, Right(-3.14));
    });
  });
}
