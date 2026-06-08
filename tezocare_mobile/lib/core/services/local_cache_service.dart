import 'dart:async';
import 'dart:collection';

class LocalCacheService {
  final _cache = HashMap<String, CacheEntry>();
  final _controllers = HashMap<String, StreamController<dynamic>>();

  void put(String key, dynamic data) {
    _cache[key] = CacheEntry(data: data);
    _controller(key).add(data);
  }

  dynamic get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    entry.lastAccessed = DateTime.now();
    return entry.data;
  }

  T? getAs<T>(String key) {
    final data = get(key);
    if (data is T) return data;
    return null;
  }

  bool has(String key) => _cache.containsKey(key);

  void remove(String key) {
    _cache.remove(key);
    _controller(key).add(null);
  }

  void clear() {
    _cache.clear();
    for (final c in _controllers.values) {
      c.add(null);
    }
  }

  void clearByPrefix(String prefix) {
    _cache.removeWhere((key, _) => key.startsWith(prefix));
  }

  void evictOlderThan(Duration maxAge) {
    final cutoff = DateTime.now().subtract(maxAge);
    _cache.removeWhere((_, entry) => entry.createdAt.isBefore(cutoff));
  }

  Stream<T?> watch<T>(String key) {
    return _controller(key).stream.map((data) => data as T?);
  }

  StreamController<dynamic> _controller(String key) {
    return _controllers.putIfAbsent(
      key,
      () => StreamController<dynamic>.broadcast(),
    );
  }

  void dispose() {
    for (final c in _controllers.values) {
      c.close();
    }
    _controllers.clear();
    _cache.clear();
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime createdAt;
  DateTime lastAccessed;

  CacheEntry({
    required this.data,
    DateTime? createdAt,
    DateTime? lastAccessed,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastAccessed = lastAccessed ?? DateTime.now();
}
