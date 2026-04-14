import 'package:meta/meta.dart'
    show experimental, visibleForOverriding, protected;
import 'package:xml/xml.dart' show XmlNode;

import '../../../../docx.dart';
import '../../sdk.dart'
    show
        AnchorConfig,
        DocumentContext,
        ImageData,
        Paragraph,
        nanoid,
        Geometry,
        Transform2D,
        Fill,
        ShapeBorder,
        Effect,
        ShapeTextBox,
        Numbering,
        Style;
import 'empty_node.dart';
import 'lazy_node.dart';

abstract class DocxTreeNode<T> {
  DocxTreeNode({
    required this.child,
    this.parent,
    String? id,
  }) : id = id ?? nanoid(7);

  bool isEmptyNode() => this is EmptyNode;

  @experimental
  @protected
  int length = 0;

  @visibleForOverriding
  void addImage(
    ImageData data, {
    required bool anchored,
    String? id,
  }) {}

  @visibleForOverriding
  void addParagraph(
    Paragraph pr, {
    int? path,
  }) {}

  @visibleForOverriding
  void insertText(
    String text, {
    int? offset,
    int? path,
    List<Object>? styles,
    bool mergeStyles = true,
  }) {}

  @visibleForOverriding
  void deleteText({
    required int start,
    required int length,
    int? path,
  }) {}

  @visibleForOverriding
  void addListItem(
    String text, {
    required Numbering numbering,
    List<Style>? styles,
    int? path,
  }) {}

  @visibleForOverriding
  void addShape({
    required AnchorConfig config,
    required int width,
    required int height,
    required Geometry<dynamic> shape,
    String name = 'shape',
    String description = 'shape desc',
    Transform2D? transform,
    bool shapeLocks = true,
    @experimental Fill<dynamic>? fill,
    @experimental ShapeBorder? border,
    @experimental Effect<dynamic>? effect,
    @experimental ShapeTextBox? textBox,
    @experimental String? shapeId,
  }) {}

  /// Remove all the elements with the [id] specified
  ///
  /// If [path] is provided, will access directly to the element
  /// and will apply the remove action there, so, ensure that
  /// the path aims to the parent that already contains the
  /// element that needs to be remove
  @visibleForOverriding
  void removeById(String id, {List<int> path = const <int>[]}) {}

  /// Adds all the elements
  ///
  /// The way them are added depends on the class
  /// implementation
  @visibleForOverriding
  void addAll(List<DocxTreeNode> components) {}

  /// Update element
  ///
  /// The way them are updated depends on the class
  /// implementation
  ///
  /// [strict] tells to the method that we cannot updated an element
  /// that has a different [id] value, and a different type from the
  /// expected one
  @visibleForOverriding
  void updateElement(
    DocxTreeNode component, {
    int? index,
    bool strict = true,
  }) {}

  T child;

  int index = -1;
  int depth = -1;

  /// The xml relations id of this component
  ///
  /// Tipically is modified only when this content
  /// has a relation with .rels file
  String? rId;

  /// The internal random id of this component
  final String id;
  DocxTreeNode<dynamic>? parent;
  DocxTreeNode<T> get copy;
  List<XmlNode> buildXml({required DocumentContext context});
  List<XmlNode> buildXmlStyle({required DocumentContext context}) =>
      <XmlNode>[];

  /// Creates a lazy version of the same node, that waits for the Compilation
  /// time to build the [DocxTreeNode] type specified
  ///
  /// Useful for when you need the context and the stores to build graphics or images
  /// manually for your unique logic at that situation and you dont want to
  /// create an specific class for that case.
  static LazyNode<C> lazyBuild<C extends DocxTreeNode<dynamic>>(
    C Function(DocumentContext, String) callback, {
    DocxTreeNode<dynamic>? parent,
    String? id,
  }) {
    return LazyNode<C>(
      child: callback,
      parent: parent,
      id: id,
    );
  }

  List<DocxTreeNode<T>> repeat(
    int times, {
    DocxTreeNode<T>? Function(int index, DocxTreeNode<T> element)? overrideCopy,
  }) {
    return List<DocxTreeNode<T>>.generate(
      times,
      (int index) =>
          overrideCopy?.call(
            index,
            this,
          ) ??
          copy,
      growable: true,
    );
  }

  T? getAncestorOfExactType<T extends DocxTreeNode>() {
    DocxTreeNode? current = this;
    if (current.parent != null && current.parent is T) {
      return current.parent as T;
    }
    while (current != null) {
      if (current is T) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }

  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });
}

class Transform {
  Transform({
    required this.rotation,
    required this.flipHorizontal,
    required this.flipVertical,
  });

  final int rotation;
  final bool flipHorizontal;
  final bool flipVertical;
}
