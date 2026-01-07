import '../../../../../docx.dart';
import 'compat_settings.dart';
import 'math_properties.dart';
import 'note_properties.dart';

/// Options for configuring the document settings.
class SettingsOptions {
  SettingsOptions({
    required this.zoomPercent,
    required this.trackRevisions,
    required this.defaultTabStop,
    required this.characterSpacingControl,
    required this.footnoteProperties,
    required this.endnoteProperties,
    required this.compatSettings,
    required this.mathProperties,
    required this.themeFontLanguage,
    required this.themeFontLanguageEastAsia,
    required this.colorSchemeMapping,
    required this.decimalSymbol,
    required this.listSeparator,
    this.autoHyphenation = true,
  });

  SettingsOptions.base({
    this.zoomPercent = '100',
    this.trackRevisions = false,
    this.defaultTabStop = '720',
    this.characterSpacingControl = 'doNotCompress',
    this.autoHyphenation = true,
    this.footnoteProperties = const NotePropertiesOptions(
      position: NotePosition.pageBottom,
      numberFormat: NoteNumberFormat.decimal,
      numberStart: '1',
      numberRestart: NoteNumberRestart.continuous,
    ),
    this.endnoteProperties = const NotePropertiesOptions(
      position: NotePosition.docEnd,
      numberFormat: NoteNumberFormat.lowerRoman,
      numberStart: '1',
      numberRestart: NoteNumberRestart.continuous,
    ),
    List<CompatSetting>? compatSettings,
    this.mathProperties,
    this.themeFontLanguage = 'en-US',
    this.themeFontLanguageEastAsia = 'zh-CN',
    this.colorSchemeMapping = const <String, String>{
      'bg1': 'light1',
      't1': 'dark1',
      'bg2': 'light2',
      't2': 'dark2',
      'accent1': 'accent1',
      'accent2': 'accent2',
      'accent3': 'accent3',
      'accent4': 'accent4',
      'accent5': 'accent5',
      'accent6': 'accent6',
      'hyperlink': 'hyperlink',
      'followedHyperlink': 'followedHyperlink',
    },
    this.decimalSymbol = '.',
    this.listSeparator = ',',
  }) : compatSettings = compatSettings ??
            <CompatSetting>[
              ...defaultCompatibilitySettings,
            ];


  static final List<CompatSetting> defaultCompatibilitySettings =
      List<CompatSetting>.unmodifiable(
    <CompatSetting>[
      CompatSetting(
        name: 'compatibilityMode',
        uri: namespaces['word']!,
        val: '12',
      ),
    ],
  );

  /// The zoom percentage for the document view.
  ///
  /// Defaults to '100'.
  final String zoomPercent;

  /// Whether revision tracking is enabled.
  ///
  /// Defaults to `false`.
  final bool trackRevisions;

  /// Whether auto hyphenation is enabled.
  ///
  /// Defaults to `true`.
  final bool autoHyphenation;

  /// The default tab stop value in twentieths of a point.
  ///
  /// Defaults to '720' (0.5 inch).
  final String defaultTabStop;

  /// Controls character spacing behavior.
  ///
  /// Defaults to 'doNotCompress'.
  final String characterSpacingControl;

  /// Options for configuring footnote properties.
  final NotePropertiesOptions footnoteProperties;

  /// Options for configuring endnote properties.
  final NotePropertiesOptions endnoteProperties;

  /// A list of compatibility settings for the document.
  ///
  /// Defaults to a standard set of compatibility options.
  final List<CompatSetting> compatSettings;

  /// Options for configuring mathematical properties.
  final MathPropertiesOptions? mathProperties;

  /// The default theme font language.
  ///
  /// Defaults to 'en-US'.
  final String themeFontLanguage;

  /// The East Asian theme font language.
  ///
  /// Defaults to 'zh-CN'.
  final String themeFontLanguageEastAsia;

  /// A map defining the color scheme mapping for the document.
  ///
  /// Each key represents a color type (e.g., 'bg1', 'accent1') and
  /// its value is the corresponding theme color name.
  final Map<String, String> colorSchemeMapping;

  /// The character used as the decimal symbol.
  ///
  /// Defaults to '.'.
  final String decimalSymbol;

  /// The character used as the list separator.
  ///
  /// Defaults to ','.
  final String listSeparator;
}
