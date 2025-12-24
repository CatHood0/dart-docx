import 'package:docx/docx.dart';
import 'package:docx/src/docx_sdk/utils/language_codes.dart';
import 'package:docx/src/docx_sdk/xml_components/styles/xml_styles_component.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('XmlToDocx', () {
    test(
      'should correctly parse [Content_Type.xml] into XmlContentTypeComponent',
      () {},
    );
    test(
        'should correctly '
        'parse styles.xml into DocumentStylesSheet', () {
      final XmlDocument xmlDocument = XmlDocument.parse(
        XmlStylesComponent()
            .buildDocument(
              DocumentContext.base(
                  options: DocumentOptions.blank(
                styles: DocumentStylesSheet.base(),
              )),
            )
            .toXmlString(),
      );
      final DocumentStylesSheet stylesSheet =
          XmlToDocxObjects.xmlToDocumentStylesSheet(xmlDocument);

      expect(
        stylesSheet.styles.length,
        EasyStyles.standardDocumentStyles.length,
      );

      // Test 'Normal' style
      final Style normalStyle =
          stylesSheet.styles.firstWhere((s) => s.styleId == 'Normal');
      expect(normalStyle.type, 'paragraph');
      expect(
        normalStyle.styleName()?.value,
        equals('Normal'),
      );
      expect(normalStyle.defaultValue, isNull);

      // Test 'Heading1' style
      final Style heading1Style =
          stylesSheet.styles.firstWhere((Style s) => s.styleId == 'Heading1');
      expect(heading1Style.contains('w:rPr'), isTrue);
      expect(heading1Style.contains('w:pPr'), isTrue);
      final StyleConfigurator? headingBlockProperties =
          heading1Style.paragraphProperties;
      final StyleConfigurator? headingInlineProperties =
          heading1Style.runProperties;
      expect(headingBlockProperties, isNotNull);
      expect(headingInlineProperties, isNotNull);
      expect(heading1Style.type, 'paragraph');
      expect(
        heading1Style.styleName(language: LanguageCodes.englishUS)?.value,
        equals('Heading 1'),
      );
      expect(heading1Style.basedOn?.value, equals('Normal'));
      expect(
        heading1Style.uiPriority!.value,
        equals(9),
      );
      expect(heading1Style.qFormat, isNotNull);
      expect(headingBlockProperties!.spacing, isNotNull);
      expect(
        headingBlockProperties.spacing!
            .getConfiguratorOrNull('w:before')
            ?.value,
        equals(480),
      );
      expect(headingBlockProperties.keepNext, isNotNull);
      expect(headingBlockProperties.keepLines, isNotNull);
      expect(headingBlockProperties.outlineLvl?.value, equals(0));
      expect(
        headingInlineProperties!.fontFamily?.attributes?['w:ascii'],
        equals('Times New Roman'),
      );
      expect(headingInlineProperties.fontSize?.value, equals(24));
      expect(headingInlineProperties.bold, isNotNull);
    });
  });
}
