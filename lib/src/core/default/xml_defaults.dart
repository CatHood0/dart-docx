import 'package:xml/xml.dart';

import '../../../docx.dart';
import '../namespaces.dart';

/// These are all the default xml nodes that are used
class XmlDefaults {
  const XmlDefaults._();

  static List<XmlElement> get paragraphStyles => List.unmodifiable(<XmlElement>[
        XmlElement.tag(
          xmlParagraphBlockAttrsNode,
          children: [
            // 'w:pBdr' (xmlBorderNode) is closed if theres not content.
            XmlElement.tag(xmlBorderNode, isSelfClosing: true),
            XmlElement.tag(xmlSpacingNode, isSelfClosing: true),
            XmlElement.tag(xmlIndentNode, isSelfClosing: true),
          ],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          xmlParagraphInlineAttsrNode,
          children: [
            XmlElement.tag(
              xmlFontsNode,
              attributes: [
                XmlAttribute(
                  XmlName.fromString('w:ascii'),
                  'Times new roman',
                ),
                XmlAttribute(
                  XmlName.fromString('w:majorHAnsi'),
                  'Times new roman',
                ),
                XmlAttribute(
                  XmlName.fromString('w:cs'),
                  'Times new roman',
                ),
              ],
            ),
            XmlElement.tag(
              xmlSizeFontNode,
              attributes: [
                XmlAttribute(
                  XmlName.fromString('w:val'),
                  '24',
                ),
              ],
            ),
            XmlElement.tag(
              xmlSizeComplexScriptFontNode,
              attributes: [
                XmlAttribute(
                  XmlName.fromString('w:val'),
                  '24',
                ),
              ],
            ),
          ],
          isSelfClosing: false,
        )
      ]);

  static XmlElement paragraphTag(
    String source, {
    Iterable<XmlElement> extraChildren = const <XmlElement>[],
    Iterable<XmlAttribute> attributes = const <XmlAttribute>[],
    Iterable<XmlAttribute> runAttributes = const <XmlAttribute>[],
  }) {
    return XmlElement.tag(
      xmlParagraphNode,
      attributes: attributes,
      children: <XmlNode>[
        ...extraChildren,
        textRunWithText(source, attributes: runAttributes),
      ],
      isSelfClosing: false,
    );
  }

  static XmlElement textRunWithText(
    String source, {
    Iterable<XmlAttribute> attributes = const <XmlAttribute>[],
  }) {
    return XmlElement.tag(
      xmlTextNode,
      attributes: attributes,
      children: [
        text(source),
      ],
      isSelfClosing: false,
    );
  }

  static XmlText text(String text) {
    return XmlText(text);
  }

  /// this is the main declaration that is used by default in xml lan
  static XmlDeclaration get declaration => XmlDeclaration(
        [
          XmlAttribute(XmlName.fromString('version'), '1.0'),
          XmlAttribute(XmlName.fromString('encoding'), 'UTF-8'),
          XmlAttribute(XmlName.fromString('standalone'), 'yes'),
        ],
      );

  static XmlElement relation({
    required String rId,
    required String type,
    required String target,
    String? targetMode = 'Internal',
  }) =>
      XmlElement.tag(
        'Relationship',
        attributes: [
          XmlAttribute(XmlName.fromString('Id'), rId),
          XmlAttribute(
            XmlName.fromString('Type'),
            type,
          ),
          XmlAttribute(
            XmlName.fromString('Target'),
            target,
          ),
          if (targetMode != null && targetMode.isNotEmpty)
            XmlAttribute(
              XmlName.fromString('TargetMode'),
              targetMode,
            ),
        ],
        isSelfClosing: true,
      );

  static XmlElement relationships({
    required Iterable<XmlElement> children,
    bool generateDefaultDocumentRelations = false,
  }) {
    final List<XmlElement> defaultRelations = generateDefaultDocumentRelations
        ? [
            relation(
              rId: 'rId1',
              type: namespaces['settingsRelation']!,
              target: 'settings.xml',
              targetMode: 'Internal',
            ),
            relation(
              rId: 'rId2',
              type: namespaces['themes']!,
              target: 'theme/theme1.xml',
              targetMode: 'Internal',
            ),
            relation(
              rId: 'rId3',
              type: namespaces['styles']!,
              target: 'styles.xml',
              targetMode: 'Internal',
            ),
            relation(
              rId: 'rId4',
              type: namespaces['fontTable']!,
              target: 'fontTable.xml',
              targetMode: 'Internal',
            ),
            relation(
              rId: 'rId5',
              type: namespaces['numbering']!,
              target: 'numbering.xml',
              targetMode: 'Internal',
            ),
            relation(
              rId: 'rId6',
              type: namespaces['webSettingsRelation']!,
              target: 'webSettings.xml',
              targetMode: 'Internal',
            ),
          ]
        : [];
    return XmlElement.tag(
      'Relationships',
      attributes: [
        XmlAttribute(
          XmlName.fromString('xmlns'),
          namespaces['relationship']!,
        ),
      ],
      children: [...defaultRelations, ...children],
      isSelfClosing: false,
    );
  }

  static Iterable<XmlAttribute> get documentAttributes =>
      List.unmodifiable(<XmlAttribute>[
        XmlAttribute(
          XmlName.fromString('xmlns:a'),
          namespaces['a']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:cdr'),
          namespaces['cdr']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:o'),
          namespaces['o']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:pic'),
          namespaces['pic']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:r'),
          namespaces['r']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:v'),
          namespaces['v']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:ve'),
          namespaces['ve']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:vt'),
          namespaces['vt']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:w'),
          namespaces['w']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:mc'),
          namespaces['mc']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:m'),
          namespaces['m']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:w10'),
          namespaces['w10']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:w14'),
          namespaces['w14']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:w15'),
          namespaces['w15']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:wps'),
          namespaces['wps']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:wpi'),
          namespaces['wpi']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:wp'),
          namespaces['wp']!,
        ),
        XmlAttribute(
          XmlName.fromString('xmlns:wne'),
          namespaces['wne']!,
        ),
      ]);
}
