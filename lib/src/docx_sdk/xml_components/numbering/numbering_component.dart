// I want to thanks to the author of https://github.com/dolanmiu/docx
// since  implementation inspired me to make the API
// of dart-docx with the same target: be easy for developers
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../utils/logger/logger_configs.dart';
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
/// in a DOCX document. It manages both abstract numbering definitions
/// (templates) and concrete numbering instances (actual list instances).
///
/// The component maintains maps for abstract and concrete numbering
/// configurations and handles the generation of unique IDs for both.
///
/// Inspired by the https://github.com/dolanmiu/docx implementation.
class XmlNumberingComponent extends XmlComponentBase<List<NumberingOptions>> {
  XmlNumberingComponent({
    required List<NumberingOptions> options,
    DocumentContext? context,
  }) : super(
          value: <NumberingOptions>[],
          xmlKey: 'w:numbering',
          //TODO: use XmlDocAttribute instead
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
        ) {
    if (context != null) applyContext(context);
    for (final NumberingOptions con in options) {
      abstractNumberingMap[con.refKey] = XmlAbstractNumComponent(
        id: abstractNumUniqueNumericId(),
        levels: con.levels,
      );
      referenceConfigMap[con.refKey] = con.levels;
    }
    // we need to check if the id is not duplicated
    final Set<num> temp = <num>{};
    for (final XmlAbstractNumComponent comp in abstractNumberingMap.values) {
      if (temp.contains(comp.id)) {
        throw 'Duplicate abstract id("${comp.id}") in $temp'
            'found during XmlNumberingComponent build';
      }
      temp.add(comp.id);
    }
  }

  /// Map of abstract numbering templates by reference key.
  ///
  /// Abstract numbering defines the template/structure of a list.
  final Map<String, XmlAbstractNumComponent> abstractNumberingMap =
      <String, XmlAbstractNumComponent>{};

  /// Map of concrete numbering instances by reference key.
  ///
  /// Concrete numbering represents actual list instances in the document.
  final Map<String, XmlConcreteNumberingComponent> concreteNumberingMap =
      <String, XmlConcreteNumberingComponent>{};

  /// Map of reference configurations by reference key.
  final Map<String, List<LevelOptions>> referenceConfigMap =
      <String, List<LevelOptions>>{};

  /// Function to generate unique IDs for abstract numbering.
  final int Function() abstractNumUniqueNumericId =
      abstractNumUniqueNumericIdGen;

  /// Function to generate unique IDs for concrete numbering.
  final int Function() concreteNumUniqueNumericId =
      concreteNumUniqueNumericIdGen;

  /// Applies document context to the numbering component.
  ///
  /// Registers the numbering component with the document context, making
  /// its abstract and concrete numbering configurations available to
  /// other document components (like paragraphs).
  ///
  /// Parameters:
  /// - [context]: The document context to register with.
  void applyContext(DocumentContext context) {
    // when the context is applied, this means that we
    // are ready to insert list styles, so, we need to ensure
    // that the ids really are uniques
    reloadIds();
    context
      ..getAbstractNumberingTemplates = (() => abstractNumberingMap.values)
      ..registerInstance = registerConcreteInstance
      ..getConcreteNumberingInstances = (() => concreteNumberingMap.values)
      ..getAbstractNumId = ((String ref) => abstractNumberingMap[ref]?.id)
      ..getConcreteNumId = ((String ref) => concreteNumberingMap[ref]?.numId)
      ..getAbstractNumbering = ((String ref) => abstractNumberingMap[ref])
      ..getConcreteNumbering = ((String ref) => concreteNumberingMap[ref]);
  }

  /// Registers a concrete numbering instance for a given reference.
  ///
  /// Creates a concrete numbering instance based on an abstract numbering
  /// template. This is called when a paragraph uses a particular numbering
  /// reference key.
  ///
  /// Parameters:
  /// - [ref]: The reference key of the abstract numbering template.
  /// - [numRefId]: The instance ID for this concrete numbering.
  void registerConcreteInstance(String ref, int numRefId, {int? level}) {
    final XmlAbstractNumComponent? abstractN = abstractNumberingMap[ref];
    if (abstractN == null) return;

    final String effectiveReference = '$ref-$numRefId';
    if (concreteNumberingMap[effectiveReference] != null) return;

    final List<LevelOptions>? referenceConfig = referenceConfigMap[ref];
    final int? firstLevelStartNumber = referenceConfig?.firstOrNull?.start;

    CompilerLogger.root.d('Registering: $ref-$numRefId of level $level');
    CompilerLogger.root.d('Overrides: first level number => $firstLevelStartNumber');

    final ConcreteNumberingOptions concreteOptions = ConcreteNumberingOptions(
      // to avoid some issues, we generates automatically an numId
      // for new concrete instances
      //
      // usually should be the same than numRefId, but we use it
      // together with  the abstract num key reference,
      // for create an unique string reference and we can get it
      // through the context during build phase
      numId: concreteNumUniqueNumericIdGen(),
      abstractRefId: abstractN.id.toInt(),
      refKey: ref,
      copyId: numRefId,
      overrides: <ConcreteLevelOverride>[
        if (firstLevelStartNumber != null)
          ConcreteLevelOverride(
            indentLevel: 0,
            startAt: firstLevelStartNumber,
          ),
      ],
    );

    // then with just the key and the instance value
    // we can get it
    concreteNumberingMap[effectiveReference] =
        XmlConcreteNumberingComponent(concreteOptions);
  }

  /// Builds the XML element for the numbering component.
  @override
  XmlElement buildXml(DocumentContext context) {
    // if there is no concrete instances, then we
    // add some to avoid conflicts
    if (concreteNumberingMap.isEmpty) {
      CompilerLogger.root.d('Detected empty concrete instances.');
      abstractNumberingMap.forEach((String k, XmlAbstractNumComponent v) {
        CompilerLogger.root.d('Registering concrete instance for "$k".');
        registerConcreteInstance(k, 1);
      });
    }
    return XmlElement.tag(
      xmlKey,
      attributes: <XmlAttribute>[...attributes.buildXml()],
      children: <XmlNode>[
        ...abstractNumberingMap.values.map(
          (XmlAbstractNumComponent el) => el.buildXml(
            context,
          ),
        ),
        ...concreteNumberingMap.values.map(
          (XmlConcreteNumberingComponent el) => el.buildXml(
            context,
          ),
        ),
      ],
    );
  }
}
