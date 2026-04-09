import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../utils/logger/logger_configs.dart';
import '../../xml_components/numbering/abstract_numbering_component.dart';
import '../../xml_components/numbering/concrete_numbering_component.dart';
import '../base/lazy_node.dart';

class DocumentRoot extends DocxTreeNode<List<DocxTreeNode<dynamic>>> {
  DocumentRoot({
    required Iterable<DocxTreeNode<dynamic>> sections,
    super.parent,
    super.id,
  })  : assert(
            parent == null,
            'root must not be in any other '
            'point than the main build of the tree'),
        super(child: <DocxTreeNode<dynamic>>[...sections]) {
    this.index = -1;
    depth = -1;
    int index = 0;
    for (final DocxTreeNode<dynamic> content in child) {
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      // the last column need to ignore the break
      if (content is Column && index + 1 >= sections.length) {
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
    DocxTreeNode<dynamic> component, {
    int? index,
    bool strict = true,
  }) {
    if (component is! RunBase) return;

    final int i = index ??
        child.indexWhere((DocxTreeNode<dynamic> el) => component.id == el.id);
    if (i <= -1) {
      CompilerLogger.root.w(
        'Tried to updated an '
        'element using: $component, '
        'but there is no match for it',
      );
      return;
    }

    final DocxTreeNode<dynamic> element = child[i];
    if (strict && component.child.runtimeType != element.child.runtimeType ||
        component.id != element.id) {
      return;
    }

    length -= element.length;

    CompilerLogger.root.d(
      'Replaced | $element | '
      'state using | $component | '
      'state at: $i in $runtimeType class type',
    );

    length += component.length;

    child[i] = component.copy.cast<DocxTreeNode<dynamic>>();
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

  @override
  void addListItem(
    String text, {
    required Numbering numbering,
    List<Style>? styles,
    List<Style>? runStyles,
    int? path,
  }) {
    final DocxTreeNode<dynamic> lazyElement =
        DocxTreeNode.lazyBuild<Paragraph>((
      DocumentContext context,
      String id,
    ) {
      return Paragraph.text(
        text: text,
        styles: styles ?? <Style>[],
        runStyles: runStyles ?? <Object>[],
        numbering: numbering,
      );
    });
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
          DrawingML(
            child: Anchor(
              width: width,
              height: height,
              name: name,
              config: config,
              child: Graphic.pic(
                child: WordprocessingShape(
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
                    transform2D: transform ??
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

  Iterable<DocxTreeNode<dynamic>> where(
    bool Function(DocxTreeNode<dynamic>) predicate,
  ) {
    return child.where(predicate);
  }

  DocxTreeNode<dynamic>? whereSingle(
    bool Function(DocxTreeNode<dynamic>) predicate,
  ) {
    return child.where(predicate).firstOrNull;
  }

  bool get isEmpty => child.isEmpty;

  @override
  List<XmlNode> buildXml({required DocumentContext context}) {
    final List<XmlNode> content = <XmlNode>[];
    for (final DocxTreeNode<dynamic> section in child) {
      if (section is IgnorableMixin &&
          (section as IgnorableMixin).shouldIgnore()) {
        continue;
      }
      context.currentContentPart = this;
      content.addAll(section.buildXml(context: context));
    }

    return content;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  DocumentRoot get copy => DocumentRoot(
        id: id,
        sections: child,
        parent: parent,
      );

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxTreeNode<dynamic>>[this];
    final List<DocxTreeNode> elements = <DocxTreeNode<dynamic>>[];
    for (final DocxTreeNode element in child) {
      if (element.isEmptyNode()) continue;
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<DocxTreeNode<dynamic>>? els = element.visitAllElement(
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
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    for (final DocxTreeNode element in child) {
      if (element.isEmptyNode()) continue;
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final DocxTreeNode<dynamic>? els = element.visitElement(
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
