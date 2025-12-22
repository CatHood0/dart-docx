import 'package:xml/xml.dart';
import '../../sdk.dart';
import 'xml_columns_settings_component.dart';

/// Represents the `<w:sectPr>` (Section Properties) element in WordML.
///
/// This component defines various properties for a document section, such as
/// page size, margins, headers/footers, and column layout.
class XmlDocumentSectionSettingsComponent
    extends XmlComponentBase<List<XmlComponentBase>> {
  XmlDocumentSectionSettingsComponent({
    required DocumentOptions options,
    String? themeId,
  }) : super(
          // Build the list of child components directly
          value: <XmlComponentBase>[
            // Page Size (w:pgSz) component
            XmlPageSizeComponent(
                size: options.pageSize, orientation: options.orientation),
            // Page Margins (w:pgMar) component
            XmlPageMarginsComponent(margins: options.margins),
            if (themeId != null)
              XmlEmptyElementComponent(
                xmlKey: 'w:theme',
                attrName: 'r:id',
                value: themeId,
              ),
            // Add column settings if present in DocumentOptions
            if (options.columns != null)
              XmlColumnsSettingsComponent(
                settings: options.columns!,
              ),
            //TODO: we need configurations for headers/footers references etc.
          ],
          xmlKey: 'w:sectPr',
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: value
          .map((
            XmlComponentBase component,
          ) =>
              component.buildXml(context))
          .toList(),
    );
  }
}

/// Represents the `<w:pgMar>` element in WordML, defining the page margins
/// for a section.
class XmlPageMarginsComponent extends XmlComponentBase<DocumentMargins> {
  XmlPageMarginsComponent({
    required DocumentMargins margins,
  }) : super(
          value: margins,
          xmlKey: 'w:pgMar',
          attrs: XmlComponentAttributes(
            xmlAttributes: {
              'w:top': margins.top.toString(),
              'w:bottom': margins.bottom.toString(),
              'w:left': margins.left.toString(),
              'w:right': margins.right.toString(),
              'w:header': margins.header.toString(),
              'w:footer': margins.footer.toString(),
              'w:gutter': margins.gutter.toString(),
            }, // Attributes are built in buildXml
          ),
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      isSelfClosing: true,
    );
  }
}

/// Represents the `<w:pgSz>` element in WordML, defining the page size
/// and orientation for a section.
class XmlPageSizeComponent
    extends XmlComponentBase<({PageSettings size, Orientation orientation})> {
  XmlPageSizeComponent({
    required PageSettings size,
    required Orientation orientation,
  }) : super(
          value: (size: size, orientation: orientation),
          xmlKey: 'w:pgSz',
          attrs: XmlComponentAttributes(
            xmlAttributes: {
              'w:w': size.width.toString(),
              'w:h': size.height.toString(),
              'w:orientation': orientation.name,
            },
          ),
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      isSelfClosing: true,
    );
  }
}
