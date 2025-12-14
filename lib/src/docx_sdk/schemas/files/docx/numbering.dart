import 'package:xml/xml.dart';

import '../../../../core/namespaces.dart';
import '../../../sdk.dart';

XmlDocument generateNumberingXMLTemplate() => XmlDocument(
      <XmlNode>[
        XmlDefaults.declaration,
        XmlElement.tag(
          'w:numbering',
          attributes: <XmlAttribute>[
            XmlAttribute(
              XmlName.fromString('xmlns:w'),
              namespaces['w']!,
            ),
            XmlAttribute(
              XmlName.fromString('xmlns:ve'),
              namespaces['ve']!,
            ),
            XmlAttribute(
              XmlName.fromString('xmlns:o'),
              namespaces['o']!,
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
              XmlName.fromString('xmlns:wp'),
              namespaces['wp']!,
            ),
            XmlAttribute(
              XmlName.fromString('xmlns:w10'),
              namespaces['w10']!,
            ),
            XmlAttribute(
              XmlName.fromString('xmlns:wne'),
              namespaces['wne']!,
            ),
          ],
          children: <XmlNode>[
            XmlElement.tag(
              'w:abstractNum',
              attributes: <XmlAttribute>[
                XmlAttribute(
                  XmlName('w:abstractNumId'),
                  '0',
                ),
              ],
              children: <XmlNode>[
                XmlElement.tag(
                  'w:nsid',
                  attributes: [
                    XmlAttribute(
                      XmlName('w:val'),
                      '00000000',
                    ),
                  ],
                ),
                XmlElement.tag(
                  'w:multiLevelType',
                  attributes: [
                    XmlAttribute(
                      XmlName('w:val'),
                      'hybridMultilevel',
                    )
                  ],
                ),
                XmlElement.tag(
                  'w:tmpl',
                  attributes: [
                    XmlAttribute(
                        XmlName(
                          'w:val',
                        ),
                        'B06C0C46'),
                  ],
                ),
                XmlElement.tag(
                  'w:lvl',
                  attributes: <XmlAttribute>[
                    XmlAttribute(XmlName('w:ilvl'), '0'),
                  ],
                  children: <XmlNode>[
                    XmlElement.tag(
                      'w:start',
                      attributes: [
                        XmlAttribute(XmlName('w:val'), '1'),
                      ],
                    ),
                    XmlElement.tag(
                      'w:numFmt',
                      attributes: [
                        XmlAttribute(
                          XmlName('w:val'),
                          'bullet',
                        ),
                      ],
                    ),
                    XmlElement.tag(
                      'w:lvlText',
                      attributes: [
                        XmlAttribute(
                          XmlName('w:val'),
                          '•',
                        ),
                      ],
                    ),
                    XmlElement.tag(
                      'w:lvlJc',
                      attributes: [
                        XmlAttribute(
                          XmlName('w:val'),
                          'left',
                        ),
                      ],
                    ),
                    XmlElement.tag('w:pPr', children: [
                      XmlElement.tag('w:ind', attributes: [
                        XmlAttribute(XmlName('w:left'), '720'),
                        XmlAttribute(XmlName('w:hanging'), '360'),
                      ]),
                    ]),
                  ],
                ),
              ],
            ),
            XmlElement.tag(
              'w:abstractNum',
              attributes: <XmlAttribute>[
                XmlAttribute(XmlName('w:abstractNumId'), '1'),
              ],
              children: <XmlNode>[
                XmlElement.tag(
                  'w:nsid',
                  attributes: [
                    XmlAttribute(
                      XmlName('w:val'),
                      '00000001',
                    ),
                  ],
                ),
                XmlElement.tag(
                  'w:multiLevelType',
                  attributes: [
                    XmlAttribute(
                      XmlName('w:val'),
                      'hybridMultilevel',
                    )
                  ],
                ),
                XmlElement.tag(
                  'w:tmpl',
                  attributes: [
                    XmlAttribute(
                      XmlName('w:val'),
                      '98E846A0',
                    ),
                  ],
                ),
                XmlElement.tag(
                  'w:lvl',
                  attributes: <XmlAttribute>[
                    XmlAttribute(XmlName('w:ilvl'), '0'),
                  ],
                  children: <XmlNode>[
                    XmlElement.tag(
                      'w:start',
                      attributes: [
                        XmlAttribute(
                          XmlName('w:val'),
                          '1',
                        ),
                      ],
                    ),
                    XmlElement.tag(
                      'w:numFmt',
                      attributes: [
                        XmlAttribute(
                          XmlName('w:val'),
                          'decimal',
                        )
                      ],
                    ),
                    XmlElement.tag(
                      'w:lvlText',
                      attributes: [
                        XmlAttribute(
                          XmlName('w:val'),
                          '%1.',
                        ),
                      ],
                    ),
                    XmlElement.tag(
                      'w:lvlJc',
                      attributes: [
                        XmlAttribute(
                          XmlName('w:val'),
                          'left',
                        ),
                      ],
                    ),
                    XmlElement.tag(
                      'w:pPr',
                      children: [
                        XmlElement.tag(
                          'w:ind',
                          attributes: [
                            XmlAttribute(
                              XmlName('w:left'),
                              '720',
                            ),
                            XmlAttribute(
                              XmlName('w:hanging'),
                              '360',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            XmlElement.tag(
              'w:num',
              attributes: <XmlAttribute>[
                XmlAttribute(XmlName('w:numId'), '1'),
              ],
              children: <XmlNode>[
                XmlElement.tag(
                  'w:abstractNumId',
                  attributes: [
                    XmlAttribute(
                      XmlName('w:val'),
                      '0',
                    ),
                  ],
                ),
              ],
            ),
            XmlElement.tag(
              'w:num',
              attributes: <XmlAttribute>[
                XmlAttribute(
                  XmlName('w:numId'),
                  '2',
                ),
              ],
              children: <XmlNode>[
                XmlElement.tag(
                  'w:abstractNumId',
                  attributes: [
                    XmlAttribute(
                      XmlName('w:val'),
                      '1',
                    ),
                  ],
                ),
              ],
            ),
          ],
          isSelfClosing: false,
        ),
      ],
    );
