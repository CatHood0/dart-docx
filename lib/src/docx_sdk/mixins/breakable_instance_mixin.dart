import '../../../docx.dart';

/// Usually, just text componentes implement this
/// mixin
mixin BreakableInstanceMixin {
  DocxContent breakAt(int offset);
}
