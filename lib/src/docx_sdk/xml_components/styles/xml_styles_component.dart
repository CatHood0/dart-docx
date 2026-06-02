import 'package:xml/xml.dart';

import '../../sdk.dart';
import 'xml_default_doc_styles_component.dart';

class XmlStylesComponent extends XmlComponentBase<void> {
  XmlStylesComponent({
    required this.docStyles,
    this.tree,
  }) : super(
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
  final DocxNode? tree;

  @override
  String get name => 'Styles';

  @override
  String get path => DocxPaths.stylesXmlFilePath;

  @override
  XmlElement buildXml() {
    CompilerLogger.root.info('Analyzing styles to build LatentStyles');
    final List<Style> styles = [];
    tree?.visitAllElement(
      (e) {
        if (e is Paragraph) {
          styles.addAll(e.styles.where((Style e) => !e.isReference));
        }

        if (e is Table) {
          styles.addAll(
              e.tableProperties!.styles.where((Style e) => !e.isReference));
        }
        if (e.child is ImageData) {
          styles.addAll(
              (e.child as ImageData).styles.where((e) => !e.isReference));
        }

        if (e is TextRun) {
          styles.addAll(e.child.styles.where((Style e) => !e.isReference));
        }

        if (e is HyperlinkRun) {
          styles.addAll(e.child.styles.where((Style e) => !e.isReference));
        }

        if (e is Text) {
          styles.addAll(e.styles.where((Style e) => !e.isReference));
        }

        return false;
      },
    );

    final (LatentStyles latent) = LatentAnalyzer.analyze(
      styles,
      docStyles.latentStyles,
    );
    CompilerLogger.root.info(
      'Building styles.xml component. '
      'Built-in styles count: ${styles.length}. '
      'latentStyles processed count: ${latent.count}, '
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
        ...docStyles.styles.values
            .where(_avoidInvalidStyles)
            .map<XmlElement>((Style e) => e.buldXml()!),
      ],
    );
  }

  bool _avoidInvalidStyles(Style style) => !style.isInvalid;
}
