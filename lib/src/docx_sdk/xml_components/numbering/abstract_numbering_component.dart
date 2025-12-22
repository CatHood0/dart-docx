import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../utils/values.dart';
import 'level_component.dart';
import 'multi_level_component.dart';

class XmlAbstractNumComponent extends XmlComponentBase<List<XmlComponentBase>> {
  XmlAbstractNumComponent({
    required this.id,
    List<LevelOptions> levels = const [],
  }) : super(
          xmlKey: 'w:abstractNum',
          value: <XmlComponentBase<dynamic>>[
            // generates an unique id for word
            XmlEmptyElementComponent(
              xmlKey: 'w:nsid',
              value: nanoid(
                8,
              ),
            ),
            MultiLevelType('hibridMultiLevel'),
            ...levels.map(
              LevelComponent.new,
            ),
          ],
          attrs: AbstractNumAttributes(
            id: ensureInteger(id),
            restartNumberingAfterBreak: 0,
          ),
        );

  final num id;

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: [
        ...attributes.buildXml(),
      ],
      children: [
        ...value.map((XmlComponentBase<dynamic> e) => e.buildXml(
              context,
            )),
      ],
    );
  }
}

class AbstractNumAttributes extends XmlComponentAttributes {
  AbstractNumAttributes({
    required num id,
    required int restartNumberingAfterBreak,
  }) : super(
          xmlAttributes: {
            'w:abstractNumId': id,
            'restartNumberingAfterBreak': restartNumberingAfterBreak,
          },
        );
}
