import '../../../../../docx.dart';

abstract class Effect<T> extends DocxTreeNode<T> {
  Effect({
    required super.data,
    super.id,
    super.parent,
  });
}
