extension CastExt on Object {
  T cast<T>() => this as T;
  T? castOrNull<T>() => this is! T ? null : this as T;
}

extension ObjectToList<T> on T {
  List<T> toList() => <T>[this];
}

extension IterableToMap<T> on Iterable<T> {
  /// Converts a List object, directly to a Map one
  Map<K, T> toMap<K>(
    K Function(T) keyCallback, {
    bool replaceOnConflict = true,
  }) {
    final map = <K, T>{};
    for (T v in this) {
      final key = keyCallback(v);
      if (!replaceOnConflict && map.containsKey(key)) {
        continue;
      }
      map[key] = v;
    }
    return map;
  }
}
