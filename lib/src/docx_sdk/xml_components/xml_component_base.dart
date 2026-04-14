import 'package:xml/xml.dart';
import '../../core/extensions/string_ext.dart';
import '../sdk.dart';

abstract class XmlComponentBase<T> {
  XmlComponentBase({
    required this.xmlKey,
    required this.value,
    XmlComponentAttributes attrs = const XmlComponentAttributes(
      xmlAttributes: <String, Object>{},
    ),
  }) : attributes = attrs;

  final String xmlKey;
  final T value;
  final XmlComponentAttributes attributes;

  String get path => '';

  /// The [name] of this component
  ///
  /// Useful when the compiler need to get 
  /// the component specified
  String get name => '';

  XmlElement buildXml(DocumentContext context);

  XmlDocument buildDocument(DocumentContext context) {
    return XmlDocument(
      <XmlNode>[
        XmlDefaults.declaration,
        buildXml(context),
      ],
    );
  }

  /// Visit the element that satisfies the predict
  /// and return the deep path of the element
  List<int> visitElement(bool Function(XmlComponentBase) component) {
    throw Exception('Not implemented visitElement');
  }

  /// Visit all elements that satisfies the conditions
  List<List<int>> visitElements(bool Function(XmlComponentBase) component) {
    throw Exception('Not implemented visitElements');
  }
}

class XmlTextElementComponent<T> extends XmlComponentBase<T> {
  XmlTextElementComponent({
    required super.xmlKey,
    required super.value,
    super.attrs,
  });

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: <XmlNode>[
        XmlDefaults.text(
          value.toString(),
        ),
      ],
      isSelfClosing: true,
    );
  }
}

class XmlEmptyElementComponent<T> extends XmlComponentBase<T> {
  final String? attrName;
  XmlEmptyElementComponent({
    required super.xmlKey,
    required super.value,
    this.attrName,
    super.attrs,
  });

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: <XmlAttribute>[
        if (value != null)
          XmlAttribute(
            (attrName ?? 'w:val').toName(),
            value.toString(),
          ),
        ...super.attributes.buildXml(),
      ],
      isSelfClosing: true,
    );
  }
}

class RawElement extends XmlComponentBase<XmlElement> {
  RawElement({required super.value})
      : super(
          xmlKey: value.qualifiedName,
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    return value;
  }
}

class XmlElementWithChild extends XmlComponentBase<XmlComponentBase> {
  XmlElementWithChild({required super.xmlKey, required super.value});

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      children: <XmlNode>[
        value.buildXml(context),
      ],
    );
  }
}
