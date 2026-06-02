import 'package:xml/xml.dart';

import '../../../docx.dart';
import 'node_to_configurator.dart';
import 'string_ext.dart';

extension StyleToNode on Style {
  /// Converts a Style class into a valid XmlElement that can be used to putted into styles.xml file
  XmlElement? toReferenceNode({String prefix = 'r'}) {
    return XmlElement.tag(
      'w:${prefix}Style',
      attributes: <XmlAttribute>[
        XmlAttribute(
          'w:val'.toName(),
          styleId,
        ),
      ],
      isSelfClosing: true,
    );
  }

  XmlElement? toParagraphPropertyElement() {
    final StyleConfigurator runConfigs =
        getConfigurator(xmlParagraphBlockAttrsNode);
    if (runConfigs.isInvalid) return null;
    return XmlElement.tag(
      'w:pPr',
      children: <XmlNode>[
        ...runConfigs.childrenToXmlNodes(),
      ],
      isSelfClosing: false,
    );
  }

  XmlElement? toRunPropertyElement() {
    final StyleConfigurator runConfigs =
        getConfigurator(xmlParagraphInlineAttsrNode);
    if (runConfigs.isInvalid) return null;
    //TODO: why we aren't returning the runConfigs directly?
    return XmlElement.tag(
      'w:rPr',
      children: <XmlNode>[
        ...runConfigs.childrenToXmlNodes(),
      ],
      isSelfClosing: false,
    );
  }

  List<XmlElement> forTableStyle({
    bool shouldShowStyleRef = true,
    bool useConfigurators = true,
  }) {
    final StyleConfigurator configs = !useConfigurators
        ? StyleConfigurator.invalid()
        : getConfigurator(
            xmlTablePropertiesNode,
            fullName: true,
          );
    assert(
        styleId.isNotEmpty,
        'styleId must not '
        'have empty string at this build phase.');

    return <XmlElement>[
      if (shouldShowStyleRef)
        XmlElement.tag(
          xmlTableStyleNode,
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:val'.toName(),
              styleId,
            ),
          ],
          isSelfClosing: true,
        ),
      if (useConfigurators) ...configs.childrenToXmlNodes(),
    ];
  }

  List<XmlElement> forTableRowStyle({
    bool shouldShowStyleRef = true,
    bool useConfigurators = true,
  }) {
    final StyleConfigurator configs = !useConfigurators
        ? StyleConfigurator.invalid()
        : getConfigurator(
            xmlTableRowPropertiesNode,
            fullName: true,
          );
    assert(
        styleId.isNotEmpty,
        'styleId must not '
        'have empty string at this build phase.');

    return <XmlElement>[
      if (shouldShowStyleRef)
        XmlElement.tag(
          xmlTableStyleNode,
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:val'.toName(),
              styleId,
            ),
          ],
          isSelfClosing: true,
        ),
      if (useConfigurators) ...configs.childrenToXmlNodes(),
    ];
  }

  List<XmlElement> forRunStyle({
    bool shouldShowStyleRef = true,
    bool useConfigurators = true,
  }) {
    final StyleConfigurator runConfigs =
        !useConfigurators ? StyleConfigurator.invalid() : runProperties!;
    assert(
        styleId.isNotEmpty,
        'styleId must not '
        'have empty string at this build phase.');
    assert(
        !runConfigs.isInvalid,
        'runConfigs must not be '
        'invalid at this build phase.');

    return <XmlElement>[
      if (shouldShowStyleRef)
        XmlElement.tag(
          xmlRunStyleNode,
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:val'.toName(),
              styleId,
            ),
          ],
          isSelfClosing: true,
        ),
      if (useConfigurators) ...runConfigs.childrenToXmlNodes(),
    ];
  }

  List<XmlElement> forParagraphStyle({
    bool shouldShowStyleRef = true,
    bool useConfigurators = true,
  }) {
    final StyleConfigurator? prConfigs =
        !useConfigurators ? StyleConfigurator.invalid() : paragraphProperties;
    assert(
        styleId.isNotEmpty,
        'styleId must not '
        'have empty string at this build phase.');
    assert(
        prConfigs == null || !prConfigs.isInvalid,
        'runConfigs must not be '
        'invalid at this build phase.');

    return <XmlElement>[
      if (shouldShowStyleRef)
        XmlElement.tag(
          xmlParagraphStyleNode,
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:val'.toName(),
              styleId,
            ),
          ],
          isSelfClosing: true,
        ),
      if (useConfigurators && prConfigs != null)
        ...prConfigs.childrenToXmlNodes(),
    ];
  }
}
