import 'package:xml/xml.dart';
import '../../sdk.dart';
import 'xml_columns_settings_component.dart';

//TODO: analyze this
//
// <w:sectPr><w:type w:val="nextPage"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:left="1440" w:right="1440" w:gutter="0" w:header="0" w:top="1440" w:footer="0" w:bottom="1440"/><w:pgNumType w:fmt="decimal"/><w:cols w:num="2" w:space="0" w:equalWidth="true" w:sep="false"></w:cols><w:formProt w:val="false"/><w:textDirection w:val="lrTb"/><w:docGrid w:type="default" w:linePitch="100" w:charSpace="0"/></w:sectPr>
//
/// Represents the `<w:sectPr>` (Section Properties) element in WordML.
///
/// This component defines various properties for a document section, such as
/// page size, margins, headers/footers, and column layout.
class XmlDocumentSectionSettingsComponent
    extends XmlComponentBase<List<XmlComponentBase>> {
  XmlDocumentSectionSettingsComponent({
    required DocumentLayout options,
    String? themeId,
  }) : super(
          xmlKey: 'w:sectPr',
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
            if (options.columns != null &&
                options.columns!.numColumns != null &&
                options.columns!.numColumns! > 1)
              XmlColumnsSettingsComponent(
                settings: options.columns!,
              ),
            //TODO: we need configurations for headers/footers references etc.
          ],
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
            xmlAttributes: <String, Object>{
              'w:top': margins.top.toInt().toString(),
              'w:bottom': margins.bottom.toInt().toString(),
              'w:left': margins.left.toInt().toString(),
              'w:right': margins.right.toInt().toString(),
              'w:header': margins.header.toInt().toString(),
              'w:footer': margins.footer.toInt().toString(),
              'w:gutter': margins.gutter.toInt().toString(),
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
    extends XmlComponentBase<({PageSize size, Orientation orientation})> {
  XmlPageSizeComponent({
    required PageSize size,
    required Orientation orientation,
  }) : super(
          value: (size: size, orientation: orientation),
          xmlKey: 'w:pgSz',
          attrs: XmlComponentAttributes(
            xmlAttributes: <String, Object>{
              'w:w': size.width.toInt().toString(),
              'w:h': size.height.toInt().toString(),
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
