import 'package:xml/xml.dart';

import '../../sdk.dart';
import '../../utils/logger/logger_configs.dart';
import 'xml_default_doc_styles_component.dart';

class XmlStylesComponent extends XmlComponentBase<void> {
  XmlStylesComponent({required this.docStyles})
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

  final DocumentStyles docStyles;

  @override
  String get name => 'Styles';

  @override
  String get path => DocxPaths.stylesXmlFilePath;

  @override
  XmlElement buildXml() {
    CompilerLogger.root.info('Analyzing styles to build LatentStyles');
    final (List<Style> styles, LatentStyles latent) = LatentAnalyzer.analyze(
      docStyles.styles,
      docStyles.latentStyles,
    );
    CompilerLogger.root.info(
      'Building styles.xml component. '
      'Styles count: ${styles.length}. '
      'LatentStyles count: ${latent.count}, '
      'exceptions: ${latent.exceptions.length}',
    );
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      isSelfClosing: false,
      children: <XmlNode>[
        XmlDefaultDocStylesComponent(
          value: docStyles,
        ).buildXml(),
        latent.buildXml(),
        ...styles
            .where(_avoidInvalidStyles)
            .map<XmlElement>((Style e) => e.buldXml()!),
      ],
    );
  }

  bool _avoidInvalidStyles(Style style) => !style.isInvalid;
}
