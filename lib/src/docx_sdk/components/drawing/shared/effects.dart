import '../../../../../docx.dart';

abstract class Effect<T> extends DocxTreeNode<T> {
  Effect({
    required super.child,
    super.id,
    super.parent,
  });
}
