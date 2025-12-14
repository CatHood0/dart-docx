import 'package:xml/xml.dart';

import '../../../../core/namespaces.dart';
import '../../../sdk.dart';

//TODO: we need to use DocumentOptions instead this
XmlDocument generateThemesXml({
  String font = defaultFont,
}) =>
    XmlDocument(
      <XmlNode>[
        XmlDefaults.declaration,
        XmlElement.tag(
          'a:theme',
          attributes: <XmlAttribute>[
            XmlAttribute(
              XmlName.fromString('xmlns:a'),
              namespaces['a']!,
            ),
            XmlAttribute(
              XmlName.fromString('name'),
              'Office Theme',
            ),
          ],
          children: <XmlNode>[
            XmlElement.tag(
              'a:themeElements',
              children: <XmlNode>[
                XmlElement.tag(
                  'a:clrScheme',
                  attributes: <XmlAttribute>[
                    XmlAttribute(XmlName.fromString('name'), 'Office'),
                  ],
                  children: <XmlNode>[
                    XmlElement.tag('a:dk1', children: [
                      XmlElement.tag('a:sysClr', attributes: [
                        XmlAttribute(XmlName.fromString('val'), 'windowText'),
                        XmlAttribute(XmlName.fromString('lastClr'), '000000'),
                      ]),
                    ]),
                    XmlElement.tag('a:lt1', children: [
                      XmlElement.tag('a:sysClr', attributes: [
                        XmlAttribute(XmlName.fromString('val'), 'window'),
                        XmlAttribute(XmlName.fromString('lastClr'), 'FFFFFF'),
                      ]),
                    ]),
                    XmlElement.tag('a:dk2', children: [
                      XmlElement.tag('a:srgbClr', attributes: [
                        XmlAttribute(XmlName.fromString('val'), '44546A')
                      ]),
                    ]),
                    XmlElement.tag('a:lt2', children: [
                      XmlElement.tag('a:srgbClr', attributes: [
                        XmlAttribute(XmlName.fromString('val'), 'E7E6E6')
                      ]),
                    ]),
                    XmlElement.tag('a:accent1', children: [
                      XmlElement.tag('a:srgbClr', attributes: [
                        XmlAttribute(XmlName.fromString('val'), '4472C4')
                      ]),
                    ]),
                    XmlElement.tag('a:accent2', children: [
                      XmlElement.tag('a:srgbClr', attributes: [
                        XmlAttribute(XmlName.fromString('val'), 'ED7D31')
                      ]),
                    ]),
                    XmlElement.tag('a:accent3', children: [
                      XmlElement.tag('a:srgbClr', attributes: [
                        XmlAttribute(XmlName.fromString('val'), 'A5A5A5')
                      ]),
                    ]),
                    XmlElement.tag('a:accent4', children: [
                      XmlElement.tag('a:srgbClr', attributes: [
                        XmlAttribute(XmlName.fromString('val'), 'FFC000')
                      ]),
                    ]),
                    XmlElement.tag('a:accent5', children: [
                      XmlElement.tag('a:srgbClr', attributes: [
                        XmlAttribute(XmlName.fromString('val'), '5B9BD5')
                      ]),
                    ]),
                    XmlElement.tag('a:accent6', children: [
                      XmlElement.tag('a:srgbClr', attributes: [
                        XmlAttribute(XmlName.fromString('val'), '70AD47')
                      ]),
                    ]),
                    XmlElement.tag('a:hlink', children: [
                      XmlElement.tag('a:srgbClr', attributes: [
                        XmlAttribute(XmlName.fromString('val'), '0563C1')
                      ]),
                    ]),
                    XmlElement.tag('a:folHlink', children: [
                      XmlElement.tag('a:srgbClr', attributes: [
                        XmlAttribute(XmlName.fromString('val'), '954F72')
                      ]),
                    ]),
                  ],
                ),
                XmlElement.tag(
                  'a:fontScheme',
                  attributes: <XmlAttribute>[
                    XmlAttribute(XmlName.fromString('name'), 'Office'),
                  ],
                  children: <XmlNode>[
                    XmlElement.tag(
                      'a:majorFont',
                      children: <XmlNode>[
                        XmlElement.tag('a:latin', attributes: [
                          XmlAttribute(XmlName.fromString('typeface'), font)
                        ]),
                        XmlElement.tag('a:ea', attributes: [
                          XmlAttribute(XmlName.fromString('typeface'), font)
                        ]),
                        XmlElement.tag('a:cs', attributes: [
                          XmlAttribute(XmlName.fromString('typeface'), '')
                        ]),
                      ],
                    ),
                    XmlElement.tag(
                      'a:minorFont',
                      children: <XmlNode>[
                        XmlElement.tag('a:latin', attributes: [
                          XmlAttribute(XmlName.fromString('typeface'), font)
                        ]),
                        XmlElement.tag('a:ea', attributes: [
                          XmlAttribute(XmlName.fromString('typeface'), font)
                        ]),
                        XmlElement.tag('a:cs', attributes: [
                          XmlAttribute(XmlName.fromString('typeface'), '')
                        ]),
                      ],
                    ),
                  ],
                ),
                XmlElement.tag(
                  'a:fmtScheme',
                  attributes: <XmlAttribute>[
                    XmlAttribute(XmlName.fromString('name'), 'Office'),
                  ],
                  children: <XmlNode>[
                    XmlElement.tag('a:fillStyleLst', children: [
                      XmlElement.tag('a:solidFill', children: [
                        XmlElement.tag('a:schemeClr', attributes: [
                          XmlAttribute(XmlName.fromString('val'), 'phClr')
                        ]),
                      ]),
                      XmlElement.tag(
                        'a:gradFill',
                        attributes: [
                          XmlAttribute(XmlName.fromString('rotWithShape'), '1')
                        ],
                        children: [
                          XmlElement.tag('a:gsLst', children: [
                            XmlElement.tag('a:gs', attributes: [
                              XmlAttribute(XmlName.fromString('pos'), '0')
                            ], children: [
                              XmlElement.tag('a:schemeClr', attributes: [
                                XmlAttribute(XmlName.fromString('val'), 'phClr')
                              ], children: [
                                XmlElement.tag('a:lumMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '110000')
                                ]),
                                XmlElement.tag('a:satMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '105000')
                                ]),
                                XmlElement.tag('a:tint', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '67000')
                                ]),
                              ]),
                            ]),
                            XmlElement.tag('a:gs', attributes: [
                              XmlAttribute(XmlName.fromString('pos'), '50000')
                            ], children: [
                              XmlElement.tag('a:schemeClr', attributes: [
                                XmlAttribute(XmlName.fromString('val'), 'phClr')
                              ], children: [
                                XmlElement.tag('a:lumMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '105000')
                                ]),
                                XmlElement.tag('a:satMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '103000')
                                ]),
                                XmlElement.tag('a:tint', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '73000')
                                ]),
                              ]),
                            ]),
                            XmlElement.tag('a:gs', attributes: [
                              XmlAttribute(XmlName.fromString('pos'), '100000')
                            ], children: [
                              XmlElement.tag('a:schemeClr', attributes: [
                                XmlAttribute(XmlName.fromString('val'), 'phClr')
                              ], children: [
                                XmlElement.tag('a:lumMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '105000')
                                ]),
                                XmlElement.tag('a:satMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '109000')
                                ]),
                                XmlElement.tag('a:tint', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '81000')
                                ]),
                              ]),
                            ]),
                          ]),
                          XmlElement.tag('a:lin', attributes: [
                            XmlAttribute(XmlName.fromString('ang'), '5400000'),
                            XmlAttribute(XmlName.fromString('scaled'), '0')
                          ]),
                        ],
                      ),
                      XmlElement.tag(
                        'a:gradFill',
                        attributes: [
                          XmlAttribute(XmlName.fromString('rotWithShape'), '1')
                        ],
                        children: [
                          XmlElement.tag('a:gsLst', children: [
                            XmlElement.tag('a:gs', attributes: [
                              XmlAttribute(XmlName.fromString('pos'), '0')
                            ], children: [
                              XmlElement.tag('a:schemeClr', attributes: [
                                XmlAttribute(XmlName.fromString('val'), 'phClr')
                              ], children: [
                                XmlElement.tag('a:satMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '103000')
                                ]),
                                XmlElement.tag('a:lumMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '102000')
                                ]),
                                XmlElement.tag('a:tint', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '94000')
                                ]),
                              ]),
                            ]),
                            XmlElement.tag('a:gs', attributes: [
                              XmlAttribute(XmlName.fromString('pos'), '50000')
                            ], children: [
                              XmlElement.tag('a:schemeClr', attributes: [
                                XmlAttribute(XmlName.fromString('val'), 'phClr')
                              ], children: [
                                XmlElement.tag('a:satMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '110000')
                                ]),
                                XmlElement.tag('a:lumMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '100000')
                                ]),
                                XmlElement.tag('a:shade', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '100000')
                                ]),
                              ]),
                            ]),
                            XmlElement.tag('a:gs', attributes: [
                              XmlAttribute(XmlName.fromString('pos'), '100000')
                            ], children: [
                              XmlElement.tag('a:schemeClr', attributes: [
                                XmlAttribute(XmlName.fromString('val'), 'phClr')
                              ], children: [
                                XmlElement.tag('a:lumMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '99000')
                                ]),
                                XmlElement.tag('a:satMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '120000')
                                ]),
                                XmlElement.tag('a:shade', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '78000')
                                ]),
                              ]),
                            ]),
                          ]),
                          XmlElement.tag('a:lin', attributes: [
                            XmlAttribute(XmlName.fromString('ang'), '5400000'),
                            XmlAttribute(XmlName.fromString('scaled'), '0')
                          ]),
                        ],
                      ),
                    ]),
                    XmlElement.tag('a:lnStyleLst', children: [
                      XmlElement.tag(
                        'a:ln',
                        attributes: [
                          XmlAttribute(XmlName.fromString('w'), '6350'),
                          XmlAttribute(XmlName.fromString('cap'), 'flat'),
                          XmlAttribute(XmlName.fromString('cmpd'), 'sng'),
                          XmlAttribute(XmlName.fromString('algn'), 'ctr'),
                        ],
                        children: [
                          XmlElement.tag('a:solidFill', children: [
                            XmlElement.tag('a:schemeClr', attributes: [
                              XmlAttribute(XmlName.fromString('val'), 'phClr')
                            ]),
                          ]),
                          XmlElement.tag('a:prstDash', attributes: [
                            XmlAttribute(XmlName.fromString('val'), 'solid')
                          ]),
                          XmlElement.tag('a:miter', attributes: [
                            XmlAttribute(XmlName.fromString('lim'), '800000')
                          ]),
                        ],
                      ),
                      XmlElement.tag(
                        'a:ln',
                        attributes: [
                          XmlAttribute(XmlName.fromString('w'), '12700'),
                          XmlAttribute(XmlName.fromString('cap'), 'flat'),
                          XmlAttribute(XmlName.fromString('cmpd'), 'sng'),
                          XmlAttribute(XmlName.fromString('algn'), 'ctr'),
                        ],
                        children: [
                          XmlElement.tag('a:solidFill', children: [
                            XmlElement.tag('a:schemeClr', attributes: [
                              XmlAttribute(XmlName.fromString('val'), 'phClr')
                            ]),
                          ]),
                          XmlElement.tag('a:prstDash', attributes: [
                            XmlAttribute(XmlName.fromString('val'), 'solid')
                          ]),
                          XmlElement.tag('a:miter', attributes: [
                            XmlAttribute(XmlName.fromString('lim'), '800000')
                          ]),
                        ],
                      ),
                      XmlElement.tag(
                        'a:ln',
                        attributes: [
                          XmlAttribute(XmlName.fromString('w'), '19050'),
                          XmlAttribute(XmlName.fromString('cap'), 'flat'),
                          XmlAttribute(XmlName.fromString('cmpd'), 'sng'),
                          XmlAttribute(XmlName.fromString('algn'), 'ctr'),
                        ],
                        children: [
                          XmlElement.tag('a:solidFill', children: [
                            XmlElement.tag('a:schemeClr', attributes: [
                              XmlAttribute(XmlName.fromString('val'), 'phClr')
                            ]),
                          ]),
                          XmlElement.tag('a:prstDash', attributes: [
                            XmlAttribute(XmlName.fromString('val'), 'solid')
                          ]),
                          XmlElement.tag('a:miter', attributes: [
                            XmlAttribute(XmlName.fromString('lim'), '800000')
                          ]),
                        ],
                      ),
                    ]),
                    XmlElement.tag('a:effectStyleLst', children: [
                      XmlElement.tag('a:effectStyle', children: [
                        XmlElement.tag('a:effectLst'),
                      ]),
                      XmlElement.tag('a:effectStyle', children: [
                        XmlElement.tag('a:effectLst'),
                      ]),
                      XmlElement.tag('a:effectStyle', children: [
                        XmlElement.tag('a:effectLst', children: [
                          XmlElement.tag(
                            'a:outerShdw',
                            attributes: [
                              XmlAttribute(
                                  XmlName.fromString('blurRad'), '57150'),
                              XmlAttribute(XmlName.fromString('dist'), '19050'),
                              XmlAttribute(
                                  XmlName.fromString('dir'), '5400000'),
                              XmlAttribute(XmlName.fromString('algn'), 'ctr'),
                              XmlAttribute(
                                  XmlName.fromString('rotWithShape'), '0'),
                            ],
                            children: [
                              XmlElement.tag(
                                'a:srgbClr',
                                attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '000000')
                                ],
                                children: [
                                  XmlElement.tag('a:alpha', attributes: [
                                    XmlAttribute(
                                        XmlName.fromString('val'), '63000')
                                  ]),
                                ],
                              ),
                            ],
                          ),
                        ]),
                      ]),
                    ]),
                    XmlElement.tag('a:bgFillStyleLst', children: [
                      XmlElement.tag('a:solidFill', children: [
                        XmlElement.tag('a:schemeClr', attributes: [
                          XmlAttribute(XmlName.fromString('val'), 'phClr')
                        ]),
                      ]),
                      XmlElement.tag('a:solidFill', children: [
                        XmlElement.tag('a:schemeClr', attributes: [
                          XmlAttribute(XmlName.fromString('val'), 'phClr')
                        ], children: [
                          XmlElement.tag('a:tint', attributes: [
                            XmlAttribute(XmlName.fromString('val'), '95000')
                          ]),
                          XmlElement.tag('a:satMod', attributes: [
                            XmlAttribute(XmlName.fromString('val'), '170000')
                          ]),
                        ]),
                      ]),
                      XmlElement.tag(
                        'a:gradFill',
                        attributes: [
                          XmlAttribute(XmlName.fromString('rotWithShape'), '1')
                        ],
                        children: [
                          XmlElement.tag('a:gsLst', children: [
                            XmlElement.tag('a:gs', attributes: [
                              XmlAttribute(XmlName.fromString('pos'), '0')
                            ], children: [
                              XmlElement.tag('a:schemeClr', attributes: [
                                XmlAttribute(XmlName.fromString('val'), 'phClr')
                              ], children: [
                                XmlElement.tag('a:tint', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '93000')
                                ]),
                                XmlElement.tag('a:satMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '150000')
                                ]),
                                XmlElement.tag('a:shade', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '98000')
                                ]),
                                XmlElement.tag('a:lumMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '102000')
                                ]),
                              ]),
                            ]),
                            XmlElement.tag('a:gs', attributes: [
                              XmlAttribute(XmlName.fromString('pos'), '50000')
                            ], children: [
                              XmlElement.tag('a:schemeClr', attributes: [
                                XmlAttribute(XmlName.fromString('val'), 'phClr')
                              ], children: [
                                XmlElement.tag('a:tint', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '98000')
                                ]),
                                XmlElement.tag('a:satMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '130000')
                                ]),
                                XmlElement.tag('a:shade', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '90000')
                                ]),
                                XmlElement.tag('a:lumMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '103000')
                                ]),
                              ]),
                            ]),
                            XmlElement.tag('a:gs', attributes: [
                              XmlAttribute(XmlName.fromString('pos'), '100000')
                            ], children: [
                              XmlElement.tag('a:schemeClr', attributes: [
                                XmlAttribute(XmlName.fromString('val'), 'phClr')
                              ], children: [
                                XmlElement.tag('a:shade', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '63000')
                                ]),
                                XmlElement.tag('a:satMod', attributes: [
                                  XmlAttribute(
                                      XmlName.fromString('val'), '120000')
                                ]),
                              ]),
                            ]),
                          ]),
                          XmlElement.tag('a:lin', attributes: [
                            XmlAttribute(XmlName.fromString('ang'), '5400000'),
                            XmlAttribute(XmlName.fromString('scaled'), '0')
                          ]),
                        ],
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
