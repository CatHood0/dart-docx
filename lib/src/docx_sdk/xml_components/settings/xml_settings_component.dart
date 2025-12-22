import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '_xlm_doc_protection_component.dart';
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
import 'entities/settings.dart';

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
            mc: true,
            o: true,
            r: true,
            m: true,
            v: true,
            w10: true,
            w: true,
            w14: true,
            w15: true,
            sl: true,
            ignorables: 'w14 w15',
          ),
          value: <XmlComponentBase>[
            XmlZoomComponent(percent: options.zoomPercent),
            XmlTrackRevisionsComponent(val: options.trackRevisions),
            XmlDocumentProtectionComponent(),
            XmlDefaultTabStopComponent(val: options.defaultTabStop),
            XmlCharacterSpacingControlComponent(
              val: options.characterSpacingControl,
            ),
            XmlFootnotePrComponent(options: options.footnoteProperties),
            XmlEndnotePrComponent(options: options.endnoteProperties),
            XmlCompatComponent(compatSettings: options.compatSettings),
            XmlMathPrComponent(options: options.mathProperties),
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
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: <XmlNode>[
        ...value.map<XmlElement>((
          XmlComponentBase<dynamic> e,
        ) =>
            e.buildXml(context)),
      ],
    );
  }
}
