import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../shared/effects.dart';
import '../shared/fill.dart';
import '../shared/geometry.dart';

/// Visual properties of a shape (wps:spPr).
///
/// Contains all visual aspects: geometry, fill, outline, effects,
/// and 2D transform (position, size, rotation).
class ShapeProperties extends DocxTreeNode<void> {
  ShapeProperties({
    required this.transform2D,
    required this.geometryComponent,
    this.fill,
    this.outline,
    this.effects,
  }) : super(data: null) {
    final List<DocxTreeNode<dynamic>> components = <DocxTreeNode<dynamic>>[
      transform2D,
      geometryComponent,
    ];

    if (fill != null) components.add(fill!);
    if (outline != null) components.add(outline!);
    if (effects != null) components.add(effects!);

    for (int i = 0; i < components.length; i++) {
      components[i]
        ..parent = this
        ..index = i
        ..depth = depth + 1;
    }
  }

  /// 2D transformation (position, size, rotation).
  final Transform2D transform2D;

  /// List of geometry components (usually one, but can be multiple for groups).
  final Geometry<dynamic> geometryComponent;

  /// Fill styling (solid, gradient, pattern, or picture).
  final Fill<dynamic>? fill;

  /// Outline/border styling.
  final DocxTreeNode<dynamic>? outline;

  /// Visual effects (shadow, glow, reflection, 3D).
  final Effect<dynamic>? effects;

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlNode> children = <XmlNode>[
      ...transform2D.buildXml(context: context),
      ...geometryComponent.buildXml(context: context),
    ];

    if (fill != null) {
      children.addAll(fill!.buildXml(context: context));
    }

    if (outline != null) {
      children.addAll(outline!.buildXml(context: context));
    }

    if (effects != null) {
      children.addAll(effects!.buildXml(context: context));
    }

    context.currentContentPart = this;
    return <XmlElement>[
      XmlElement.tag(
        'wps:spPr',
        children: children,
      ),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  ShapeProperties get copy => ShapeProperties(
        transform2D: transform2D,
        geometryComponent: geometryComponent,
        fill: fill,
        outline: outline,
        effects: effects,
      );

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxTreeNode<dynamic>>[this];

    final List<DocxTreeNode<dynamic>> results = <DocxTreeNode<dynamic>>[];

    final List<DocxTreeNode<dynamic>>? transformResult =
        transform2D.visitAllElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
    if (transformResult != null) results.addAll(transformResult);

    final List<DocxTreeNode<dynamic>>? geometryResult =
        geometryComponent.visitAllElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
    if (geometryResult != null) results.addAll(geometryResult);

    if (fill != null) {
      final List<DocxTreeNode<dynamic>>? fillResult = fill!.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (fillResult != null) results.addAll(fillResult);
    }

    if (outline != null) {
      final List<DocxTreeNode<dynamic>>? outlineResult =
          outline!.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (outlineResult != null) results.addAll(outlineResult);
    }

    if (effects != null) {
      final List<DocxTreeNode<dynamic>>? effectsResult =
          effects!.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (effectsResult != null) results.addAll(effectsResult);
    }

    return results.isNotEmpty ? results : null;
  }

  @override
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;

    DocxTreeNode<dynamic>? result = transform2D.visitElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
    if (result != null) return result;

    result = geometryComponent.visitElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
    if (result != null) return result;

    if (fill != null) {
      result = fill!.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }

    if (outline != null) {
      result = outline!.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }

    if (effects != null) {
      result = effects!.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }

    return null;
  }
}
