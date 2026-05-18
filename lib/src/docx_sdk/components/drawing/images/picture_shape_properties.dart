import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents pic:spPr
class PictureShapeProperties extends DocxNode<dynamic> {
  PictureShapeProperties({
    required this.transform2D,
    required this.presetGeometry,
    super.id,
    super.parent,
  }) : super(child: null);

  final Transform2D transform2D;
  final PresetGeometry presetGeometry;

  @override
  PictureShapeProperties get copy => PictureShapeProperties(
        transform2D: transform2D.copy,
        presetGeometry: presetGeometry.copy,
        id: id,
        parent: parent,
      );

  @override
  PictureShapeProperties copyWith({
    String? id,
    DocxNode<dynamic>? parent,
    Transform2D? transform2D,
    PresetGeometry? presetGeometry,
  }) {
    return PictureShapeProperties(
      transform2D: transform2D ?? this.transform2D.copy,
      presetGeometry: presetGeometry ?? this.presetGeometry.copy,
      parent: parent ?? this.parent,
      id: id ?? this.id,
    );
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      XmlElement.tag(
        'pic:spPr',
        isSelfClosing: false,
        children: [
          ...transform2D.ensureInitialized(context).buildXml(),
          ...presetGeometry.ensureInitialized(context).buildXml(),
          XmlElement.tag('a:noFill', isSelfClosing: true),
        ],
      ),
    ];
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return [this];
    if (!visitChildrenIfNeeded) return null;
    return transform2D.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        presetGeometry.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return transform2D.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        presetGeometry.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded);
  }
}
