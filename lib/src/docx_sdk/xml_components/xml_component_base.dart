import 'package:xml/xml.dart';
import '../sdk.dart';

abstract class XmlComponentBase<T extends XmlComponentBase<T>> {
  XmlComponentBase({
    required this.xmlKey,
    List<T>?elements,
  }) : elements = elements ?? <T>[], attributes = [];

  final String xmlKey;
  final List<T> elements;
  final List<XmlComponentAttributes> attributes;

  XmlElement buildXml(DocxComponentContext context);

  void insert() => throw Exception('Not insert implemented yet');
  void replace() => throw Exception('Not replace implemented yet');
  void delete() => throw Exception('Not delete implemented yet');
}

class XmlComponentAttributes {
  XmlComponentAttributes({required this.key, required this.value});

  final String key;
  final String value;
}
