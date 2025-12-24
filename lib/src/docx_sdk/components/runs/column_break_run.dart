import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';

class ColumnBreakRun extends RunBase<void> {
  ColumnBreakRun()
      : super(
          data: null,
        );

  @override
  XmlElement buildXml({required DocumentContext context}) {
    return XmlElement.tag(
      'w:br',
      attributes: [
        XmlAttribute(
          'w:type'.toName(),
          'column',
        ),
      ],
      isSelfClosing: true,
    );
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  DocxContent<dynamic> get copy => ColumnBreakRun();

  @override
  bool get isEmptyData => true;

  @override
  String toPlainText() {
    return '\n';
  }

  @override
  String toString() {
    throw UnimplementedError();
  }
}
