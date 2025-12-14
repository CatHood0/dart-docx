import 'package:xml/xml.dart';

import '../../../docx_transformer.dart';

extension XmlNodeToStyleConfigurator on XmlElement {
  StyleConfigurator get toConfigurator {
    final Map<String, dynamic> attributes = <String, dynamic>{};
    for (final attr in this.attributes) {
      if (attr.localName == 'val') continue;
      attributes[attr.qualifiedName] = attr.value;
    }
    return isSelfClosing
        ? StyleConfigurator.autoClosure(
            propertyName: name.local,
            prefix: name.prefix,
            value: getAttribute('w:val'),
            attributes: attributes,
            configurators: <StyleConfigurator>[
              ...children.whereType<XmlElement>().map(
                    (XmlElement node) => node.toConfigurator,
                  ),
            ],
          )
        : StyleConfigurator.noAutoClosure(
            propertyName: name.local,
            attributes: attributes,
            prefix: name.prefix,
            value: getAttribute('w:val'),
            configurators: <StyleConfigurator>[
              ...children.whereType<XmlElement>().map(
                    (XmlElement node) => node.toConfigurator,
                  ),
            ],
          );
  }
}

extension StyleConfiguratorToXmlNode on StyleConfigurator {
  XmlElement get toXmlNode {
    final List<XmlAttribute> xmlAttributes = [];

    if (value != null) {
      xmlAttributes.add(
        XmlAttribute(
          XmlName.fromString('w:val'),
          value.toString(),
        ),
      );
    }

    for (final MapEntry<String, dynamic> attr
        in (attributes ?? <String, dynamic>{}).entries) {
      if (attr.key == 'w:val' && value != null) {
        continue;
      }
      xmlAttributes.add(
        XmlAttribute(
          XmlName.fromString(attr.key),
          attr.value.toString(),
        ),
      );
    }

    final List<XmlNode> childrenNodes = configurators
        .map(
          (StyleConfigurator e) => e.toXmlNode,
        )
        .whereType<XmlElement>()
        .toList();

    final bool shouldBeSelfClosing = isAutoClosure && childrenNodes.isEmpty;

    return XmlElement(
      XmlName.fromString(
        qualifiedName,
      ),
      xmlAttributes,
      childrenNodes,
      shouldBeSelfClosing,
    );
  }

  /// Returns the children nodes instead the current node wrapped
  ///
  /// Tipically this is used when is detected that this style
  /// is a w:pPr or a w:rPr where we just need its children values
  List<XmlElement> get toNodes {
    final List<XmlAttribute> xmlAttributes = [];

    for (final MapEntry<String, dynamic> attr
        in (attributes ?? <String, dynamic>{}).entries) {
      if (attr.key == 'w:val' && value != null) {
        continue;
      }
      xmlAttributes.add(
        XmlAttribute(
          XmlName.fromString(attr.key),
          attr.value.toString(),
        ),
      );
    }

    final List<XmlElement> childrenNodes = configurators
        .map(
          (StyleConfigurator e) => e.toXmlNode,
        )
        .whereType<XmlElement>()
        .toList();

    return childrenNodes;
  }
}
