import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../../../../core/extensions/cast_ext.dart';

/// Wordprocessing Shape (wps:wsp).
class WPShape extends DocxTreeNode<DocxTreeNode> {
  WPShape({
    required this.shapeProperties,
    this.name = 'unnamed-shape',
    this.description = '',
    this.shapeLocks = true,
    this.textBox,
    super.id,
    super.parent,
  }) : super(child: shapeProperties) {
    final List<DocxTreeNode<dynamic>> components = <DocxTreeNode<dynamic>>[
      shapeProperties,
      if (textBox != null)
        textBox!
      else
        ShapeTextBox(child: ShapeTextBoxData.empty()),
    ];

    for (int i = 0; i < components.length; i++) {
      components[i]
        ..parent = this
        ..index = i
        ..depth = depth + 1;
    }
  }

  /// Display name (appears in selection pane and alt text).
  final String name;

  /// Description for accessibility and tooltips.
  final String description;

  /// Shape locks prevent certain modifications in Word UI
  final bool shapeLocks;

  /// Visual properties: geometry, fill, outline, effects, and transform.
  final ShapeProperties shapeProperties;

  /// Optional text box within the shape (wps:txbx).
  final ShapeTextBox? textBox;

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    context.currentContentPart = this;
    final Anchor? anchor = context.getAncestorOfExactType<Anchor>();
    final Inline? inline = context.getAncestorOfExactType<Inline>();
    final int shapeId = anchor?.elementId?.castOrNull() ??
        inline?.elementId?.castOrNull() ??
        context.drawingStore.getNextId(id);

    final NonVisualShapeProperties nonVisualProperties =
        NonVisualShapeProperties(
      id: shapeId.toString(),
      name: name,
      description: description,
      shapeLocks: shapeLocks,
    );

    final num? width = anchor?.width ?? inline?.width.toInt();
    final num? height = anchor?.height ?? inline?.height.toInt();
    assert(
      width != null && height != null,
      'Founded non defined size '
      'properties for $runtimeType:$id. Size(w: $width, h: $height)',
    );

    assert(
      width == shapeProperties.transform.extents.cx,
      'the ${anchor?.runtimeType ?? inline?.runtimeType ?? 'N/A'} width must be equals than the '
      'ShapeProperties -> Transform2D -> AnnotationExtents -> cx',
    );

    assert(
      height == shapeProperties.transform.extents.cy,
      'the ${anchor?.runtimeType ?? inline?.runtimeType ?? 'N/A'} height must be equals than the '
      'ShapeProperties -> Transform2D -> AnnotationExtents -> cy specified',
    );

    final List<XmlNode> children = <XmlNode>[
      ...nonVisualProperties.buildXml(context: context),
      ...shapeProperties.buildXml(context: context),
    ];

    if (textBox != null) {
      children.addAll(textBox!.buildXml(context: context));
    }

    return <XmlElement>[
      XmlElement.tag(
        'wps:wsp',
        children: children,
      ),
    ];
  }

  @override
  WPShape get copy => WPShape(
        id: id,
        name: name,
        textBox: textBox,
        description: description,
        shapeLocks: shapeLocks,
        shapeProperties: shapeProperties,
      );

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxTreeNode<dynamic>>[this];

    final List<DocxTreeNode<dynamic>> results = <DocxTreeNode<dynamic>>[];

    final List<DocxTreeNode<dynamic>>? shapeResult =
        shapeProperties.visitAllElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
    if (shapeResult != null) results.addAll(shapeResult);

    if (textBox != null) {
      final List<DocxTreeNode<dynamic>>? textBoxResult =
          textBox!.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (textBoxResult != null) results.addAll(textBoxResult);
    }

    return results.isNotEmpty ? results : null;
  }

  @override
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;

    DocxTreeNode<dynamic>? result = shapeProperties.visitElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
    if (result != null) return result;

    if (textBox != null) {
      result = textBox!.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }

    return null;
  }
}
