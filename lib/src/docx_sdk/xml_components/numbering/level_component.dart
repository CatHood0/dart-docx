import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/style_to_from_node.dart';
import '../../utils/values.dart';

class NumberFormatComponent extends XmlComponentBase<LevelFormat> {
  NumberFormatComponent(
    LevelFormat format,
  ) : super(
          xmlKey: 'w:numFmt',
          value: format,
          attrs: Attributes(val: format.name),
        );

  @override
  XmlElement buildXml(BuildNodeContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: [
        ...attributes.buildXml(),
      ],
    );
  }
}

class LevelTextComponent extends XmlComponentBase<void> {
  LevelTextComponent(String text)
      : super(
          xmlKey: 'w:lvlText',
          value: null,
          attrs: Attributes(
            val: text,
          ),
        );

  @override
  XmlElement buildXml(BuildNodeContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: <XmlAttribute>[
        ...attributes.buildXml(),
      ],
    );
  }
}

class LevelAlignmentComponent extends XmlComponentBase<void> {
  LevelAlignmentComponent(Alignment alignment)
      : super(
          value: null,
          xmlKey: 'w:lvlJc',
          attrs: Attributes(
            val: alignment.name,
          ),
        );

  @override
  XmlElement buildXml(BuildNodeContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: <XmlAttribute>[
        ...attributes.buildXml(),
      ],
    );
  }
}

class LevelComponent extends XmlComponentBase<List<XmlComponentBase<dynamic>>> {
  LevelComponent(LevelOptions options)
      : assert(options.level < 9, 'Level cannot be grater than 9'),
        super(
          xmlKey: 'w:lvl',
          value: <XmlComponentBase<dynamic>>[
            XmlEmptyElementComponent(xmlKey: 'w:start', value: options.start),
            NumberFormatComponent(options.format),
            if (options.text.isNotEmpty) LevelTextComponent(options.text),
            LevelAlignmentComponent(options.alignment),
            if (options.suffix != null)
              XmlEmptyElementComponent(
                  xmlKey: 'w:suff', value: options.suffix!),
            if (options.isLegalNumberingStyle)
              XmlEmptyElementComponent<void>(xmlKey: 'w:isLgl', value: null),
            if (options.paragraphStyle != null)
              RawElement(
                value: options.paragraphStyle!.toParagraphPropertyElement()!,
              ),
            if (options.runStyle != null)
              RawElement(
                value: options.runStyle!.toRunPropertyElement()!,
              ),
          ],
          attrs: XmlComponentAttributes(xmlAttributes: {
            'w:ilvl': ensureInteger(options.level),
            // only will show the component if there is no compatibility
            // issues
            // 'w15:tentative': '1',
          }),
        );

  @override
  XmlElement buildXml(BuildNodeContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: [
        ...attributes.buildXml(),
      ],
      children: [
        ...value.map<XmlElement>(
          (XmlComponentBase<dynamic> n) => n.buildXml(
            context,
          ),
        ),
      ],
    );
  }
}
