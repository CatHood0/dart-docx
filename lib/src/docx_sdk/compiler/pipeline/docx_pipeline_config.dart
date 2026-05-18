import '../../sdk.dart';

/// Configuración general del pipeline de compilación.
///
/// Contiene opciones que afectan el comportamiento global del compilador.
/// Se pasa al [DocxPipeline] durante su construcción.
///
/// Ejemplo de uso:
/// ```dart
/// final pipeline = DocxPipeline(
///   config: PipelineConfig(
///     applyCustomTheme: true,
///     defaultNormalStyle: Style.ref('Normal'),
///     applyNormalStyleIfNeeded: true,
///   ),
/// );
/// ```
class PipelineConfig {
  PipelineConfig({
    this.applyCustomTheme = false,
    Style? defaultNormalStyle,
    this.applyNormalStyleIfNeeded = true,
    this.noTrim = true,
    this.checkStyleRefExistence = false,
    this.dynamicFontSearch = true,
  }) : defaultNormalStyle = defaultNormalStyle ?? Style.ref('Normal');

  /// Si aplicar tema custom al documento.
  ///
  /// Cuando es true, se incluye el archivo de tema XML en el archive.
  final bool applyCustomTheme;

  /// Estilo "Normal" por defecto aplicado a párrafos sin estilo.
  ///
  /// Por defecto es [Style.ref('Normal')].
  final Style defaultNormalStyle;

  /// Si aplicar estilo Normal a párrafos sin estilo.
  ///
  /// Cuando es true, párrafos que no tienen un estilo explícito
  /// reciben el [defaultNormalStyle].
  final bool applyNormalStyleIfNeeded;

  /// Si preservar whitespace en textos.
  ///
  /// Cuando es true, todos los text runs preservan su whitespace
  /// original con el atributo `xml:space="preserve"`.
  final bool noTrim;

  /// Si validar existencia de Style.ref.
  ///
  /// Cuando es true, cada Style.ref usado en el documento es
  /// verificado contra DocumentStylesSheet. Puede hacer la
  /// compilación más lenta.
  final bool checkStyleRefExistence;

  /// Si descubrir fuentes dinámicamente.
  ///
  /// Cuando es true, el compilador analiza los text runs para
  /// detectar automáticamente las fuentes usadas y registrarlas.
  final bool dynamicFontSearch;

  /// Crea una copia con modificaciones.
  ///
  /// Útil para crear configuraciones derivadas con cambios específicos.
  PipelineConfig copyWith({
    bool? applyCustomTheme,
    Style? defaultNormalStyle,
    bool? applyNormalStyleIfNeeded,
    bool? noTrim,
    bool? checkStyleRefExistence,
    bool? dynamicFontSearch,
  }) {
    return PipelineConfig(
      applyCustomTheme: applyCustomTheme ?? this.applyCustomTheme,
      defaultNormalStyle: defaultNormalStyle ?? this.defaultNormalStyle,
      applyNormalStyleIfNeeded: applyNormalStyleIfNeeded ?? this.applyNormalStyleIfNeeded,
      noTrim: noTrim ?? this.noTrim,
      checkStyleRefExistence: checkStyleRefExistence ?? this.checkStyleRefExistence,
      dynamicFontSearch: dynamicFontSearch ?? this.dynamicFontSearch,
    );
  }
}
