import 'package:xml/xml.dart';

import '../sdk.dart';

class DocxDocument {
  DocxDocument({
    required this.root,
    required this.options,
  });

  final DocumentRoot root;

  //NOTE: probably we will move these to DocxDocument class
  final DocumentOptions options;

  List<XmlNode> buildXml({required DocumentContext context}) {
    return root.buildXml(context: context);
  }

  String toPlainText() {
    final StringBuffer buffer = StringBuffer();
    for (final Paragraph pr in root.data.whereType<Paragraph>()) {
      for (final PrintableMixin content
          in pr.data.whereType<PrintableMixin>()) {
        buffer.write(content.toPlainText());
      }
    }
    return '$buffer';
  }
}
