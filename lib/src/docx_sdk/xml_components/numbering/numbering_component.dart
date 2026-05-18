// I want to thanks to the author of https://github.com/dolanmiu/docx
// since  implementation inspired me to make the API
// of dart-docx with the same target: be easy for developers
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../xml_components/numbering/abstract_numbering_component.dart';
import '../../xml_components/numbering/concrete_numbering_component.dart';

/// Configuration for document numbering (lists and outlines).
///
/// This class defines the properties for creating numbered or bulleted lists
/// in a DOCX document. It serves as a high-level configuration that is
/// transformed into the appropriate XML components during document generation.
///
/// Example usage:
/// ```dart
/// final numbering = NumberingOptions(
///   refKey: 'myList',
///   levels: [
///     LevelOptions(
///       level: 0,
///       format: NumberFormat.decimal,
///       text: '%1.',
///       alignment: Alignment.left,
///       start: 1,
///     ),
///   ],
/// );
/// ```
class NumberingOptions {
  NumberingOptions({
    required this.levels,
    required this.refKey,
  });

  /// List level definitions for multi-level numbering.
  final List<LevelOptions> levels;

  /// Reference key used to identify this numbering configuration.
  final String refKey;
}

/// XML component for document numbering (lists and outlines).
///
/// This class is responsible for generating the `w:numbering` XML element
/// in a DOCX document. It ONLY constructs XML from pre-built components.
///
/// The store (NumberingStore) is responsible for:
/// - Storing abstract and concrete numbering data
/// - Generating unique IDs
/// - Managing registration of instances
///
/// This component receives the data ready to be serialized to XML.
///
/// Inspired by the https://github.com/dolanmiu/docx implementation.
class XmlNumberingComponent extends XmlComponentBase<void> {
  XmlNumberingComponent({
    required List<XmlAbstractNumComponent> abstracts,
    required List<XmlConcreteNumberingComponent> concretes,
  })  : _abstracts = abstracts,
        _concretes = concretes,
        super(
          value: null,
          xmlKey: 'w:numbering',
          attrs: XmlComponentAttributes(xmlAttributes: <String, Object>{
            'xmlns:w': namespaces['w']!,
            'xmlns:ve': namespaces['ve']!,
            'xmlns:o': namespaces['o']!,
            'xmlns:r': namespaces['r']!,
            'xmlns:v': namespaces['v']!,
            'xmlns:wp': namespaces['wp']!,
            'xmlns:w10': namespaces['w10']!,
            'xmlns:wne': namespaces['wne']!,
          }),
        );

  /// List of abstract numbering components.
  final List<XmlAbstractNumComponent> _abstracts;

  /// List of concrete numbering components.
  final List<XmlConcreteNumberingComponent> _concretes;

  @override
  String get name => 'Numbering';

  @override
  String get path => DocxPaths.numberingXmlFilePath;

  /// Builds the XML element for the numbering component.
  @override
  XmlElement buildXml(BuildNodeContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: <XmlAttribute>[...attributes.buildXml()],
      children: <XmlNode>[
        ..._abstracts.map((XmlAbstractNumComponent el) => el.buildXml(context)),
        ..._concretes.map((XmlConcreteNumberingComponent el) => el.buildXml(context)),
      ],
    );
  }
}
