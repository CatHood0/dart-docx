import 'package:xml/src/xml/nodes/element.dart';

import '../../../../docx.dart';
import '../../utils/values.dart';

class ConcreteNumberingOptions {
  ConcreteNumberingOptions({
    required this.numId,
    required this.abstractRefId,
    required this.refKey,
    required this.copyId,
    this.overrides = const [],
  });

  ///
  final int numId;

  /// The unique id that let us identify reference
  /// the abstract templates
  final int abstractRefId;

  /// The unique id that let us identify this option
  final String refKey;

  /// Define the list id. All the list with this id
  /// will continue its own numeration rules
  ///
  /// Tipically, we use different ids when need reset
  /// the list numbers
  final int copyId;

  final List<ConcreteLevelOverride> overrides;
}

class ConcreteLevelOverride {
  ConcreteLevelOverride({required this.indentLevel, required this.startAt});

  final int indentLevel;
  final int startAt;
}

class XmlConcreteNumberingComponent
    extends XmlComponentBase<List<XmlComponentBase>> {
  XmlConcreteNumberingComponent(ConcreteNumberingOptions options)
      : numId = options.numId,
        reference = options.refKey,
        instance = options.copyId,
        super(
          xmlKey: 'w:num',
          value: <XmlComponentBase<dynamic>>[
            XmlElementComponent(
              xmlKey: 'w:abstractNumId',
              value: options.abstractRefId,
            ),
            ...options.overrides.map((ele) {
              return ConcreteLevelOverrideComponent(
                indentLevel: ele.indentLevel,
                startAt: ele.startAt,
              );
            }),
          ],
          attrs: XmlComponentAttributes(xmlAttributes: {
            'v:numId': ensureInteger(options.numId),
          }),
        );

  final int numId;
  final String reference;
  final int instance;

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: value.map(
        (
          XmlComponentBase<dynamic> e,
        ) =>
            e.buildXml(context),
      ),
    );
  }
}

class ConcreteLevelOverrideComponent
    extends XmlComponentBase<List<XmlComponentBase>> {
  ConcreteLevelOverrideComponent({
    required int indentLevel,
    int? startAt,
  }) : super(
          xmlKey: 'w:lvlOverride',
          attrs: XmlComponentAttributes(xmlAttributes: {
            'w:ilvl': indentLevel,
          }),
          value: <XmlComponentBase<dynamic>>[
            if (startAt != null)
              XmlElementComponent(
                xmlKey: 'w:startOverride',
                value: '$startAt',
              ),
          ],
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: value.map(
        (
          XmlComponentBase<dynamic> e,
        ) =>
            e.buildXml(context),
      ),
    );
  }
}
