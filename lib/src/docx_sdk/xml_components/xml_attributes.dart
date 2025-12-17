import 'package:xml/xml.dart';
import '../../../docx.dart';
import '../../core/extensions/string_ext.dart';

class XmlComponentAttributes {
  const XmlComponentAttributes({required this.xmlAttributes});

  final Map<String, Object> xmlAttributes;

  List<XmlAttribute> buildXml() {
    return xmlAttributes.entries
        .map<XmlAttribute>(
          (MapEntry<String, Object> e) => XmlAttribute(
            e.key.toName(),
            e.value.toString(),
          ),
        )
        .toList();
  }
}

class Attributes extends XmlComponentAttributes {
  Attributes({
    Object? val,
    String? color,
    String? fill,
    String? space,
    String? sz,
    String? type,
    String? rsidR,
    String? rsidRPr,
    String? rsidSect,
    String? w,
    String? h,
    String? top,
    String? right,
    String? bottom,
    String? left,
    String? header,
    String? footer,
    String? gutter,
    String? linePitch,
    Object? pos,
  }) : super(xmlAttributes: {
          if (val != null) 'w:val': val,
          if (color != null) 'w:color': color,
          if (fill != null) 'w:fill': fill,
          if (space != null) 'w:space': space,
          if (sz != null) 'w:sz': sz,
          if (type != null) 'w:type': type,
          if (rsidR != null) 'w:rsidR': rsidR,
          if (rsidRPr != null) 'w:rsidRPr': rsidRPr,
          if (rsidSect != null) 'w:rsidSect': rsidSect,
          if (w != null) 'w:w': w,
          if (h != null) 'w:h': h,
          if (top != null) 'w:top': top,
          if (right != null) 'w:right': right,
          if (bottom != null) 'w:bottom': bottom,
          if (left != null) 'w:left': left,
          if (header != null) 'w:header': header,
          if (footer != null) 'w:footer': footer,
          if (gutter != null) 'w:gutter': gutter,
          if (linePitch != null) 'w:linePitch': linePitch,
          if (pos != null) 'w:pos': pos,
        });
}

class XmlDocAttributes extends XmlComponentAttributes {
  XmlDocAttributes({
    bool? wpc = false,
    bool? mc = false,
    bool? o = false,
    bool? r = false,
    bool? m = false,
    bool? v = false,
    bool? wp14 = false,
    bool? wp = false,
    bool? w10 = false,
    bool? w = false,
    bool? w14 = false,
    bool? w15 = false,
    bool? wpg = false,
    bool? wpi = false,
    bool? wne = false,
    bool? wps = false,
    bool? cp = false,
    bool? dc = false,
    bool? dcterms = false,
    bool? dcmitype = false,
    bool? xsi = false,
    bool? cx = false,
    bool? cx1 = false,
    bool? cx2 = false,
    bool? cx3 = false,
    bool? cx4 = false,
    bool? cx5 = false,
    bool? cx6 = false,
    bool? cx7 = false,
    bool? cx8 = false,
    bool? aink = false,
    bool? am3d = false,
    bool? w16cex = false,
    bool? w16cid = false,
    bool? w16 = false,
    bool? w16sdtdh = false,
    bool? w16se = false,
    String ignorables = '',
  }) : super(xmlAttributes: {
          if (wpc == true) 'xmlns:wpc': namespaces['wpc']!,
          if (mc == true) 'xmlns:mc': namespaces['mc']!,
          if (o == true) 'xmlns:o': namespaces['o']!,
          if (r == true) 'xmlns:r': namespaces['r']!,
          if (m == true) 'xmlns:m': namespaces['m']!,
          if (v == true) 'xmlns:v': namespaces['v']!,
          if (wp14 == true) 'xmlns:wp14': namespaces['wp14']!,
          if (wp == true) 'xmlns:wp': namespaces['wp']!,
          if (w10 == true) 'xmlns:w10': namespaces['w10']!,
          if (w == true) 'xmlns:w': namespaces['w']!,
          if (w14 == true) 'xmlns:w14': namespaces['w14']!,
          if (w15 == true) 'xmlns:w15': namespaces['w15']!,
          if (wpg == true) 'xmlns:wpg': namespaces['wpg']!,
          if (wpi == true) 'xmlns:wpi': namespaces['wpi']!,
          if (wne == true) 'xmlns:wne': namespaces['wne']!,
          if (wps == true) 'xmlns:wps': namespaces['wps']!,
          if (cp == true) 'xmlns:cp': namespaces['cp']!,
          if (dc == true) 'xmlns:dc': namespaces['dc']!,
          if (dcterms == true) 'xmlns:dcterms': namespaces['dcterms']!,
          if (dcmitype == true) 'xmlns:dcmitype': namespaces['dcmitype']!,
          if (xsi == true) 'xmlns:xsi': namespaces['xsi']!,
          if (cx == true) 'xmlns:cx': namespaces['cx']!,
          if (cx1 == true) 'xmlns:cx1': namespaces['cx1']!,
          if (cx2 == true) 'xmlns:cx2': namespaces['cx2']!,
          if (cx3 == true) 'xmlns:cx3': namespaces['cx3']!,
          if (cx4 == true) 'xmlns:cx4': namespaces['cx4']!,
          if (cx5 == true) 'xmlns:cx5': namespaces['cx5']!,
          if (cx6 == true) 'xmlns:cx6': namespaces['cx6']!,
          if (cx7 == true) 'xmlns:cx7': namespaces['cx7']!,
          if (cx8 == true) 'xmlns:cx8': namespaces['cx8']!,
          if (aink == true) 'xmlns:aink': namespaces['aink']!,
          if (am3d == true) 'xmlns:am3d': namespaces['am3d']!,
          if (w16cex == true) 'xmlns:w16cex': namespaces['w16cex']!,
          if (w16cid == true) 'xmlns:w16cid': namespaces['w16cid']!,
          if (w16 == true) 'xmlns:w16': namespaces['w16']!,
          if (w16sdtdh == true) 'xmlns:w16sdtdh': namespaces['w16sdtdh']!,
          if (w16se == true) 'xmlns:w16se': namespaces['w16se']!,
          if (ignorables.isNotEmpty) 'mc:Ignorables': ignorables,
        });
}
