import '../../../docx.dart';
import 'rule.dart';

class NoToggleAttributesRule extends Rule {
  @override
  bool get ignorable => true;

  @override
  RuleException? validate(DocxDocument document) {
    final DocumentStyles docStyles = document.options.docStyles;

    for (final Style style in docStyles.styles.values) {
      final StyleConfigurator? pPr = style.paragraphProperties;
      final StyleConfigurator? rPr = style.runProperties;
      if (pPr == null && rPr == null) continue;
    }

    return null;
  }
}

class SortedAttributesRule extends Rule {
  @override
  RuleException? validate(DocxDocument document) {
    // TODO: implement validate
    throw UnimplementedError();
  }
}
