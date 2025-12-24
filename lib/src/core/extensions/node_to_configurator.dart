import 'package:xml/xml.dart';

import '../../../docx.dart';
import 'xml_values_to_dart.dart';

extension XmlNodeToStyleConfigurator on XmlElement {
//TODO: please, document this
  StyleConfigurator toStyleConfigurator() {
    final Map<String, dynamic> attributes = <String, dynamic>{};
    Object? value;
    for (final XmlAttribute attr in this.attributes) {
      if (attr.qualifiedName == 'w:val') {
        value = attr.value.toExactValueFromXml();
        continue;
      }
      attributes[attr.qualifiedName] = attr.value.toExactValueFromXml();
    }
    // by some reason, some [XmlElement] instances can have its [isSelfClosing]
    // setted to true, but them had children... IDK
    final StyleConfigurator element = isSelfClosing && children.isEmpty
        ? StyleConfigurator.selfClosing(
            propertyName: name.local,
            prefix: name.prefix,
            value: value,
            attributes: attributes,
          )
        : StyleConfigurator.noSelfClosing(
            propertyName: name.local,
            prefix: name.prefix,
            value: value,
            attributes: attributes,
            configurators: <StyleConfigurator>[
              ...children.whereType<XmlElement>().map(
                    (XmlElement node) => node.toStyleConfigurator(),
                  ),
            ],
          );
    return element;
  }
}

extension StyleConfiguratorToXmlNode on StyleConfigurator {
  /// Returns the children nodes instead the current node wrapped
  ///
  /// Tipically this is used when is detected that this style
  /// is a w:pPr or a w:rPr where we just need its children values
  List<XmlElement> childrenToXmlNodes() {
    final List<XmlElement> childrenNodes = configurators
        .map(
          (StyleConfigurator e) => e.toXmlNode(),
        )
        .whereType<XmlElement>()
        .toList();

    return childrenNodes;
  }
}
