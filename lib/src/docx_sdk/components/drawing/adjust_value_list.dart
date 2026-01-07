import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../../../core/extensions/skippable_iterations_ext.dart';
import '../../../core/extensions/string_ext.dart';

class AdjustValue {
  AdjustValue({
    required this.name,
    required this.value,
  });

  final String name;
  final Object? value;
}

// Represents a:avLst
class AdjustValueList extends DocxTreeNode<Iterable<AdjustValue>> {
  AdjustValueList({
    Iterable<AdjustValue> values = const <AdjustValue>[],
  }) : super(
          data: values
        );

  @override
  AdjustValueList get copy => AdjustValueList();

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:avLst',
        isSelfClosing: data.isEmpty,
        children: <XmlNode>[
          // to allow shape compatibility
          // we build geometric formulas
          //
          // them are not useful for images, but for
          // shapes works
          ...data.skippableMap((el) {
            if (el.value == null) return null;
            return XmlElement.tag(
              'a:gd',
              attributes: [
                XmlAttribute('name'.toName(), el.name),
                XmlAttribute('fmla'.toName(), el.value.toString()),
              ],
            );
          })
        ],
      ),
    ];
  }

  @override
  List<AdjustValueList>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  AdjustValueList? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }
}
