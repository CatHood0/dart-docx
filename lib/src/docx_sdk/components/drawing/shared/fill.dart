import '../../../../../docx.dart';

abstract class Fill<T> extends DocxNode<T> {
  Fill({
    required super.child,
    super.id,
    super.parent,
  });
}
