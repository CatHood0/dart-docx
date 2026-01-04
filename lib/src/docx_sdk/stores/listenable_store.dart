typedef StoreCallable<T> = void Function(T data);

abstract class ListenableStore<T> {
  final List<StoreCallable<T>> _listeners =
      List<StoreCallable<T>>.from(<StoreCallable<T>>[]);

  void adopt(StoreCallable callable) {
    if (_listeners.contains(callable)) return;
    _listeners.add(callable);
  }

  void delete(StoreCallable callable) {
    _listeners.remove(callable);
  }

  void notify(T data) {
    for (final StoreCallable<T> call in _listeners) {
      call(data);
    }
  }

  void release() {
    _listeners.clear();
  }
}
