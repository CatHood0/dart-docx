import '../../../docx.dart';

//TODO: add listeners to events
/// Manages numbering definitions and instances for a Docx document.
/// It provides access to abstract and concrete numbering templates
/// and generates the `numbering.xml` file.
class NumberingStore {
  NumberingStore();

  /// The file path for the numbering XML within the DOCX archive.
  static String get filePath => numberingXmlFilePath;

  late XmlNumberingComponent _numberingComponent;
  DocumentContext? _context;
  bool _isInitialized = false;
  final List<NumberingOptions> _customNumbering = <NumberingOptions>[];

  /// Resets the numbering store to its initial state.
  void reset() {
    if (_context == null) return;
    _customNumbering.clear();
    _context = null;
    _isInitialized = false;
  }

  void _registerCustom(List<NumberingOptions> numbering) {
    _customNumbering.addAll(numbering);
  }

  /// Initializes the numbering store with default templates and applies them
  /// to the provided [context].
  ///
  /// This method must be called before `buildNumberingXmlDocumentComponent`
  /// or any component attempts to register concrete numbering instances.
  void initializeAndApplyContext(DocumentContext context) {
    _context = context;
    _registerCustom(context.options.numberingOptions);
    _numberingComponent = _createDefaultNumberingComponent();
    _numberingComponent.applyContext(context);
    _isInitialized = true;
  }

  /// Builds the [XmlNumberingComponent] for the `numbering.xml` part.
  ///
  /// This method uses the internal [XmlNumberingComponent] and the stored context
  /// to generate the complete numbering XML document.
  ///
  /// Throws a [StateError] if `initializeAndApplyContext` has not been called.
  XmlNumberingComponent buildNumberingXmlDocumentComponent() {
    if (!_isInitialized) {
      throw StateError(
          'NumberingStore not initialized. Call initializeAndApplyContext first.');
    }
    // Return the component itself, which will build the XML when buildDocument is called.
    return _numberingComponent;
  }

  /// Internal helper to create the default numbering component structure.
  ///
  /// This logic was originally in `generateNumberingXMLTemplate`.
  /// [context] The [DocumentContext] to pass to the [XmlNumberingComponent].
  /// It can be `null` during initial reset before the full context is available.
  XmlNumberingComponent _createDefaultNumberingComponent() {
    return XmlNumberingComponent(
      context: _context,
      options: <NumberingOptions>[
        ..._customNumbering,
        ..._defaultOptions,
      ],
    );
  }

  List<NumberingOptions> get _defaultOptions => <NumberingOptions>[
        NumberingOptions(
          refKey: 'unordered',
          levels: <LevelOptions>[
            LevelOptions(
              level: 0,
              format: LevelFormat.bullet,
              text: '\u25CF',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl0')
                  .indent(
                    left: 0.5.toTwipsFromInches(), // 0.5 inch
                    hanging:
                        0.25.toTwipsFromInches(), // 0.25 inch hanging indent
                  )
                  .build(),
              runStyle: StyleBuilder.paragraph('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions(
              level: 1,
              format: LevelFormat.bullet,
              text: '\u25CB',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl1')
                  .indent(
                    left: 1.0.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
              runStyle: StyleBuilder.paragraph('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions(
              level: 2,
              format: LevelFormat.bullet,
              text: '\u25A0', // Square bullet
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl2')
                  .indent(
                    left: 1.5.toTwipsFromInches(), // 1.5 inch
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
              runStyle: StyleBuilder.paragraph('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions(
              level: 3,
              format: LevelFormat.bullet,
              text: '\u25CF',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl3')
                  .indent(
                    left: 2.0.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
              runStyle: StyleBuilder.paragraph('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions(
              level: 4,
              format: LevelFormat.bullet,
              text: '\u25CB',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl4')
                  .indent(
                    left: 2.5.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
              runStyle: StyleBuilder.paragraph('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions(
              level: 5,
              format: LevelFormat.bullet,
              text: '\u25A0',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl5')
                  .indent(
                    left: 3.0.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
              runStyle: StyleBuilder.paragraph('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions(
              level: 6,
              format: LevelFormat.bullet,
              text: '\u25CF',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl6')
                  .indent(
                    left: 3.5.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
              runStyle: StyleBuilder.paragraph('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions(
              level: 7,
              format: LevelFormat.bullet,
              text: '\u25CB',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl7')
                  .indent(
                    left: 4.0.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
              runStyle: StyleBuilder.paragraph('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions(
              level: 8,
              format: LevelFormat.bullet,
              text: '\u25A0',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl8')
                  .indent(
                    left: 4.5.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
              runStyle: StyleBuilder.paragraph('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
          ],
        ),
        NumberingOptions(
          refKey: 'ordered',
          levels: <LevelOptions>[
            LevelOptions(
              level: 0,
              format: LevelFormat.decimal,
              text: '%1.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl0')
                  .indent(
                    left: 0.5.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 1,
              format: LevelFormat.lowerLetter,
              text: '%1.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl1')
                  .indent(
                    left: 1.0.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 2,
              format: LevelFormat.lowerRoman,
              text: '%1.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl2')
                  .indent(
                    left: 1.5.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
            ),
            // You can add more levels here
            LevelOptions(
              level: 3,
              format: LevelFormat.decimal,
              text: '%1.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl3')
                  .indent(
                    left: 2.0.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 4,
              format: LevelFormat.lowerLetter,
              text: '%1.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl4')
                  .indent(
                    left: 2.5.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 5,
              format: LevelFormat.lowerRoman,
              text: '%1.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl5')
                  .indent(
                    left: 3.0.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 6,
              format: LevelFormat.decimal,
              text: '%1.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl6')
                  .indent(
                    left: 3.5.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 7,
              format: LevelFormat.lowerLetter,
              text: '%1.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl7')
                  .indent(
                    left: 4.0.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 8,
              format: LevelFormat.lowerRoman,
              text: '%1.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl8')
                  .indent(
                    left: 4.5.toTwipsFromInches(),
                    hanging: 0.25.toTwipsFromInches(),
                  )
                  .build(),
            ),
          ],
        ),
      ];
}
