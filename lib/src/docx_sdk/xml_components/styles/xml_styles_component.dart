import 'package:xml/xml.dart';

import '../../sdk.dart';
import '../../styles/latent_analyzer.dart';
import '../../styles/latent_styles.dart';
import '../../utils/logger/logger_configs.dart';
import 'xml_default_doc_styles_component.dart';

class XmlStylesComponent extends XmlComponentBase<void> {
  XmlStylesComponent()
      : super(
          xmlKey: 'w:styles',
          value: null,
          attrs: XmlDocAttributes(
            mc: true,
            w: true,
            w14: true,
            w15: true,
          ),
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    CompilerLogger.root.i('Analyzing styles to build LatentStyles');
    final (List<Style> styles, LatentStyles latent) = LatentAnalyzer.analyze(
      context.docStyleSheet.styles,
      context.docStyleSheet.latentStyles,
    );
    CompilerLogger.root.i('Building styles.xml component. '
        'Styles count: ${styles.length}. '
        'LatentStyles count: ${latent.count}, '
        'exceptions: ${latent.exceptions.length}');
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      isSelfClosing: false,
      children: <XmlNode>[
        XmlDefaultDocStylesComponent(
          value: context.docStyleSheet,
        ).buildXml(context),
        latent.buildXml(context),
        ...styles
            .where(_avoidInvalidStyles)
            .map<XmlElement>((Style e) => e.toXmlNode()!),
      ],
    );
  }

  bool _avoidInvalidStyles(Style style) => !style.isInvalid;
}
