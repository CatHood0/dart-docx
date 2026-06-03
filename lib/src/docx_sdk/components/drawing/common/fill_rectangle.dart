import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:fillRect
class FillRectangle extends DocxNode<dynamic> {
  FillRectangle({super.id, super.parent}) : super(child: null);

  @override
  FillRectangle get copy => FillRectangle(
        id: id,
        parent: parent,
      );

  @override
  FillRectangle copyWith({String? id, DocxNode<dynamic>? parent}) {
    return FillRectangle(
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      XmlElement.tag(
        'a:fillRect',
        isSelfClosing: true,
      ),
    ];
  }

  @override
  List<FillRectangle>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  FillRectangle? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
