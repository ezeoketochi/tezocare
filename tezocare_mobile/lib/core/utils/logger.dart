class Logger {
  static final Logger _instance = Logger._();
  static Logger get instance => _instance;

  Logger._();

  void info(String message) {
    _log('INFO', message);
  }

  void warning(String message) {
    _log('WARNING', message);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message);
    if (error != null) {
      _log('ERROR', 'Error details: $error');
    }
    if (stackTrace != null) {
      _log('ERROR', 'Stack trace: $stackTrace');
    }
  }

  void debug(String message) {
    _log('DEBUG', message);
  }

  void _log(String level, String message) {
    // ignore: avoid_print
    print('[$level] $message');
  }
}
