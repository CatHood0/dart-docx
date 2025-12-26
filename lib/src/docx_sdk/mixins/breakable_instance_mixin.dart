import '../../../docx.dart';

/// Usually, just text componentes implement this
/// mixin
mixin BreakableInstanceMixin {
  DocxTreeNode breakAt(int offset);
}
