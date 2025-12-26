import 'package:xml/xml.dart';
import '../../../../docx.dart';
import 'blip.dart';
import 'stretch.dart';

// Represents pic:blipFill
class BlipFill extends DocxTreeNode<dynamic> {
  BlipFill({
    required this.blip,
    required this.stretch,
  }) : super(data: null);

  final Blip blip;
  final Stretch stretch;

  @override
  BlipFill get copy => BlipFill(
        blip: blip.copy,
        stretch: stretch.copy,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'pic:blipFill',
        isSelfClosing: false,
        children: [
          ...blip.buildXml(context: context),
          ...stretch.buildXml(context: context),
        ],
      ),
    ];
  }

  @override
  List<BlipFill>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return [this];
    if (!visitChildrenIfNeeded) return null;
    return blip.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) as List<BlipFill>? ??
        stretch.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) as List<BlipFill>?;
  }

  @override
  BlipFill? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return blip.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) as BlipFill? ??
        stretch.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) as BlipFill?;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }
}

