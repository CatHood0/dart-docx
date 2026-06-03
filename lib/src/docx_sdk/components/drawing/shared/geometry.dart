import '../../../../../docx.dart';

abstract class Geometry<T> extends DocxNode<T> {
  Geometry({
    required super.child,
    super.id,
    super.parent,
  });
}
