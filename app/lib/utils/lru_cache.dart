import 'dart:collection';

class LRUCache<K, V> {
  int _capacity;
  final LinkedHashMap<K, V> _cache;

  LRUCache(
    this._capacity, {
    bool Function(K, K)? equals,
    int Function(K)? hashCode,
    bool Function(dynamic)? isValidKey,
  }) : _cache = LinkedHashMap<K, V>(
          equals: equals,
          hashCode: hashCode,
          isValidKey: isValidKey,
        );

  void resize(int capacity) {
    if (_capacity > capacity) {
      _cache.keys.take(_capacity - capacity).forEach(_cache.remove);
    }

    _capacity = capacity;
  }

  V? get(K key) {
    final value = _cache.remove(key); // Temporarily remove the item.

    if (value != null) {
      _cache[key] =
          value; // Re-inserting the item makes it the most-recently used.
    }

    return value;
  }

  void set(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key); // Remove the existing item before updating.
    } else if (_cache.length == _capacity) {
      _cache.remove(
        _cache.keys.first,
      ); // Explicitly remove the least recently used item if at capacity.
    }

    _cache[key] = value; // Inserting or updating the item.
  }
}
