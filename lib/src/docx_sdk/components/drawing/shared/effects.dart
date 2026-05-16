import '../../../../../docx.dart';

abstract class Effect<T> extends DocxNode<T> {
  Effect({
    required super.child,
    super.id,
    super.parent,
  });
}
