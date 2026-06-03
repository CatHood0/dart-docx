import 'package:xml/xml.dart';

import '../sdk.dart';

//TODO: we should support indexing most modified was used paths
// for the stores
class DocxDocument {
  DocxDocument({
    required this.root,
    required this.options,
  });

  final DocxNode root;

  //NOTE: probably we will move these to DocxDocument class
  final DocumentOptions options;

  List<XmlNode> buildXml() {
    return root.buildXml();
  }

  String toPlainText() {
    final StringBuffer buffer = StringBuffer();
    for (final Paragraph pr in root.child.whereType<Paragraph>()) {
      for (final PrintableMixin content in pr.child.whereType<PrintableMixin>()) {
        buffer.write(content.toPlainText());
      }
    }
    return '$buffer';
  }
}
