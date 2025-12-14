import 'package:xml/xml.dart';

import '../../../../core/extensions/string_ext.dart';
import '../../../../core/extensions/style_to_from_node.dart';
import '../../../../core/namespaces.dart';
import '../../../sdk.dart';

XmlDocument generateStylesXML(
  DocumentOptions options,
) {
  final List<Style> styles = options.docStyles.styles;
  return XmlDocument(
    <XmlNode>[
      XmlDefaults.declaration,
      XmlElement.tag(
        'w:styles',
        attributes: <XmlAttribute>[
          XmlAttribute(
            'xmlns:mc'.toName(),
            '${namespaces['mc']}',
          ),
          XmlAttribute(
            'xmlns:r'.toName(),
            '${namespaces['r']}',
          ),
          XmlAttribute(
            'xmlns:w'.toName(),
            '${namespaces['w']}',
          ),
          XmlAttribute(
            'xmlns:w15'.toName(),
            '${namespaces['w15']}',
          ),
          XmlAttribute(
            'xmlns:w14'.toName(),
            '${namespaces['w14']}',
          ),
          XmlAttribute('mc:Ignorable'.toName(), 'w14'),
        ],
        children: <XmlNode>[
          XmlElement.tag(
            'w:docDefaults',
            children: <XmlNode>[
              //blocks
              XmlElement.tag(
                'w:pPrDefault',
                children: <XmlNode>[
                  //TODO: we need to implement this to override
                  // default w:pPr
                  options.docStyles.docDefaultParagraphStyles.toNode(
                    defaultChildren: <XmlNode>[
                      XmlElement.tag(
                        'w:spacing',
                        attributes: [
                          XmlAttribute(
                            XmlName('w:after'),
                            '120',
                          ),
                          XmlAttribute(
                            XmlName('w:line'),
                            '240',
                          ),
                          XmlAttribute(
                            XmlName('w:lineRule'),
                            'atLeast',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
                isSelfClosing: false,
              ),
              // inlines
              XmlElement(
                XmlName('w:rPrDefault'),
                <XmlAttribute>[],
                <XmlNode>[
                  XmlElement(
                    XmlName('w:rPr'),
                    <XmlAttribute>[],
                    <XmlNode>[
                      if (options.docStyles
                              .docDefaultInlineStyles()
                              .toNode() !=
                          null)
                        options.docStyles.docDefaultInlineStyles().toNode()!,
                      XmlElement(
                        XmlName('w:rFonts'),
                        [
                          XmlAttribute(
                            XmlName('w:ascii'),
                            options.editorSettings.fontFamily,
                          ),
                          XmlAttribute(
                            XmlName('w:eastAsiaTheme'),
                            'minorHAnsi',
                          ),
                          XmlAttribute(
                            XmlName('w:hAnsiTheme'),
                            'minorHAnsi',
                          ),
                          XmlAttribute(
                            XmlName('w:cstheme'),
                            'minorBidi',
                          ),
                        ],
                      ),
                      XmlElement(
                        XmlName('w:sz'),
                        [
                          XmlAttribute(XmlName('w:val'),
                              '${options.editorSettings.fontSize}'),
                        ],
                      ),
                      XmlElement(
                        XmlName('w:szCs'),
                        [
                          XmlAttribute(
                            XmlName('w:val'),
                            '${options.editorSettings.complexScriptFontSize}',
                          ),
                        ],
                      ),
                      XmlElement(
                        XmlName('w:lang'),
                        [
                          XmlAttribute(XmlName('w:val'),
                              options.editorSettings.language),
                          XmlAttribute(XmlName('w:eastAsia'),
                              options.editorSettings.language),
                          XmlAttribute(XmlName('w:bidi'), 'ar-SA'),
                        ],
                      ),
                    ],
                    false,
                  ),
                ],
                false,
              ),
            ],
            isSelfClosing: false,
          ),
          ...styles.where(_avoidInvalidStyles).map<XmlElement>(
                (Style style) => style.toNode()!,
              ),
        ],
        isSelfClosing: false,
      ),
    ],
  );
}

bool _avoidInvalidStyles(Style style) => !style.isInvalid;
