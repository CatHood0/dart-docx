import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';
import 'xml_font_table_component.dart';

/// Represents a `<w:font>` element within the `fontTable.xml`.
///
/// This component defines the properties of a single font used in the document.
class XmlFontComponent extends XmlComponentBase<FontProperties> {
  XmlFontComponent(FontProperties properties)
      : super(
          value: properties,
          xmlKey: 'w:font',
          attrs: XmlComponentAttributes(
            xmlAttributes: {
              'w:name': properties.name,
            },
          ),
        );

  XmlElement? _buildEmbeddedFontRef(
    EmbeddedFontRefOptions? refOptions,
    String tagName,
  ) {
    if (refOptions == null) return null;
    return XmlElement.tag(
      tagName,
      attributes: [
        XmlAttribute('r:id'.toName(), refOptions.rId),
        if (refOptions.fontKey != null)
          // Format as {GUID}
          XmlAttribute(
            'w:fontKey'.toName(),
            '{${refOptions.fontKey!}}',
          ),
        if (refOptions.subsetted != null)
          XmlAttribute(
            'w:subsetted'.toName(),
            refOptions.subsetted! ? '1' : '0',
          ),
      ],
      isSelfClosing: true,
    );
  }

  @override
  XmlElement buildXml(BuildNodeContext context) {
    final List<XmlNode> children = [];

    if (value.panose1 != null) {
      children.add(XmlEmptyElementComponent(
        xmlKey: 'w:panose1',
        value: value.panose1!,
      ).buildXml(context));
    }

    if (value.charset != null) {
      children.add(XmlEmptyElementComponent(
        xmlKey: 'w:charset',
        value: value.charset!.value,
      ).buildXml(context));
    }

    if (value.family != null) {
      children.add(XmlEmptyElementComponent(
        xmlKey: 'w:family',
        value: value.family!,
      ).buildXml(context));
    }

    if (value.pitch != null) {
      children.add(XmlEmptyElementComponent(
        xmlKey: 'w:pitch',
        value: value.pitch!,
      ).buildXml(context));
    }

    if (value.sigUsb0 != null ||
        value.sigUsb1 != null ||
        value.sigUsb2 != null ||
        value.sigUsb3 != null ||
        value.sigCsb0 != null ||
        value.sigCsb1 != null) {
      children.add(
        XmlElement.tag(
          'w:sig',
          attributes: [
            if (value.sigUsb0 != null)
              XmlAttribute('w:usb0'.toName(), value.sigUsb0!),
            if (value.sigUsb1 != null)
              XmlAttribute('w:usb1'.toName(), value.sigUsb1!),
            if (value.sigUsb2 != null)
              XmlAttribute('w:usb2'.toName(), value.sigUsb2!),
            if (value.sigUsb3 != null)
              XmlAttribute('w:usb3'.toName(), value.sigUsb3!),
            if (value.sigCsb0 != null)
              XmlAttribute('w:csb0'.toName(), value.sigCsb0!),
            if (value.sigCsb1 != null)
              XmlAttribute('w:csb1'.toName(), value.sigCsb1!),
          ],
          isSelfClosing: true,
        ),
      );
    }

    if (value.altName != null) {
      children.add(XmlEmptyElementComponent(
        xmlKey: 'w:altName',
        value: value.altName!,
      ).buildXml(context));
    }

    final XmlElement? embedRegular = _buildEmbeddedFontRef(
      value.embedRegular,
      'w:embedRegular',
    );
    if (embedRegular != null) children.add(embedRegular);
    final XmlElement? embedBold = _buildEmbeddedFontRef(
      value.embedBold,
      'w:embedBold',
    );
    if (embedBold != null) children.add(embedBold);
    final XmlElement? embedItalic = _buildEmbeddedFontRef(
      value.embedItalic,
      'w:embedItalic',
    );
    if (embedItalic != null) children.add(embedItalic);
    final XmlElement? embedBoldItalic = _buildEmbeddedFontRef(
      value.embedBoldItalic,
      'w:embedBoldItalic',
    );
    if (embedBoldItalic != null) children.add(embedBoldItalic);

    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: children,
    );
  }

  /// Parses an [XmlDocument] representing `fontTable.xml` into a [XmlFontTableComponent].
  ///
  /// Returns an [XmlFontTableComponent] instance containing parsed [FontProperties].
  static XmlFontTableComponent fromXmlDocument(XmlDocument document) {
    final XmlElement? fontsElement =
        document.findAllElements('w:fonts').firstOrNull;
    if (fontsElement == null) {
      return XmlFontTableComponent(fonts: []);
    }

    final List<FontProperties> parsedFonts = [];
    for (final XmlElement fontElement
        in fontsElement.findAllElements('w:font')) {
      final String? fontName = fontElement.getAttribute('w:name');
      if (fontName == null) continue;

      String? altName;
      String? panose1;
      CharacterSet? charset;
      String? family;
      bool? notTrueType;
      String? pitch;
      String? sigUsb0, sigUsb1, sigUsb2, sigUsb3, sigCsb0, sigCsb1;

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
                  (e) => e.value == charsetVal,
                  orElse: () => CharacterSet.ansi, // Default or handle unknown
                );
              }
              break;
            case 'w:family':
              family = child.getAttribute('w:val');
              break;
            case 'w:notTrueType':
              notTrueType = child.getAttribute('w:val') ==
                  '1'; // '1' for true, '0' for false
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
        ),
      );
    }
    return XmlFontTableComponent(fonts: parsedFonts);
  }
}
