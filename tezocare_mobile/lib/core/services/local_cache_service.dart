import 'dart:collection';

class LocalCacheService {
  final _cache = HashMap<String, CacheEntry>();

  void put(String key, dynamic data) {
    _cache[key] = CacheEntry(data: data);
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

  void remove(String key) => _cache.remove(key);

  void clear() => _cache.clear();

  void clearByPrefix(String prefix) {
    _cache.removeWhere((key, _) => key.startsWith(prefix));
  }

  void evictOlderThan(Duration maxAge) {
    final cutoff = DateTime.now().subtract(maxAge);
    _cache.removeWhere((_, entry) => entry.createdAt.isBefore(cutoff));
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
