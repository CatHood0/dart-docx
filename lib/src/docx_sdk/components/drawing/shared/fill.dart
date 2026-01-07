import '../../../../../docx.dart';

abstract class Fill<T> extends DocxTreeNode<T> {
  Fill({
    required super.data,
    super.id,
    super.parent,
  });
}
