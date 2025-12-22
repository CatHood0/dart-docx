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

  ///
  XmlElement buildXml(DocumentContext context);

  ///
  XmlDocument buildDocument(DocumentContext context) {
    return XmlDocument(
      [
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

  // since we will allow making some changes in tree
  // we will need adjust somethings in the current implementation
  void insert() =>
      throw Exception('Not insert implemented yet for $runtimeType');
  void replace() =>
      throw Exception('Not replace implemented yet for $runtimeType');
  void delete() =>
      throw Exception('Not delete implemented yet for $runtimeType');
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
  });

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: [
        if (value != null)
          XmlAttribute(
            (attrName ?? 'w:val').toName(),
            value.toString(),
          ),
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
