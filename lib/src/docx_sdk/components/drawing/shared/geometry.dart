import '../../../../../docx.dart';

abstract class Geometry<T> extends DocxTreeNode<T> {
  Geometry({
    required super.data,
    super.id,
    super.parent,
  });
}
