import 'package:xml/xml.dart';
import '../../../../docx.dart';
import 'xml_font_component.dart';

/// Represents the root `<w:fonts>` element in `fontTable.xml`.
///
/// This component contains a list of [XmlFontComponent] instances,
/// each defining properties for a specific font.
class XmlFontTableComponent extends XmlComponentBase<List<XmlFontComponent>> {
  XmlFontTableComponent({
    required List<FontProperties> fonts,
  }) : super(
          value: fonts.map(XmlFontComponent.new).toList(),
          xmlKey: 'w:fonts',
          attrs: XmlDocAttributes(
            mc: true,
            r: true,
            w: true,
            w14: true,
            w15: true,
            w16cex: true,
            w16cid: true,
            w16: true,
            w16sdtdh: true,
            w16se: true,
          ),
        );

  @override
  String get name => 'FontTable';

  @override
  String get path => DocxPaths.fontTableXmlRelsFilePath;

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: value.map((
        XmlFontComponent n,
      ) {
        return n.buildXml(context);
      }),
    );
  }

  /// Parses an [XmlDocument] representing `fontTable.xml` into a [XmlFontTableComponent].
  ///
  /// [document] The [XmlDocument] to parse.
  /// Returns an [XmlFontTableComponent] instance containing parsed [FontProperties].
  static XmlFontTableComponent fromXmlDocument(
    XmlDocument document,
  ) {
    final XmlElement? fontsElement =
        document.findAllElements('w:fonts').firstOrNull;
    if (fontsElement == null) {
      return XmlFontTableComponent(fonts: []);
    }

    final List<FontProperties> parsedFonts = [];
    for (final XmlElement fontElement in fontsElement.findAllElements(
      'w:font',
    )) {
      final String? fontName = fontElement.getAttribute('w:name');
      if (fontName == null) continue;

      String? altName;
      String? panose1;
      CharacterSet? charset;
      String? family;
      bool? notTrueType;
      String? pitch;
      String? sigUsb0, sigUsb1, sigUsb2, sigUsb3, sigCsb0, sigCsb1;
      EmbeddedFontRefOptions? embedRegular;
      // EmbeddedFontRefOptions? embedBold;
      // EmbeddedFontRefOptions? embedItalic;
      // EmbeddedFontRefOptions? embedBoldItalic;

      for (final XmlNode child in fontElement.children) {
        if (child is XmlElement) {
          switch (child.qualifiedName) {
            case 'w:altName':
              altName = child.getAttribute('w:val');
              break;
            case 'w:panose1':
              panose1 = child.getAttribute('w:val');
              break;
            case 'w:charset':
              final String? charsetVal = child.getAttribute('w:val');
              if (charsetVal != null) {
                charset = CharacterSet.values.firstWhere(
                  (CharacterSet e) => e.value == charsetVal,
                  orElse: () => CharacterSet.ansi,
                );
              }
              break;
            case 'w:family':
              family = child.getAttribute('w:val');
              break;
            case 'w:notTrueType':
              notTrueType = child.getAttribute('w:val') == '1';
              break;
            case 'w:pitch':
              pitch = child.getAttribute('w:val');
              break;
            case 'w:sig':
              sigUsb0 = child.getAttribute('w:usb0');
              sigUsb1 = child.getAttribute('w:usb1');
              sigUsb2 = child.getAttribute('w:usb2');
              sigUsb3 = child.getAttribute('w:usb3');
              sigCsb0 = child.getAttribute('w:csb0');
              sigCsb1 = child.getAttribute('w:csb1');
              break;
            case 'w:embedRegular':
              embedRegular = EmbeddedFontRefOptions(
                rId: child.getAttribute('r:id') ?? '',
                fontKey: child
                    .getAttribute('w:fontKey')
                    ?.replaceAll('{', '')
                    .replaceAll('}', ''),
                subsetted: child.getAttribute('w:subsetted') == '1',
              );
              break;
            //TODO: we need to add parsing for other embed types (bold, italic, boldItalic) if they are to be read.
          }
        }
      }

      parsedFonts.add(
        FontProperties(
          name: fontName,
          altName: altName,
          panose1: panose1,
          charset: charset,
          family: family,
          notTrueType: notTrueType,
          pitch: pitch,
          sigUsb0: sigUsb0,
          sigUsb1: sigUsb1,
          sigUsb2: sigUsb2,
          sigUsb3: sigUsb3,
          sigCsb0: sigCsb0,
          sigCsb1: sigCsb1,
          embedRegular: embedRegular,
        ),
      );
    }
    return XmlFontTableComponent(fonts: parsedFonts);
  }
}
