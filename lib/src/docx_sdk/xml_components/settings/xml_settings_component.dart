import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '_xml_base_note_pr_component.dart';
import '_xml_character_spacing_control_component.dart';
import '_xml_color_scheme_map_component.dart';
import '_xml_compatibility_component.dart';
import '_xml_decimal_symbol_component.dart';
import '_xml_default_tab_stop_component.dart';
import '_xml_list_separator_component.dart';
import '_xml_math_pr_component.dart';
import '_xml_shape_defaults_component.dart';
import '_xml_theme_font_language_component.dart';
import '_xml_track_revisions_component.dart';
import '_xml_zoom_component.dart';

//TODO: we need to add examples on how coustomizing these
// options can change our docx output
/// A component representing the 'settings.xml' part of a DOCX document.
///
/// This component generates the `w:settings` XML element and its children,
/// allowing customization through [SettingsOptions].
class XmlSettingsComponent extends XmlComponentBase<List<XmlComponentBase>> {
  /// Creates an [XmlSettingsComponent] with the specified [options].
  ///
  /// The [options] parameter allows customization of various document settings.
  XmlSettingsComponent({
    required this.options,
  }) : super(
          xmlKey: 'w:settings',
          attrs: XmlDocAttributes(
            w: true,
            mc: true,
            o: true,
            r: true,
            m: true,
            v: true,
            w10: true,
            w14: true,
            w15: true,
            sl: true,
          ),
          value: <XmlComponentBase>[
            XmlZoomComponent(percent: options.zoomPercent),
            XmlTrackRevisionsComponent(val: options.trackRevisions),
            //XmlDocumentProtectionComponent(),
            XmlDefaultTabStopComponent(val: options.defaultTabStop),
            XmlCharacterSpacingControlComponent(
              val: options.characterSpacingControl,
            ),
            if (options.footnoteProperties != null) XmlFootnotePrComponent(options: options.footnoteProperties!),
            if (options.endnoteProperties != null) XmlEndnotePrComponent(options: options.endnoteProperties!),
            XmlCompatComponent(compatSettings: options.compatSettings),
            if (options.mathProperties != null) XmlMathPrComponent(options: options.mathProperties!),
            XmlThemeFontLangComponent(
              val: options.themeFontLanguage,
              eastAsia: options.themeFontLanguageEastAsia,
            ),
            XmlColorSchemeMappingComponent(
              mapping: options.colorSchemeMapping,
            ),
            XmlShapeDefaultsComponent(),
            XmlDecimalSymbolComponent(val: options.decimalSymbol),
            XmlListSeparatorComponent(val: options.listSeparator),
          ],
        );

  /// The configurable options for the document settings.
  final SettingsOptions options;

  @override
  String get name => 'Settings';

  @override
  String get path => DocxPaths.settingsXmlFilePath;

  @override
  XmlElement buildXml() {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: <XmlNode>[
        ...value.map<XmlElement>((
          XmlComponentBase<dynamic> e,
        ) =>
            e.buildXml()),
      ],
    );
  }
}
