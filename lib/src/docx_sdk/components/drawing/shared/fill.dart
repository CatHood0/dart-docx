import '../../../../../docx.dart';

abstract class Fill<T> extends DocxTreeNode<T> {
  Fill({
    required super.child,
    super.id,
    super.parent,
  });
}
