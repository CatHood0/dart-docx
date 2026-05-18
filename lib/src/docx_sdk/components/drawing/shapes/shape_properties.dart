import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../shared/effects.dart';
import '../shared/fill.dart';
import '../shared/geometry.dart';

/// Visual properties of a shape (wps:spPr).
///
/// Contains all visual aspects: geometry, fill, outline, effects,
/// and 2D transform (position, size, rotation).
class ShapeProperties extends DocxNode<void> {
  ShapeProperties({
    required this.transform,
    required this.geometryComponent,
    this.fill,
    this.border,
    this.effects,
    super.id,
    super.parent,
  }) : super(child: null) {
    final List<DocxNode<dynamic>> components = <DocxNode<dynamic>>[
      transform,
      geometryComponent,
    ];

    if (fill != null) components.add(fill!);
    if (border != null) components.add(border!);
    if (effects != null) components.add(effects!);

    for (int i = 0; i < components.length; i++) {
      components[i]
        ..parent = this
        ..index = i
        ..depth = depth + 1;
    }
  }

  factory ShapeProperties.preset({
    required Transform2D transform,
    required PresetShapeType preset,
    Fill<dynamic>? fill,
    ShapeBorder? border,
    Effect<dynamic>? effect,
    String? id,
    DocxNode? parent,
  }) {
    return ShapeProperties(
      transform: transform,
      geometryComponent: PresetGeometry(preset: preset),
      fill: fill,
      border: border,
      effects: effect,
      id: id,
      parent: parent,
    );
  }

  factory ShapeProperties.custom({
    required Transform2D transform,
    required CustomGeometryComponent geometry,
    Fill<dynamic>? fill,
    ShapeBorder? border,
    Effect<dynamic>? effect,
    String? id,
    DocxNode? parent,
  }) {
    return ShapeProperties(
      transform: transform,
      geometryComponent: geometry,
      fill: fill,
      border: border,
      effects: effect,
      id: id,
      parent: parent,
    );
  }

  /// 2D transformation (position, size, rotation).
  final Transform2D transform;

  /// List of geometry components (usually one, but can be multiple for groups).
  final Geometry<dynamic> geometryComponent;

  /// Fill styling (solid, gradient, pattern, or picture).
  final Fill<dynamic>? fill;

  /// Outline/border styling.
  final DocxNode<dynamic>? border;

  /// Visual effects (shadow, glow, reflection, 3D).
  final Effect<dynamic>? effects;

  @override
  List<XmlNode> buildXml() {
    final List<XmlNode> children = <XmlNode>[
      ...transform.ensureInitialized(context).buildXml(),
      ...geometryComponent.ensureInitialized(context).buildXml(),
    ];

    if (fill != null) {
      children.addAll(fill!.ensureInitialized(context).buildXml());
    }

    if (border != null) {
      children.addAll(border!.ensureInitialized(context).buildXml());
    }

    if (effects != null) {
      children.addAll(effects!.ensureInitialized(context).buildXml());
    }

    return <XmlNode>[
      XmlElement.tag(
        'wps:spPr',
        children: children,
      ),
    ];
  }

  @override
  ShapeProperties get copy => ShapeProperties(
        id: id,
        transform: transform,
        geometryComponent: geometryComponent,
        fill: fill,
        border: border,
        effects: effects,
        parent: parent,
      );

  @override
  ShapeProperties copyWith({
    String? id,
    DocxNode<void>? parent,
    Transform2D? transform,
    Geometry<dynamic>? geometryComponent,
    Fill<dynamic>? fill,
    DocxNode<dynamic>? border,
    Effect<dynamic>? effects,
  }) {
    return ShapeProperties(
      transform: transform ?? this.transform,
      geometryComponent: geometryComponent ?? this.geometryComponent,
      fill: fill ?? this.fill,
      border: border ?? this.border,
      effects: effects ?? this.effects,
      parent: parent ?? this.parent,
      id: id ?? this.id,
    );
  }

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxNode<dynamic>>[this];

    final List<DocxNode<dynamic>> results = <DocxNode<dynamic>>[];

    final List<DocxNode<dynamic>>? transformResult = transform.visitAllElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
    if (transformResult != null) results.addAll(transformResult);

    final List<DocxNode<dynamic>>? geometryResult =
        geometryComponent.visitAllElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
    if (geometryResult != null) results.addAll(geometryResult);

    if (fill != null) {
      final List<DocxNode<dynamic>>? fillResult = fill!.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (fillResult != null) results.addAll(fillResult);
    }

    if (border != null) {
      final List<DocxNode<dynamic>>? outlineResult = border!.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (outlineResult != null) results.addAll(outlineResult);
    }

    if (effects != null) {
      final List<DocxNode<dynamic>>? effectsResult = effects!.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (effectsResult != null) results.addAll(effectsResult);
    }

    return results.isNotEmpty ? results : null;
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;

    DocxNode<dynamic>? result = transform.visitElement(
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

    if (border != null) {
      result = border!.visitElement(
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
