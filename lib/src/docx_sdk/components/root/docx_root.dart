import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';

//TODO: ensure that parents really are correctly referenced
class DocxRoot extends DocxNode<List<DocxNode<dynamic>>> {
  DocxRoot({
    required Iterable<DocxNode<dynamic>> sections,
    super.parent,
    super.id,
  })  : assert(
            parent == null,
            'root must not be in any other '
            'point than the main build of the tree'),
        super(child: <DocxNode<dynamic>>[...sections]) {
    this.index = 0;
    depth = 0;
    int index = 0;
    for (final DocxNode<dynamic> content in child) {
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      // the last column need to ignore the break
      if (content is PageColumn && index + 1 >= sections.length) {
        // ignore: invalid_use_of_protected_member
        content.ignoreBreak = true;
      }
      index++;
    }
  }

  @override
  set depth(int value) {}

  @override
  set index(int value) {}

  @override
  void removeById(String id, {List<int> path = const <int>[]}) {
    if (path.isNotEmpty) {}
  }

  @override
  void updateElement(
    DocxNode<dynamic> component, {
    int? index,
    bool strict = true,
  }) {
    if (component is! RunBase) return;

    final int i = index ??
        child.indexWhere((DocxNode<dynamic> el) => component.id == el.id);
    if (i <= -1) {
      CompilerLogger.root.warning(
        'Tried to updated an '
        'element using: $component, '
        'but there is no match for it',
      );
      return;
    }

    final DocxNode<dynamic> element = child[i];
    if (strict && component.child.runtimeType != element.child.runtimeType ||
        component.id != element.id) {
      return;
    }

    length -= element.length;

    CompilerLogger.root.debug(
      'Replaced | $element | '
      'state using | $component | '
      'state at: $i in $runtimeType class type',
    );

    length += component.length;

    child[i] = component.copy.cast<DocxNode<dynamic>>();

    if (child[i].mounted) {
      child[i].markAsDirty();
    }
  }

  @override
  void addImage(
    ImageData<Object> data, {
    required bool anchored,
    String? id,
  }) {
    child.add(Paragraph.empty()
      ..addImage(
        data,
        anchored: anchored,
        id: id,
      ));
  }

  @override
  void addParagraph(
    Paragraph pr, {
    int? path,
  }) {
    path == null ? child.add(pr) : child.insert(path, pr);
  }

  //TODO: remove this
  @override
  void addListItem(
    String text, {
    required Numbering numbering,
    List<Style>? styles,
    List<Style>? runStyles,
    int? path,
  }) {
    final Builder<Paragraph> lazyElement = Builder<Paragraph>(
      builder: (String id) {
        return Paragraph.text(
          text: text,
          styles: styles ?? <Style>[],
          runStyles: runStyles ?? <Object>[],
          numbering: numbering,
        );
      },
    );
    path == null ? child.add(lazyElement) : child.insert(path, lazyElement);
  }

  @override
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
  }) =>
      addParagraph(
        Paragraph.run(
          Drawing(
            child: Anchor(
              width: width,
              height: height,
              name: name,
              config: config,
              child: Graphic.pic(
                child: WPShape(
                  id: shapeId,
                  name: name,
                  description: description,
                  textBox: textBox,
                  shapeLocks: shapeLocks,
                  shapeProperties: ShapeProperties(
                    geometryComponent: shape,
                    fill: fill,
                    border: border,
                    effects: effect,
                    transform: transform ??
                        Transform2D(
                          offset: Offset.zero(),
                          extents: AnnotationExtents.zero(),
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Iterable<DocxNode<dynamic>> where(
    bool Function(DocxNode<dynamic>) predicate,
  ) {
    return child.where(predicate);
  }

  DocxNode<dynamic>? whereSingle(
    bool Function(DocxNode<dynamic>) predicate,
  ) {
    return child.where(predicate).firstOrNull;
  }

  bool get isEmpty => child.isEmpty;

  @override
  List<XmlNode> buildXml() {
    final List<XmlNode> content = <XmlNode>[];
    for (final DocxNode<dynamic> section in child) {
      if (section is IgnorableMixin &&
          (section as IgnorableMixin).shouldIgnore()) {
        continue;
      }
      content.addAll(section.buildXml());
    }

    // Detect if this component is a row into another one
    //
    // Internally, Row is automatically parsed to a Table
    // so, we cannot call it expecting something
    //
    // If you create a trace of the ancestor, you will get this:
    //
    //  LayoutConstraints
    //  |_ Table
    //   |_ TableRow
    //    | TableCell <- (we are here)
    //
    // As you see, we don't get a Row instance here
    if ((child.lastOrNull is Table || child.lastOrNull is Row)) {
      // why we call last element and check if it's a row?
      //
      // Well, by some reason, LibreOffice does not render it properly if there is no space
      // between the table and the end of the cell
      //
      // What is this problem? Literally, all the tables break the current flows, and are "moved"
      // internally to behave as independent external tables, that makes look it likes we moved
      // all outsided without nesting the tree
      content.addAll(Paragraph.empty().buildXml());
    }

    return content;
  }

  @override
  DocxRoot get copy => DocxRoot(
        id: id,
        sections: child,
        parent: parent,
      );

  @override
  DocxRoot copyWith({
    Iterable<DocxNode<dynamic>>? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return DocxRoot(
      sections: child ?? this.child,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxNode<dynamic>>[this];
    final List<DocxNode> elements = <DocxNode<dynamic>>[];
    for (final DocxNode element in child) {
      if (element.isEmptyNode()) continue;
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<DocxNode<dynamic>>? els = element.visitAllElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (els != null) {
          return els;
        }
      }
    }
    return elements;
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    for (final DocxNode element in child) {
      if (element.isEmptyNode()) continue;
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final DocxNode<dynamic>? els = element.visitElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (els != null) {
          return els;
        }
      }
    }
    return null;
  }
}
