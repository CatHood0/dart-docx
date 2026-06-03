import 'package:xml/xml.dart';

import '../../../../docx.dart';

class MultiLevelType extends XmlComponentBase<void> {
  MultiLevelType(String value)
      : super(
          xmlKey: 'w:multiLevelType',
          value: null,
          attrs: Attributes(
            val: value,
          ),
        );

  @override
  XmlElement buildXml() {
    return XmlElement.tag(
      xmlKey,
      attributes: <XmlAttribute>[
        attributes.buildXml().single,
      ],
    );
  }
}
