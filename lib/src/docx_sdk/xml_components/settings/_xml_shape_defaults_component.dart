import 'package:xml/xml.dart';
import '../../../../../docx.dart';

/// Represents the `<w:shapeDefaults>` element in WordML settings.
class XmlShapeDefaultsComponent
    extends XmlComponentBase<List<XmlComponentBase>> {
  XmlShapeDefaultsComponent()
      : super(
          xmlKey: 'w:shapeDefaults',
          value: [
            _XmlOShapeDefaultsComponent(),
            _XmlOShapeLayoutComponent(),
          ],
        );

  @override
  XmlElement buildXml(BuildNodeContext context) {
    return XmlElement.tag(
      xmlKey,
      children: value.map((e) => e.buildXml(context)).toList(),
    );
  }
}

/// Represents the `<o:shapedefaults>` element.
class _XmlOShapeDefaultsComponent extends XmlComponentBase {
  _XmlOShapeDefaultsComponent()
      : super(
          xmlKey: 'o:shapedefaults',
          value: null,
          attrs: const XmlComponentAttributes(
            xmlAttributes: {
              'v:ext': 'edit',
              'spidmax': '1026',
              'strokecolor': '000000',
            },
          ),
        );

  @override
  XmlElement buildXml(BuildNodeContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      isSelfClosing: true,
    );
  }
}

/// Represents the `<o:idmap>` element.
class _XmlOIdMapComponent extends XmlComponentBase {
  _XmlOIdMapComponent()
      : super(
          xmlKey: 'o:idmap',
          value: null,
          attrs: const XmlComponentAttributes(
            xmlAttributes: {
              'v:ext': 'edit',
              'data': '1',
            },
          ),
        );

  @override
  XmlElement buildXml(BuildNodeContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      isSelfClosing: true,
    );
  }
}

/// Represents the `<o:shapelayout>` element.
class _XmlOShapeLayoutComponent
    extends XmlComponentBase<List<XmlComponentBase>> {
  _XmlOShapeLayoutComponent()
      : super(
          xmlKey: 'o:shapelayout',
          value: [
            _XmlOIdMapComponent(),
          ],
          attrs: const XmlComponentAttributes(
            xmlAttributes: {
              'v:ext': 'edit',
            },
          ),
        );

  @override
  XmlElement buildXml(BuildNodeContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: value.map((e) => e.buildXml(context)).toList(),
    );
  }
}
