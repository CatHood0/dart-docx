import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../../../../core/extensions/cast_ext.dart';

class Padding extends DocxNode<DocxNode<dynamic>> {
  Padding({
    required this.padding,
    required super.child,
    super.id,
    super.parent,
  }) {
    child
      ..parent = this
      ..index = 0
      ..depth = depth + 1;
  }

  final EdgeInsets padding;

  @override
  List<XmlNode> buildXml() {
    if (child is! Row &&
        child is! Table &&
        child.visitElement(
                visitChildrenIfNeeded: true,
                (DocxNode<dynamic> e) => e is Row || e is Table) ==
            null) {
      int maxWidth =
          context.getAncestorOfExactType<LayoutConstraints>()?.maxWidth ??
              context.options.availablePageWidth;

      return LayoutConstraints(
        maxWidth:
            maxWidth > 0 ? maxWidth - padding.all().twipsToPt().ptToDxa() : 0,
        children: <DocxNode<dynamic>>[
          Table(
            id: id,
            parent: this,
            tableProperties: TableProperties(
              width: maxWidth,
              widthType: TableWidthType.dxa,
              layout: true,
              padding: padding,
            ),
            columns: maxWidth > 0
                ? GridColumn(width: maxWidth.toInt()).toList()
                : GridColumn.intrintric().toList(),
            rows: TableRow.one(
              cell: child.tableCell(
                cellConfig: TableCellConfig.dxa(width: maxWidth),
              ),
            ).toList(),
          )
        ],
      ).ensureInitialized(context).buildXml();
    }
    return child.ensureInitialized(context).buildXml();
  }

  @override
  Padding get copy => Padding(
        id: id,
        padding: padding,
        parent: parent,
        child: child,
      );

  @override
  Padding copyWith({
    DocxNode<dynamic>? child,
    String? id,
    DocxNode<dynamic>? parent,
    EdgeInsets? padding,
  }) {
    return Padding(
      padding: padding ?? this.padding,
      child: child ?? this.child,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    if (shouldGetElement(child)) {
      return child;
    } else if (visitChildrenIfNeeded) {
      final DocxNode? foundedEl = child.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: true,
      );
      if (foundedEl != null) {
        return foundedEl;
      }
    }
    return null;
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (child.isEmptyNode() ||
        child.castOrNull<IgnorableMixin>()?.shouldIgnore() == true) {
      return <DocxNode>[];
    }
    final List<DocxNode> elements = <DocxNode>[];
    if (shouldGetElement(child)) {
      elements.add(child);
    } else if (visitChildrenIfNeeded) {
      final List<DocxNode<dynamic>>? foundedEl = child.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: true,
      );
      if (foundedEl != null) {
        elements.addAll(foundedEl);
      }
    }
    return elements;
  }
}

/// Internal padding within a component.
///
/// Values are typically specified in twips (1/1440 inch), but can use
/// other units when combined with appropriate XML attributes.
///
/// Example usage:
/// ```dart
/// EdgeInsets(
///   top: 100,    // 100 twips padding on top
///   right: 80,   // 80 twips padding on right
///   bottom: 100, // 100 twips padding on bottom
///   left: 120,   // 120 twips padding on left
/// ),
/// ```
class EdgeInsets {
  const EdgeInsets({
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  const EdgeInsets.zero()
      : top = 0,
        right = 0,
        bottom = 0,
        left = 0;

  const EdgeInsets.all(num value)
      : top = value,
        right = value,
        bottom = value,
        left = value;

  const EdgeInsets.symmetric({
    num? vertical,
    num? horizontal,
  })  : top = vertical,
        right = horizontal,
        bottom = vertical,
        left = horizontal;

  /// Top margin (padding) inside the cell in twip units.
  ///
  /// Spacing between the cell's top border and its content.
  /// Use `null` to inherit from table-level margins.
  final num? top;

  /// Right margin (padding) inside the cell in twip units.
  ///
  /// Spacing between the cell's right border and its content.
  /// Use `null` to inherit from table-level margins.
  final num? right;

  /// Bottom margin (padding) inside the cell in twip units.
  ///
  /// Spacing between the cell's bottom border and its content.
  /// Use `null` to inherit from table-level margins.
  final num? bottom;

  /// Left margin (padding) inside the cell in twip units.
  ///
  /// Spacing between the cell's left border and its content.
  /// Use `null` to inherit from table-level margins.
  final num? left;

  num all() {
    return (top ?? 0) + (left ?? 0) + (bottom ?? 0) + (right ?? 0);
  }

  @override
  String toString() {
    return '$runtimeType(left: $left, right: $right, top: $top, bottom: $bottom)';
  }
}
