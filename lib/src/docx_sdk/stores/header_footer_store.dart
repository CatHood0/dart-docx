import 'package:xml/xml.dart';

import '../components/base/docx_node.dart';
import '../docx_component_context.dart';
import 'inherited_component.dart';

//TODO: see deepseek
class HeaderFooterStore extends InheritedComponent {
  HeaderFooterStore({
    required super.child,
  });

  @override
  bool shouldNotify(covariant HeaderFooterStore old) {
    return false;
  }

  @override
  List<XmlNode> buildXml({required DocumentContext context}) {
    return child.buildXml(context: context);
  }

  @override
  InheritedComponent get copy => HeaderFooterStore(
        child: child,
      );

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
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
    return child.visitElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }
}
