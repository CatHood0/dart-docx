import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';

abstract class InheritedNode extends DocxNode<DocxNode> {
  InheritedNode({
    required super.child,
    super.parent,
    super.id,
  }) {
    child
      ..parent = this
      ..index = 0;
  }

  @override
  List<XmlNode> buildXml() {
    return child.buildXml();
  }

  @override
  List<XmlNode> buildXmlStyle() {
    return child.buildXmlStyle();
  }

  @override
  InheritedNode get copy;

  @override
  InheritedNode copyWith({
    DocxNode? child,
    String? id,
    DocxNode<dynamic>? parent,
  });

  @override
  void updateElement(
    DocxNode<dynamic> component, {
    int? index,
    bool strict = true,
  }) {
    if (index != null && index != this.index || parent == null) {
      CompilerLogger.root.debug(
        '[$runtimeType:$id] Ignoring '
        'updateElement call by bad index reference ($index) '
        'or no parent definition',
      );
      return;
    }
    if (strict && child.id != component.id) {
      CompilerLogger.root.debug(
        '[$runtimeType:$id] Ignoring '
        'updateElement call difference between '
        'current child id (${child.id}) '
        'and the provided component id (${component.id})',
      );
      return;
    }

    parent!.updateElement(
      copyWith(child: component),
      index: this.index,
    );
  }

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return toList();
    return child.visitAllElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    return child.visitElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }
}
