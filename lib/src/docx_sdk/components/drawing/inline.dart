import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../../core/extensions/string_ext.dart';
import '../../mixins/ignorable_mixin.dart';

/// Inline drawing element for images and shapes that flow with text.
///
/// Represents the `wp:inline` element in DrawingML, used for images and
/// shapes that are positioned inline with text (similar to text characters).
/// Inline elements have fixed positioning within the text flow and cannot
/// be wrapped around by text.
///
/// This is typically used for small icons, emojis, or images that should
/// behave like text characters in the document flow.
///
/// Example usage:
/// ```dart
/// final inline = Inline(
///   name: 'logo.png',
///   width: 1000000, // EMU units
///   height: 500000, // EMU units
///   distance: TextDistance.all(0),
///   components: [myGraphic],
/// );
/// ```
class Inline extends DocxNode<Iterable<DocxNode>> {
  Inline({
    required Iterable<DocxNode> components,
    required this.name,
    required this.width,
    required this.height,
    required this.distance,
    super.id,
  }) : super(child: components) {
    int index = 0;
    for (final DocxNode<dynamic> content in child) {
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  /// Text wrapping distances around the inline element.
  final TextDistance distance;

  /// Unique element identifier for this inline drawing
  /// required for [DocProperties]
  int? elementId;

  /// Descriptive name for the inline element.
  final String name;

  /// Width of the inline element in EMU units (English Metric Units).
  final num width;

  /// Height of the inline element in EMU units (English Metric Units).
  final num height;

  @override
  Inline get copy => Inline(
        id: id,
        height: height,
        name: name,
        width: width,
        components: child,
        distance: distance,
      );

  @override
  Inline copyWith({
    Iterable<DocxNode>? child,
    String? id,
    DocxNode<dynamic>? parent,
    TextDistance? distance,
    String? name,
    num? width,
    num? height,
  }) {
    return Inline(
      distance: distance ?? this.distance,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      components: child ?? this.child,
      id: id ?? this.id,
    )..parent = parent ?? this.parent;
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlNode> children = <XmlNode>[];
    for (final DocxNode<dynamic> element in child) {
      if (element is IgnorableMixin && element.cast<IgnorableMixin>().shouldIgnore()) {
        continue;
      }
      context.currentContentPart = element;
      children.addAll(element.buildXml(context: context));
    }
    elementId ??= context.drawingStore.getNextId(id);
    context.currentContentPart = this;
    return <XmlElement>[
      XmlElement.tag(
        'wp:inline',
        attributes: <XmlAttribute>[
          XmlAttribute(
            'distT'.toName(),
            distance.top.toString(),
          ),
          XmlAttribute(
            'distB'.toName(),
            distance.bottom.toString(),
          ),
          XmlAttribute(
            'distL'.toName(),
            distance.left.toString(),
          ),
          XmlAttribute(
            'distR'.toName(),
            distance.right.toString(),
          ),
        ],
        isSelfClosing: children.isEmpty,
        children: <XmlNode>[
          ...Extent(
            cx: width,
            cy: height,
          ).buildXml(context: context),
          ...DocProperties(
            docPrId: elementId!.toString(),
            name: name,
            description: name,
          ).buildXml(context: context),
          ...children,
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
    for (final DocxNode<dynamic> el in child) {
      final List<DocxNode<dynamic>>? result = el.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }
    return null;
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    for (final DocxNode<dynamic> el in child) {
      final DocxNode<dynamic>? result = el.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }
    return null;
  }
}
