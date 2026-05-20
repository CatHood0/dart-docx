import 'package:xml/xml.dart';
import '../../core/extensions/string_ext.dart';
import '../sdk.dart';

//TODO: we should probably make attributes parts of an mixin or interface, value idk, and xmlKey a mixin too
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

  XmlElement buildXml();

  XmlDocument buildDocument() {
    return XmlDocument(
      <XmlNode>[
        XmlDefaults.declaration,
        buildXml(),
      ],
    );
  }
}

class XmlTextElementComponent<T> extends XmlComponentBase<T> {
  XmlTextElementComponent({
    required super.xmlKey,
    required super.value,
    super.attrs,
  });

  @override
  XmlElement buildXml() {
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
  XmlElement buildXml() {
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
  XmlElement buildXml() {
    return value;
  }
}

class XmlElementWithChild extends XmlComponentBase<XmlComponentBase> {
  XmlElementWithChild({required super.xmlKey, required super.value});

  @override
  XmlElement buildXml() {
    return XmlElement.tag(
      xmlKey,
      children: <XmlNode>[
        value.buildXml(),
      ],
    );
  }
}
