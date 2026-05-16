import '../../../docx.dart';

typedef StoreCallable<T> = void Function(T data);

//TODO: we need to use this like InheritedWidget for our stores
abstract class InheritedComponent extends DocxNode<DocxNode> {
  InheritedComponent({
    required super.child,
    super.id,
    super.parent,
  }) {
    child
      ..parent = this
      ..index = 0
      ..depth = depth + 1;
  }

  bool shouldNotify(InheritedComponent old);

  final List<StoreCallable> _listeners = List<StoreCallable>.from(<StoreCallable>[]);

  void adopt(StoreCallable callable) {
    if (_listeners.contains(callable)) return;
    _listeners.add(callable);
  }

  void delete(StoreCallable callable) {
    _listeners.remove(callable);
  }

  void notify() {
    for (final StoreCallable call in _listeners) {
      call(this);
    }
  }

  void dispose() {
    _listeners.clear();
  }

  @override
  InheritedComponent copyWith({String? id, DocxNode<dynamic>? parent}) {
    return copy as InheritedComponent;
  }
}
