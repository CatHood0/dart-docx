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
  XmlElement buildXml() {
    final List<XmlNode> children = <XmlNode>[];

    if (value.mathFont != null) {
      children.add(
        XmlElement(
          XmlName('m:mathFont'),
          <XmlAttribute>[
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
          <XmlAttribute>[
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
          <XmlAttribute>[
            XmlAttribute(
              XmlName('m:val'),
              value.breakBinarySubtraction!.value,
            ),
          ],
        ),
      );
    }
    if (value.displayLoop != null) {
      children.add(
        XmlElement(
          XmlName('m:dispLMargin'),
          <XmlAttribute>[
            XmlAttribute(
              XmlName('m:val'),
              value.displayLoop!.name,
            ),
          ],
        ),
      );
    }
    if (value.integerLimit != null) {
      children.add(
        XmlElement.tag(
          'm:intLim',
          isSelfClosing: true,
          attributes: <XmlAttribute>[
            XmlAttribute(
              XmlName('m:val'),
              value.integerLimit! ? 'subSup' : 'undOvr',
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
