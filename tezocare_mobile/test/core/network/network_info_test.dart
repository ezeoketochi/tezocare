import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/network/network_info.dart';

class MockInternetConnectionChecker extends Mock
    implements InternetConnectionChecker {}

void main() {
  late MockInternetConnectionChecker mockConnectionChecker;
  late NetworkInfoImpl networkInfo;

  setUp(() {
    mockConnectionChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(connectionChecker: mockConnectionChecker);
  });

  group('isConnected', () {
    test('returns true when connection checker says connected', () async {
      when(() => mockConnectionChecker.hasConnection)
          .thenAnswer((_) async => true);
      final result = await networkInfo.isConnected;
      expect(result, true);
    });

    test('returns false when connection checker says disconnected', () async {
      when(() => mockConnectionChecker.hasConnection)
          .thenAnswer((_) async => false);
      final result = await networkInfo.isConnected;
      expect(result, false);
    });
  });
}
