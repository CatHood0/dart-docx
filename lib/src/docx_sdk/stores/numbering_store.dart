import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../docx.dart';
import '../../core/extensions/string_ext.dart';
import '../xml_components/numbering/abstract_numbering_component.dart';
import '../xml_components/numbering/concrete_numbering_component.dart';

/// Stores numbering abstract instances and concretes ones.
///
/// Manages all about:
/// - Storing abstract numbering templates (w:abstractNum)
/// - Storing concrete numbering instances (w:num)
/// - Generating unique IDs for both abstract and concrete numberings
/// - Registering concrete instances when numbering is used in content
/// - Auto-discovering numbering usage in the document
class NumberingStore extends Store {
  NumberingStore();

  /// Map of abstract numbering templates by reference key.
  final Map<String, XmlAbstractNumComponent> _abstractNumberings =
      <String, XmlAbstractNumComponent>{};

  /// Map of concrete numbering instances by reference key.
  final Map<String, XmlConcreteNumberingComponent> _concreteNumberings =
      <String, XmlConcreteNumberingComponent>{};

  /// Map of reference configurations (LevelOptions) by reference key.
  final Map<String, List<LevelOptions>> _referenceConfigMap =
      <String, List<LevelOptions>>{};

  int _nextAbstractId = 0;
  int _nextConcreteId = 0;

  int _generateAbstractId() => ++_nextAbstractId;
  int _generateConcreteId() => ++_nextConcreteId;

  bool _isInitialized = false;
  final List<NumberingOptions> _customNumbering = <NumberingOptions>[];

  /// Returns all abstract numbering templates.
  Iterable<XmlAbstractNumComponent> get abstractTemplates =>
      _abstractNumberings.values;

  /// Returns all concrete numbering instances.
  Iterable<XmlConcreteNumberingComponent> get concreteInstances =>
      _concreteNumberings.values;

  /// Gets the abstract numbering ID for a given reference key.
  num? getAbstractNumId(String ref) => _abstractNumberings[ref]?.id;

  /// Gets the concrete numbering ID for a given reference key.
  ///
  /// Using `nodeId` property lets to the compiler knowing what nodes should
  /// use that exact concrete instance reference. If not provided, there's no
  /// problem, but then you'll need to know that then numberings must be registered
  /// in compilation time instead of previous discovering
  int? getConcreteNumId(
    String ref, {
    String? nodeId,
  }) =>
      _concreteNumberings[
              '$ref${nodeId != null && nodeId.isNotEmpty ? '-$nodeId' : ''}']
          ?.numId ??
      _concreteNumberings[ref]?.numId;

  bool hasConcreteInstance(String ref, [String? nodeId]) =>
      getConcreteNumId(ref, nodeId: nodeId) != null;

  /// Gets the abstract numbering component for a given reference key.
  @internal
  XmlAbstractNumComponent? getAbstractNumbering(String ref) =>
      _abstractNumberings[ref];

  /// Gets the concrete numbering component for a given reference key.
  @internal
  XmlConcreteNumberingComponent? getConcreteNumbering(
    String ref, {
    String? nodeId,
  }) =>
      _concreteNumberings[
          '$ref${nodeId != null && nodeId.isNotEmpty ? '-$nodeId' : ''}'] ??
      _concreteNumberings[ref];

  @override
  String get storeName => 'Numbering Store';

  /// Resets the numbering store to its initial state.
  @override
  void reset() {
    _abstractNumberings.clear();
    _concreteNumberings.clear();
    _referenceConfigMap.clear();
    _customNumbering.clear();
    _isInitialized = false;
    _nextAbstractId = 0;
    _nextConcreteId = 0;
  }

  /// Initializes the numbering store with provided options and default templates.
  ///
  /// This method must be called before `buildNumberingXmlComponent`
  /// or any component attempts to register concrete numbering instances.
  @override
  void initialize(PipelineContext context) {
    _registerCustom(List.from(
      context.document.options.numberingOptions,
    ));
    _registerDefaultNumberings();
    _isInitialized = true;
  }

  void _registerCustom(List<NumberingOptions> numbering) {
    _customNumbering.addAll(numbering);
  }

  void _registerDefaultNumberings() {
    for (final NumberingOptions opt in _customNumbering) {
      _registerAbstractNumbering(opt);
    }
    // Register default numberings
    for (final NumberingOptions opt in defaultNumberings) {
      _registerAbstractNumbering(opt);
    }
  }

  /// Registers an abstract numbering definition.
  ///
  /// Creates the XmlAbstractNumComponent and stores it by reference key.
  void registerAbstractNumbering(NumberingOptions options) {
    _registerAbstractNumbering(options);
  }

  void _registerAbstractNumbering(NumberingOptions options) {
    final id = _generateAbstractId();
    CompilerLogger.root.debug(
      'Registering abstract numbering "${options.refKey}" with id $id',
    );
    _abstractNumberings[options.refKey] = XmlAbstractNumComponent(
      id: id,
      levels: options.levels,
    );
    _referenceConfigMap[options.refKey] = options.levels;
  }

  /// Registers a concrete numbering instance for a given reference.
  ///
  /// Creates a concrete numbering instance based on an abstract numbering
  /// template. This is called when a paragraph uses a particular numbering
  /// reference key.
  ///
  /// Parameters:
  /// - [ref]: The reference key of the abstract numbering template.
  /// - [numRefId]: The instance ID for this concrete numbering.
  /// - [level]: Optional level override.
  void registerConcreteInstance(String ref, int numRefId,
      {String? nodeId, int? level}) {
    final XmlAbstractNumComponent? abstractN = _abstractNumberings[ref];
    if (abstractN == null) {
      CompilerLogger.root.warning(
        'Cannot register concrete instance: no abstract numbering found for "$ref"',
      );
      return;
    }

    final String effectiveReference =
        '$ref-$numRefId${nodeId != null && nodeId.isNotEmpty ? '-$nodeId' : ''}';
    if (_concreteNumberings.containsKey(effectiveReference)) {
      CompilerLogger.root.debug(
        'Concrete instance "$effectiveReference" already registered, skipping',
      );
      return;
    }

    final List<LevelOptions>? referenceConfig = _referenceConfigMap[ref];
    final int? firstLevelStartNumber = referenceConfig?.firstOrNull?.start;

    CompilerLogger.root.debug(
      'Registering concrete: $effectiveReference of level $level',
    );
    CompilerLogger.root.debug(
      'Overrides: first level number => $firstLevelStartNumber',
    );

    final ConcreteNumberingOptions concreteOptions = ConcreteNumberingOptions(
      numId: _generateConcreteId(),
      abstractRefId: abstractN.id.toInt(),
      refKey: ref,
      copyId: numRefId,
      overrides: <ConcreteLevelOverride>[
        if (firstLevelStartNumber != null)
          ConcreteLevelOverride(
            indentLevel: 0,
            startAt: firstLevelStartNumber,
          ),
      ],
    );

    _concreteNumberings[effectiveReference] =
        XmlConcreteNumberingComponent(concreteOptions);
  }

  /// Discovers all numbering usage in the document and registers concrete instances.
  ///
  /// This method visits the document tree looking for Paragraphs with numbering
  /// and NumberingList components, then registers concrete instances for each unique
  /// node ID + reference + instance ID combination found.
  void discoverAndRegister(DocxDocument document) {
    CompilerLogger.root.debug('Starting numbering auto-discovery');

    // Collect all unique (reference, refId) combinations
    final Set<(String?, String, int)> uniqueNumberings = {};

    document.root.visitAllElement(
      visitChildrenIfNeeded: true,
      (DocxNode<dynamic> element) {
        if (element is Paragraph && element.numbering != null) {
          final num = element.numbering!;
          uniqueNumberings.add((element.id, num.reference, num.refId!));
        }
        // NumberingList will not count, since will register the concrete instances
        // in compilation time. At this point, the implementation replaces
        // some elements automatically, and cannot be do it in another way
        // so, letting to the Paragraph the task of registering the concrete instance
        return false;
      },
    );

    // Register each unique combination
    for (final (id, ref, refId) in uniqueNumberings) {
      registerConcreteInstance(ref, refId, nodeId: id);
    }

    CompilerLogger.root.debug(
      'Numbering auto-discovery complete. Registered ${_concreteNumberings.length} concrete instances',
    );
  }

  /// Checks if an abstract numbering exists for the given reference key.
  bool hasAbstractNumbering(String ref) => _abstractNumberings.containsKey(ref);

  /// Validates that an abstract numbering exists for the given reference.
  /// Throws an exception if not found.
  void validateAbstractNumberingExistence(String ref) {
    if (!hasAbstractNumbering(ref)) {
      throw Exception(
        '''No registered abstract instance for $ref. Please ensure that you are passing the NumberingOption in "numberingOption" property from DocumentOptions class.
NumberingOptions(
  refKey: '$ref',
  levels: <LevelOptions>[
    LevelOptions(
      level: 0,
      format: LevelFormat.bullet,
      text: '\u25CF',
      start: 1,
      paragraphStyle: StyleBuilder.paragraph('$ref-lvl0')
        .indent(
          left: 0.5.inchesToTwips(),
          hanging: 0.25.inchesToTwips(),
        )
        .build(),
      runStyle: StyleBuilder.character('$ref-lvl0')
        .fontFamily('Symbol')
        .build(),
    ),
  ],
);''',
      );
    }
  }

  /// Builds the [XmlNumberingComponent] for the `numbering.xml` part.
  ///
  /// If no concrete instances have been registered, creates default instances
  /// for all abstract numberings to ensure valid XML output.
  ///
  /// Throws a [StateError] if `initialize` has not been called.
  XmlNumberingComponent buildNumberingXmlComponent() {
    if (!_isInitialized) {
      throw StateError(
        'NumberingStore not initialized. Call initialize() first.',
      );
    }

    // If no concrete instances, create defaults from all abstracts
    if (_concreteNumberings.isEmpty) {
      CompilerLogger.root.debug(
        'No concrete instances registered, creating defaults',
      );
      for (final String ref in _abstractNumberings.keys) {
        registerConcreteInstance(ref, 1);
      }
    }

    return XmlNumberingComponent(
      abstracts: _abstractNumberings.values.toList(),
      concretes: _concreteNumberings.values.toList(),
    );
  }

  static List<NumberingOptions> get defaultNumberings => <NumberingOptions>[
        NumberingOptions(
          refKey: 'unordered',
          levels: <LevelOptions>[
            LevelOptions.bullet(
              level: 0,
              text: '\u25CF',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl0')
                  .indent(
                    left: 0.5.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
              runStyle: StyleBuilder.character('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions.bullet(
              level: 1,
              text: '\u25CB',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl1')
                  .indent(
                    left: 1.0.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
              runStyle: StyleBuilder.character('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions.bullet(
              level: 2,
              text: '\u25A0',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl2')
                  .indent(
                    left: 1.5.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
              runStyle: StyleBuilder.character('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions.bullet(
              level: 3,
              text: '\u25CF',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl3')
                  .indent(
                    left: 2.0.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
              runStyle: StyleBuilder.character('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions.bullet(
              level: 4,
              text: '\u25CB',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl4')
                  .indent(
                    left: 2.5.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
              runStyle: StyleBuilder.character('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions.bullet(
              level: 5,
              text: '\u25A0',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl5')
                  .indent(
                    left: 3.0.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
              runStyle: StyleBuilder.character('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions.bullet(
              level: 6,
              text: '\u25CF',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl6')
                  .indent(
                    left: 3.5.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
              runStyle: StyleBuilder.character('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions.bullet(
              level: 7,
              text: '\u25CB',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl7')
                  .indent(
                    left: 4.0.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
              runStyle: StyleBuilder.character('unordered-lvl0')
                  .fontFamily('Symbol')
                  .build(),
            ),
            LevelOptions.bullet(
              level: 8,
              text: '\u25A0',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('unordered-lvl8')
                  .indent(
                    left: 4.5.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
              runStyle: StyleBuilder.character('unordered-lvl0')
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
                    left: 0.5.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 1,
              format: LevelFormat.upperRoman,
              text: '%2.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl1')
                  .indent(
                    left: 1.0.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 2,
              format: LevelFormat.upperLetter,
              text: '%3.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl2')
                  .indent(
                    left: 1.5.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 3,
              format: LevelFormat.decimal,
              text: '%4.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl3')
                  .indent(
                    left: 2.0.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 4,
              format: LevelFormat.lowerRoman,
              text: '%5.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl4')
                  .indent(
                    left: 2.5.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 5,
              format: LevelFormat.lowerLetter,
              text: '%6.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl5')
                  .indent(
                    left: 3.0.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 6,
              format: LevelFormat.decimal,
              text: '%7.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl6')
                  .indent(
                    left: 3.5.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 7,
              format: LevelFormat.lowerLetter,
              text: '%8.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl7')
                  .indent(
                    left: 4.0.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
            ),
            LevelOptions(
              level: 8,
              format: LevelFormat.lowerRoman,
              text: '%9.',
              start: 1,
              paragraphStyle: StyleBuilder.paragraph('ordered-lvl8')
                  .indent(
                    left: 4.5.inchesToTwips(),
                    hanging: 0.25.inchesToTwips(),
                  )
                  .build(),
            ),
          ],
        ),
      ];
}

/// Configuration for numbered or bulleted list items.
///
/// Defines how a paragraph participates in document numbering (lists).
/// Each numbering reference corresponds to a list definition in the
/// document's numbering store.
class Numbering {
  Numbering({
    required this.reference,
    this.level = 0,
    this.refId,
  }) : assert(
          level >= 0 && level <= 9,
          'Numbering level must be between 0 and 9. '
          'Word does not support more than 9 list levels.',
        );

  /// Reference key to a numbering definition in [NumberingOptions].
  final String reference;

  /// List nesting level (0-9). Level 0 is the top-level list item.
  final int level;

  /// The unique reference id of this item
  ///
  /// Share the same id when you need a continuous
  /// count of your items
  ///
  /// Change the id between the item when you need
  /// to reset the list count
  final int? refId;

  String get concreteRef => '$reference-${refId ?? 0}';

  XmlElement build(int id) {
    return XmlElement.tag(
      'w:numPr',
      children: <XmlNode>[
        XmlElement.tag(
          'w:ilvl',
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:val'.toName(),
              level.toString(),
            ),
          ],
        ),
        XmlElement.tag(
          'w:numId',
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:val'.toName(),
              id.toString(),
            ),
          ],
        ),
      ],
    );
  }
}

