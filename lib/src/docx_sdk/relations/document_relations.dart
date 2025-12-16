import 'package:xml/xml.dart';

import '../../../docx.dart';

class DocumentStore {
  DocumentStore({
    required this.styles,
    required this.mediaStore,
    required this.links,
  });

  final DocumentStylesSheet styles;
  final MediaStore mediaStore;
  final List<HyperlinkRun> links;
}

class DocumentRelations extends XmlComponentBase<DocumentStore> {
  DocumentRelations({required super.xmlKey, required super.value});

  @override
  XmlElement buildXml(DocumentContext context) {
    throw UnimplementedError();
  }
}
