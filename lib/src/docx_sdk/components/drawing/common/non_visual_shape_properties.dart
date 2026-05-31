import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../../../../core/extensions/string_ext.dart';

/// Non-visual properties of a shape (wps:nvSpPr).
///
/// Contains identification metadata and shape-specific non-visual settings
/// like locking constraints.
class NonVisualShapeProperties extends DocxNode<void> {
  NonVisualShapeProperties({
    required this.name,
    required this.description,
    this.shapeLocks = true,
    super.id,
    super.parent,
  }) : super(child: null);

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
        shapeLocks: shapeLocks,
        parent: parent,
      );

  @override
  NonVisualShapeProperties copyWith({
    String? id,
    DocxNode<void>? parent,
    String? name,
    String? description,
    bool? shapeLocks,
  }) {
    return NonVisualShapeProperties(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shapeLocks: shapeLocks ?? this.shapeLocks,
      parent: parent ?? this.parent,
    );
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      XmlElement.tag(
        'wps:cNvPr',
        attributes: [
          XmlAttribute('id'.toName(), id),
          XmlAttribute('name'.toName(), name),
          XmlAttribute('descr'.toName(), description),
        ],
        isSelfClosing: true,
      ),
      XmlElement.tag(
        'wps:cNvSpPr',
        children: [
          XmlElement.tag(
            'a:spLocks',
            attributes: [
              XmlAttribute('noChangeShapeType'.toName(), shapeLocks ? '1' : '0'),
            ],
            isSelfClosing: true,
          ),
        ],
      ),
    ];
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <NonVisualShapeProperties>[this] : null;
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
