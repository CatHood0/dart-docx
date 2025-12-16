import 'package:xml/xml.dart';

import '../../../../docx.dart';
import 'abstract_numbering_component.dart';
import 'concrete_numbering_component.dart';
import 'level_options.dart';

class NumberingOptions {
  NumberingOptions({
    required this.levels,
    required this.refKey,
  });

  final List<LevelOptions> levels;
  final String refKey;
}

class XmlNumberingComponent extends XmlComponentBase<List<NumberingOptions>> {
  XmlNumberingComponent({
    required List<NumberingOptions> options,
    DocumentContext? context,
  }) : super(
          value: <NumberingOptions>[],
          xmlKey: 'w:numbering',
          attrs: XmlComponentAttributes(xmlAttributes: {
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
  }

  // to allow to context getting these styles from just ref ids
  // we use these variables
  final Map<String, XmlAbstractNumComponent> abstractNumberingMap =
      <String, XmlAbstractNumComponent>{};
  final Map<String, XmlConcreteNumberingComponent> concreteNumberingMap =
      <String, XmlConcreteNumberingComponent>{};
  final Map<String, List<LevelOptions>> referenceConfigMap = {};
  final int Function() abstractNumUniqueNumericId =
      abstractNumUniqueNumericIdGen;
  final int Function() concreteNumUniqueNumericId =
      concreteNumUniqueNumericIdGen;

  void applyContext(DocumentContext context) {
    // when the context is applied, this means that we
    // are ready to insert list styles, so, we need to ensure
    // that the ids really are uniques
    reloadIds();
    context
      ..getAbstractNumberingTemplates = (() => abstractNumberingMap.values)
      ..getConcreteNumber = (() => concreteNumberingMap.values)
      ..abstractNum = ((String ref) => abstractNumberingMap[ref])
      ..concreteNum = ((String ref) => concreteNumberingMap[ref]);
  }

  void registerConcreteInstance(String ref, int numRefId) {
    final XmlAbstractNumComponent? abstractN = abstractNumberingMap[ref];
    if (abstractN == null) return;

    final String effectiveReference = '$ref-$numRefId';
    if (concreteNumberingMap[effectiveReference] != null) return;

    final List<LevelOptions>? referenceConfig =
        referenceConfigMap[effectiveReference];
    final int? firstLevelStartNumber = referenceConfig?.firstOrNull?.start;

    final ConcreteNumberingOptions concreteOptions = ConcreteNumberingOptions(
      numId: concreteNumUniqueNumericIdGen(),
      abstractRefId: abstractN.id.toInt(),
      refKey: ref,
      copyId: numRefId,
      overrides: <ConcreteLevelOverride>[
        ConcreteLevelOverride(
          indentLevel: 0,
          startAt: firstLevelStartNumber ?? 1,
        ),
      ],
    );

    concreteNumberingMap[effectiveReference] = XmlConcreteNumberingComponent(
      concreteOptions,
    );
  }

  @override
  XmlElement buildXml(DocumentContext context) {
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
