import 'package:xml/xml.dart';

/// Options for typeface elements (a:latin, a:ea, a:cs).
class TypefaceOptions {
  const TypefaceOptions({
    required this.latin,
    required this.eastAsia,
    required this.complexScript,
  });

  final String latin;
  final String eastAsia;
  final String complexScript;

  XmlElement buildLatinXml() => XmlElement(
        XmlName('a:latin'),
        [
          XmlAttribute(
            XmlName('typeface'),
            latin,
          ),
        ],
      );

  XmlElement buildEastAsiaXml() => XmlElement(
        XmlName('a:ea'),
        [
          XmlAttribute(
            XmlName('typeface'),
            eastAsia,
          ),
        ],
      );

  XmlElement buildComplexScriptXml() => XmlElement(
        XmlName('a:cs'),
        [
          XmlAttribute(
            XmlName('typeface'),
            complexScript,
          ),
        ],
      );
}
