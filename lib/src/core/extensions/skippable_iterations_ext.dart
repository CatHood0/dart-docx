extension SkippableIterationsExt<T> on Iterable<T> {
  /// Returns a new lazy [Iterable] with elements that are created by
  /// calling `builder` on each element of this `Iterable` in
  /// iteration order.
  ///
  /// If the `builder` call returns null
  /// then that element is ignored
  ///
  /// Example:
  /// ```dart import:convert
  /// var products = jsonDecode('''
  /// [
  ///   {"name": "Screwdriver", "price": 42.00},
  ///   {"name": "Wingnut", "price": 0.50}
  /// ]
  /// ''');
  /// var values = products.skippableMap((product) => (product['price'] as int) < 1 ? null : product['price'] as double);
  /// var totalPrice = values.fold(0.0, (a, b) => a + b); // 42.
  /// ```
  Iterable<K> skippableMap<K>(K? Function(T) builder) {
    final List<K> values = [];
    for (final T value in this) {
      final K? el = builder(value);
      if (el == null) continue;
      values.add(el);
    }
    return values;
  }
}

extension SkippableMapExt<K, V> on Map<K, V> {
  /// Returns a new lazy [Iterable] with elements that are created by
  /// calling `builder` on each element of this `Map`
  ///
  /// If the `builder` call returns null
  /// then that element is ignored
  Iterable<T> skippableMap<T>(T? Function(MapEntry<K, V> entry) builder) {
    final List<T> values = [];
    for (final K key in this.keys) {
      final T? el = builder(
        MapEntry<K, V>(
          key,
          this[key] as V,
        ),
      );
      if (el == null) continue;
      values.add(el);
    }
    return values;
  }
}
