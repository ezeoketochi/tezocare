import 'package:flutter_test/flutter_test.dart';
import 'package:tezocare_mobile/core/utils/logger.dart';

void main() {
  group('Logger', () {
    test('info prints INFO message', () {
      expect(
        () => Logger.instance.info('test message'),
        prints('[INFO] test message\n'),
      );
    });

    test('warning prints WARNING message', () {
      expect(
        () => Logger.instance.warning('test warning'),
        prints('[WARNING] test warning\n'),
      );
    });

    test('error prints ERROR message', () {
      expect(
        () => Logger.instance.error('test error'),
        prints('[ERROR] test error\n'),
      );
    });

    test('error with error object prints error details', () {
      expect(
        () => Logger.instance.error('test error', Exception('detail')),
        prints('[ERROR] test error\n[ERROR] Error details: Exception: detail\n'),
      );
    });

    test('error with stack trace prints stack trace', () {
      final stackTrace = StackTrace.current;
      expect(
        () => Logger.instance.error('test error', null, stackTrace),
        prints('[ERROR] test error\n[ERROR] Stack trace: $stackTrace\n'),
      );
    });

    test('debug prints DEBUG message', () {
      expect(
        () => Logger.instance.debug('test debug'),
        prints('[DEBUG] test debug\n'),
      );
    });

    test('instance is singleton', () {
      expect(Logger.instance, same(Logger.instance));
    });
  });
}
