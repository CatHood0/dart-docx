import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import 'entities/math_properties.dart';

/// Represents the `<m:mathPr>` element in WordML settings.
class XmlMathPrComponent extends XmlComponentBase<MathPropertiesOptions> {
  XmlMathPrComponent({required MathPropertiesOptions options})
      : super(
          xmlKey: 'm:mathPr',
          value: options,
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    final List<XmlNode> children = [];

    if (value.mathFont != null) {
      children.add(
        XmlElement(
          XmlName('m:mathFont'),
          [
            XmlAttribute(
              XmlName('m:val'),
              value.mathFont!,
            ),
          ],
        ),
      );
    }
    if (value.breakBinary != null) {
      children.add(
        XmlElement(
          XmlName('m:brkBin'),
          [
            XmlAttribute(
              XmlName('m:val'),
              value.breakBinary!.name,
            ),
          ],
        ),
      );
    }
    if (value.breakBinarySubtraction != null) {
      children.add(
        XmlElement(
          XmlName('m:brkBinSub'),
          [
            XmlAttribute(
              XmlName('m:val'),
              value.breakBinarySubtraction!.name,
            ),
          ],
        ),
      );
    }
    if (value.displayLoop != null) {
      children.add(
        XmlElement(
          XmlName('m:dispLMargin'),
          [
            XmlAttribute(
              XmlName('m:val'),
              value.displayLoop!.name,
            ),
          ],
        ),
      );
    }
    if (value.integerLimit == true) {
      children.add(
        XmlElement(
          XmlName('m:intLim'),
          [
            XmlAttribute(
              XmlName('m:val'),
              '1',
            ),
          ],
        ),
      );
    }
    if (value.wrapIndent != null) {
      children.add(
        XmlElement(
          XmlName('m:wrapIndent'),
          [
            XmlAttribute(
              XmlName('m:val'),
              value.wrapIndent!,
            ),
          ],
        ),
      );
    }

    return XmlElement.tag(
      xmlKey,
      children: children,
    );
  }
}
