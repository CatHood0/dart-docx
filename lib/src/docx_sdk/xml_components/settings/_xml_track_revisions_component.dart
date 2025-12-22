
import 'package:xml/xml.dart';
import '../../../../../docx.dart';

/// Represents the `<w:trackRevisions>` element in WordML settings.
class XmlTrackRevisionsComponent extends XmlComponentBase {
  XmlTrackRevisionsComponent({required bool val})
      : super(
          xmlKey: 'w:trackRevisions',
          value: null,
          attrs: Attributes(val: val ? 'true' : 'false'),
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      isSelfClosing: true,
    );
  }
}
