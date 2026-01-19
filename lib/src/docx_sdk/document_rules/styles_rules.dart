import '../components/docx_document.dart';
import '../document/styles/document_style_sheet.dart';
import '../styles/styles.dart';
import 'rule.dart';

class NoToggleAttributesRule extends Rule {
  @override
  bool get ignorable => true;

  @override
  RuleException? validate(DocxDocument document) {
    final DocumentStylesSheet docStyles = document.options.docStyles;

    for (final Style style in docStyles.styles) {
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
