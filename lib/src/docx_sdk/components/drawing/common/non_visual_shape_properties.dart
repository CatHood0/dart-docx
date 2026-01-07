import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/extensions/string_ext.dart';

/// Non-visual properties of a shape (wps:nvSpPr).
///
/// Contains identification metadata and shape-specific non-visual settings
/// like locking constraints.
class NonVisualShapeProperties extends DocxTreeNode<void> {
  NonVisualShapeProperties({
    required this.name,
    required this.description,
    this.shapeLocks = true,
    super.id,
  }) : super(data: null);

  /// Display name (appears in selection pane and alt text).
  final String name;

  /// Description for accessibility and tooltips.
  final String description;

  /// Shape locks prevent certain modifications in Word UI
  final bool shapeLocks;

  @override
  NonVisualShapeProperties get copy => NonVisualShapeProperties(
        id: id,
        name: name,
        description: description,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'wps:nvSpPr',
        children: <XmlNode>[
          // Common non-visual properties (id, name, description)
          XmlElement.tag(
            'wps:cNvPr',
            attributes: <XmlAttribute>[
              XmlAttribute('id'.toName(), id),
              XmlAttribute('name'.toName(), name),
              XmlAttribute('descr'.toName(), description),
            ],
            isSelfClosing: true,
          ),
          // Shape-specific non-visual properties
          XmlElement.tag(
            'wps:cNvSpPr',
            children: <XmlNode>[
              XmlElement.tag(
                'a:spLocks',
                attributes: <XmlAttribute>[
                  XmlAttribute(
                    'noChangeShapeType'.toName(),
                    shapeLocks.toInt().toString(),
                  ),
                ],
                isSelfClosing: true,
              ),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <NonVisualShapeProperties>[this] : null;
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
