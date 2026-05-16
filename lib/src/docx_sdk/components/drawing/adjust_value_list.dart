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
class AdjustValueList extends DocxNode<Iterable<AdjustValue>> {
  AdjustValueList({
    Iterable<AdjustValue> values = const <AdjustValue>[],
  })  : assert(values.length < 9, 'values cannot be major than 8 elements'),
        super(child: values);

  @override
  AdjustValueList get copy => AdjustValueList(values: child);

  @override
  AdjustValueList copyWith({
    Iterable<AdjustValue>? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return AdjustValueList(
      values: child ?? this.child,
    )..parent = parent ?? this.parent;
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:avLst',
        isSelfClosing: child.isEmpty,
        children: <XmlNode>[
          // to allow shape compatibility
          // we build geometric formulas
          //
          // them are not useful for images, but for
          // shapes works
          ...child.skippableMapIndexed((int index, AdjustValue el) {
            if (el.value == null) return null;

            return XmlElement.tag(
              'a:gd',
              attributes: <XmlAttribute>[
                XmlAttribute('name'.toName(), 'adj${index + 1}'),
                XmlAttribute('fmla'.toName(), 'val ${el.value}'),
              ],
            );
          })
        ],
      ),
    ];
  }

  @override
  List<AdjustValueList>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <AdjustValueList>[this] : null;
  }

  @override
  AdjustValueList? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }
}
