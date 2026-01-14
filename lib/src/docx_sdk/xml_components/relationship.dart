import 'package:xml/xml.dart';

class RelationShip {
  RelationShip({
    required this.rId,
    required this.target,
    required this.type,
    this.mode,
  })  : assert(rId.trim().isNotEmpty, 'rId cannot be empty'),
        assert(target.trim().isNotEmpty, 'target cannot be empty'),
        assert(type.trim().isNotEmpty, 'type cannot be empty');

  RelationShip.invalid()
      : rId = '',
        target = '',
        mode = '',
        type = '';

  final String rId;
  final String target;
  final String type;
  final String? mode;

  @override
  String toString() {
    return 'RelationShip(rId: $rId, type: $type, target: $target)';
  }

  String toXmlString({String leftIndent = ''}) {
    return '$leftIndent<RelationShip '
        'Id="$rId" '
        'Type="$type" '
        'Target="$target" ${mode == null || mode!.isEmpty ? '' : 'TargetMode="$mode" '}'
        '/>';
  }

  XmlElement toXml() {
    return XmlElement.tag(
      'Relationship',
      attributes: <XmlAttribute>[
        XmlAttribute(XmlName.fromString('Id'), rId),
        XmlAttribute(
          XmlName.fromString('Type'),
          type,
        ),
        XmlAttribute(
          XmlName.fromString('Target'),
          target,
        ),
        if (mode != null)
          XmlAttribute(
            XmlName.fromString('TargetMode'),
            mode!,
          ),
      ],
      isSelfClosing: true,
    );
  }
}
