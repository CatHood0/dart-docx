import 'package:xml/xml.dart' as xml;

import '../../../../docx.dart';
import '../../core/extensions/node_to_configurator.dart';
import '../../util/predicate.dart';

class XmlToDocxObjects {
  const XmlToDocxObjects._();
  static DocumentStylesSheet xmlToDocumentStylesSheet(
    xml.XmlDocument xmlStyles,
  ) {
    final List<Style> paragraphDefaultStyles = [];
    final List<Style> runDefaultStyles = [];
    final xml.XmlElement mainStyles = xmlStyles.getElement('w:styles')!;
    final xml.XmlElement? rawDocDefaults =
        mainStyles.getElement(xmlDocDefaultsNode);
    assert(
      rawDocDefaults != null,
      'all styles.xml documents should '
      'have at least $xmlDocDefaultsNode element',
    );
    final xml.XmlElement? paragraphStyles =
        rawDocDefaults!.getElement('w:pPrDefault');
    final xml.XmlElement? runStyles = rawDocDefaults.getElement('w:rPrDefault');
    if (paragraphStyles != null) {
      paragraphDefaultStyles.addAll(
        _buildConfigurators(paragraphStyles).map(
          (StyleConfigurator n) {
            return StyleBuilder.singularP()
                .withConfigurators(<StyleConfigurator>[n]).build();
          },
        ),
      );
    }
    if (runStyles != null) {
      runDefaultStyles.addAll(
        _buildConfigurators(runStyles).map(
          (StyleConfigurator n) {
            return StyleBuilder.singularC()
                .withConfigurators(<StyleConfigurator>[n]).build();
          },
        ),
      );
    }

    // common styles configured by the user
    final Iterable<xml.XmlElement> rawStyles =
        mainStyles.findElements(xmlStyleNode);
    if (rawStyles.isEmpty) return DocumentStylesSheet.empty();
    final Iterable<Style> styles =
        rawStyles.map((xml.XmlElement xmlStyleElement) {
      // common values
      final String type = xmlStyleElement.getAttribute('w:type')!;
      final String styleId = xmlStyleElement.getAttribute('w:styleId')!;
      final String? defaultValue = xmlStyleElement.getAttribute('w:default');
      final xml.XmlElement? nameElement = xmlStyleElement.getElement('w:name');
      final String styleName = nameElement!.getAttribute('w:val')!;

      final List<StyleConfigurator> configurators =
          List<StyleConfigurator>.from(
        _buildConfigurators(
          xmlStyleElement,
        ),
      );

      // to keep in memory the session editions
      // usually to avoid loss colaborative feature
      final String? revisionIdDefault =
          xmlStyleElement.getAttribute('w:rsidDefault');
      final String? revisionIdP = xmlStyleElement.getAttribute('w:rsidP');
      final String? revisionIdRun = xmlStyleElement.getAttribute('w:rsidR');
      final String? revisionIdRPr = xmlStyleElement.getAttribute('w:rsidRPr');

      return Style(
        type: type,
        styleId: styleId,
        styleName: styleName,
        configurators: configurators,
        defaultValue: defaultValue,
        revisionIdPPr: revisionIdP,
        revisionIdRun: revisionIdRun,
        revisionIdRPr: revisionIdRPr,
        revisionIdDefault: revisionIdDefault,
      );
    });

    return DocumentStylesSheet(
      styles: List<Style>.from(styles),
      docDefaultParagraphStyles: List<Style>.from(paragraphDefaultStyles),
      docDefaultRunStyles: List<Style>.from(runDefaultStyles),
    );
  }

  static Iterable<StyleConfigurator> _buildConfigurators(
    xml.XmlElement? element,
  ) {
    final List<StyleConfigurator> configurators = <StyleConfigurator>[];
    if (element == null) return configurators;
    for (final xml.XmlElement node
        in element.children.whereType<xml.XmlElement>()) {
      configurators.add(node.toConfigurator);
    }
    return configurators;
  }
}

class ConverterFromXmlContext {
  ConverterFromXmlContext({
    required this.ignoreColorWhenNoSupported,
    required this.defaultTabStop,
    this.acceptFontValueWhen,
    this.acceptSizeValueWhen,
    this.acceptSpacingValueWhen,
    this.shouldParserSizeToHeading,
    this.parseSpacing,
    this.colorBuilder,
    this.checkColor,
  });

  ParseSizeToHeadingCallback? shouldParserSizeToHeading;
  ParseSpacingCallback? parseSpacing;
  bool Function(String? hex)? checkColor;
  final Predicate<String>? acceptFontValueWhen;
  final Predicate<String>? acceptSizeValueWhen;
  final Predicate<int>? acceptSpacingValueWhen;
  final bool ignoreColorWhenNoSupported;
  final String? Function(String? hex)? colorBuilder;
  final double defaultTabStop;
}
