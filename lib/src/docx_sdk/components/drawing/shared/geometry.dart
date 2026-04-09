import '../../../../../docx.dart';

abstract class Geometry<T> extends DocxTreeNode<T> {
  Geometry({
    required super.child,
    super.id,
    super.parent,
  });
}
