import 'package:xml/xml.dart';

import '../../core/extensions/string_ext.dart';
import '../sdk.dart';

/// Represents a Word document style with support for inheritance and revision tracking.
///
/// Styles define formatting rules for paragraphs, characters, and other document elements.
/// Each style can inherit properties from a base style using the `w:basedOn` mechanism,
/// creating a hierarchy of formatting rules.
///
/// Example usage:
/// ```dart
/// final headingStyle = Style(
///   type: Style.paragraphType,
///   styleId: 'Heading1',
///   styleName: 'Heading 1',
///   configurators: [
///     StyleConfigurator.noSelfClosing(
///       prefix: 'w',
///       propertyName: 'rPr',
///       configurators: [
///         StyleConfigurator.selfClosing(
///           prefix: 'w',
///           propertyName: 'b',
///           value: true,
///         ),
///       ],
///     ),
///   ],
/// );
/// ```
class Style extends IterableConfigurators {
  /// Creates a fully-defined style with all required properties.
  ///
  /// [type]: The style type - either [Style.paragraphType] or [Style.characterType]
  /// [styleId]: Unique identifier used in XML (e.g., "Heading1", "Normal", "Hyperlink")
  /// [styleName]: Display name shown in Word's style picker
  /// [alternativeNames]: Display name using the System Language to allow Word picking the correct name. First argument is the name in the language that correspond to the languages of the second argument in Tuple
  /// [defaultValue]: Whether this style is marked as default
  /// [configurators]: Collection of style properties and formatting rules
  /// [rId]: Revision save ID when style was set as default (w:rsidDefault)
  /// [revisionIdPPr]: Revision ID for paragraph properties changes (w:rsidP)
  /// [revisionIdRun]: Revision ID for general text properties changes (w:rsidR)
  /// [revisionIdRPr]: Revision ID for specific text properties changes (w:rsidRPr)
  Style({
    required this.type,
    required this.styleId,
    String? styleName,
    this.defaultValue,
    Iterable<StyleConfigurator>? configurators,
    this.revisionIdDefault,
    this.revisionIdPPr,
    this.revisionIdRun,
    this.revisionIdRPr,
  })  : id = nanoid(10),
        _onlyReference = false,
        super(
          configurators: List.from(
            configurators ?? <StyleConfigurator>[],
          ),
        ) {
    if (styleName != null) {
      super.configurators.insert(
            0,
            StyleConfigurator.selfClosing(
              prefix: 'w',
              propertyName: 'name',
              value: styleName,
            ),
          );
    }
  }

  /// Creates a lightweight style reference for lookup/search purposes only.
  ///
  /// This constructor creates a minimal Style instance that contains only
  /// the styleId, useful for searching styles in a document without loading
  /// all their properties.
  ///
  /// Example:
  /// ```dart
  /// final reference = Style.reference('Heading1');
  /// final fullStyle = styleSheet.getStyleById(reference.styleId);
  /// ```
  Style.reference(this.styleId)
      : type = '',
        revisionIdDefault = null,
        id = nanoid(10),
        defaultValue = null,
        revisionIdRPr = null,
        revisionIdRun = null,
        revisionIdPPr = null,
        _onlyReference = true,
        super(
          configurators: <StyleConfigurator>[],
        );

  Style.themeReference(int idx)
      : type = '',
        styleId = '$idx',
        revisionIdDefault = null,
        id = nanoid(10),
        defaultValue = null,
        revisionIdRPr = null,
        revisionIdRun = null,
        revisionIdPPr = null,
        _onlyReference = true,
        super(
          configurators: <StyleConfigurator>[],
        );

  /// Creates a placeholder Style instance representing an invalid or missing style.
  ///
  /// Useful as a sentinel value or default return when a requested style doesn't exist.
  factory Style.invalid() {
    return Style(
      type: 'invalid',
      styleId: 'invalid',
      styleName: 'invalid',
    );
  }

  List<StyleConfigurator> prioritySort() {
    configurators.sort((StyleConfigurator a, StyleConfigurator b) {
      if (a.qualifiedName == xmlStyleName) {
        return -1;
      }
      return 0;
    });
    return configurators;
  }

  // Style type constants
  static const String paragraphType = 'paragraph';
  static const String listType = 'list';
  static const String numberingType = 'numbering';
  static const String characterType = 'character';
  static const String tableType = 'table';

  // Internal state
  bool _onlyReference = false;
  late String id;

  /// Revision tracking IDs (rsid) - used for collaborative editing and change tracking

  /// Revision save ID when this style was set as the default style.
  /// Corresponds to w:rsidDefault in Word XML.
  final String? revisionIdDefault;

  /// Revision save ID for changes to paragraph properties (w:pPr elements).
  /// Updated when paragraph formatting (alignment, spacing, indentation) is modified.
  final String? revisionIdPPr;

  /// Revision save ID for changes to general text properties (w:rPr base properties).
  /// Updated when fundamental text formatting (font, size, bold, italic) is modified.
  final String? revisionIdRun;

  /// Revision save ID for changes to specific text properties (w:rPr specific properties).
  /// Updated when decorative text formatting (color, underline, highlighting) is modified.
  final String? revisionIdRPr;

  /// Style properties

  /// The type of style: 'paragraph' for paragraph styles, 'character' for character styles.
  final String type;

  /// Unique identifier used in Word XML to reference this style.
  /// This ID appears in document.xml as w:styleId attributes.
  final String styleId;

  /// Indicates if this style is marked as default in its category.
  final Object? defaultValue;

  /// Returns true if this is a reference-only style (created with [Style.reference]).
  bool get isReference => _onlyReference;

  /// Returns true if this represents an invalid or non-existent style.
  bool get isInvalid => styleId == 'invalid' && type == 'invalid';

  /// Returns the configurators that contains all the properties that set
  /// the styles to the paragraphs
  StyleConfigurator? get paragraphProperties => getConfiguratorOrNull('w:pPr');

  /// Returns the configurators that contains all the properties that set
  /// the styles to the text runs
  StyleConfigurator? get runProperties => getConfiguratorOrNull('w:rPr');

  static StyleConfigurator? styleConfiguratorOrNull(
      StyleConfigurator configurator) {
    return configurator.isInvalid ? null : configurator;
  }

  static Style? styleOrNull(Style style) {
    return style.isInvalid ? null : style;
  }

  /// Gets the base style that this style inherits from, if any.
  ///
  /// Searches for a w:basedOn configurator and returns the corresponding
  /// Style from the provided [styles] sheet. Returns null if no base style
  /// is defined or if the referenced style doesn't exist.
  Style? getStyleWhereBaseOn(DocumentStyles styles) {
    final StyleConfigurator? basedOnConfigurator =
        getConfiguratorOrNull('w:basedOn');
    if (basedOnConfigurator == null) return null;

    final Style? style =
        styles.getStyleById(basedOnConfigurator.value as String);
    if (style == null) return null;

    assert(style.styleId == basedOnConfigurator.value,
        'Style ID mismatch: expected ${basedOnConfigurator.value}, found ${style.styleId}');
    return style;
  }

  /// Computes the complete style definition by resolving inheritance chain.
  ///
  /// This method follows the w:basedOn chain through all ancestor styles and
  /// merges their properties to produce a final, fully-resolved style definition.
  /// Properties from more specific styles override those from base styles.
  ///
  /// Example hierarchy resolution:
  /// ```xml
  /// Normal (base) → BodyText (inherits from Normal) → Quote (inherits from BodyText)
  /// ```
  ///
  /// Returns a new Style instance with all inherited properties merged.
  Style getDeepStyleRelation(DocumentStyles styles) {
    if (basedOn == null) {
      return this;
    }
    const int maxAttempts = 200;
    final List<Style> styleHierarchy = <Style>[this];
    Style? currentStyleInChain = this;
    int attempt = 0;

    // Build inheritance chain from base to most specific
    while (currentStyleInChain!.basedOn != null && attempt < maxAttempts) {
      final Style? basedOn =
          styles.getStyleById(currentStyleInChain.basedOn!.value as String);

      if (basedOn != null &&
          !styleHierarchy.any((Style s) => s.id == basedOn.id)) {
        // Insert at beginning to maintain base-first order
        styleHierarchy.insert(0, basedOn);
        currentStyleInChain = basedOn;
      } else {
        break; // No more base styles or circular dependency detected
      }
      attempt++;
    }

    // Maps to accumulate merged properties during inheritance resolution
    final Map<String, StyleConfigurator> mergedTopLevelConfigurators =
        <String, StyleConfigurator>{};
    final Map<String, StyleConfigurator> mergedPPrChildren =
        <String, StyleConfigurator>{};
    final Map<String, StyleConfigurator> mergedRPrChildren =
        <String, StyleConfigurator>{};

    // Helper: Convert configurator list to map for efficient lookups
    Map<String, StyleConfigurator> listToMap(
            Iterable<StyleConfigurator> list) =>
        <String, StyleConfigurator>{
          for (final StyleConfigurator c in list) c.qualifiedName: c
        };

    // Helper: Merge child configurators with inheritance override logic
    Map<String, StyleConfigurator> mergeChildren(
      Map<String, StyleConfigurator> base,
      Iterable<StyleConfigurator> overrides,
    ) {
      final Map<String, StyleConfigurator> result =
          Map<String, StyleConfigurator>.from(base);

      for (final StyleConfigurator overrideConfig in overrides) {
        final StyleConfigurator? existingConfig =
            result[overrideConfig.qualifiedName];

        if (existingConfig != null &&
            existingConfig.hasChildren &&
            overrideConfig.hasChildren) {
          // Both are containers - recursively merge their children
          final Map<String, StyleConfigurator> mergedInnerChildren =
              mergeChildren(
            listToMap(existingConfig.configurators),
            overrideConfig.configurators,
          );

          // Create new container with merged children
          result[overrideConfig.qualifiedName] =
              StyleConfigurator.noSelfClosing(
            propertyName: overrideConfig.propertyName,
            prefix: overrideConfig.prefix,
            value: overrideConfig.value,
            attributes: overrideConfig.attributes,
            configurators: mergedInnerChildren.values.toList(),
          );
        } else {
          // Simple property or new container - override completely
          result[overrideConfig.qualifiedName] = overrideConfig;
        }
      }
      return result;
    }

    // Process inheritance chain: base styles first, then derived styles
    for (final Style style in styleHierarchy) {
      for (final StyleConfigurator config in style.configurators) {
        // Skip inheritance and revision metadata during merging
        if (config.qualifiedName == 'w:basedOn' ||
            config.qualifiedName == 'w:rsid' ||
            // we will ignore always the other names that comes
            // from other styles
            config.qualifiedName == 'w:name') {
          continue;
        }

        // Route configurators to appropriate merge maps
        if (config.qualifiedName == xmlParagraphBlockAttrsNode) {
          // Paragraph properties (w:pPr)
          mergedPPrChildren.addAll(mergeChildren(
            mergedPPrChildren,
            config.configurators,
          ));
        } else if (config.qualifiedName == xmlParagraphInlineAttsrNode) {
          // Text properties (w:rPr)
          mergedRPrChildren.addAll(mergeChildren(
            mergedRPrChildren,
            config.configurators,
          ));
        } else {
          // Top-level properties (name, link, etc.)
          mergedTopLevelConfigurators[config.qualifiedName] = config;
        }
      }
    }

    // Assemble final configurator list from merged properties
    final List<StyleConfigurator> finalConfigurators = <StyleConfigurator>[
      ...configurators
          .where((StyleConfigurator el) => el.qualifiedName == 'w:name'),
      ...mergedTopLevelConfigurators.values
    ];

    // Add paragraph properties container if any paragraph properties exist
    if (mergedPPrChildren.isNotEmpty) {
      finalConfigurators.add(
        StyleConfigurator.noSelfClosing(
          prefix: 'w',
          propertyName: 'pPr',
          configurators: mergedPPrChildren.values.toList(),
        ),
      );
    }

    // Add text properties container if any text properties exist
    if (mergedRPrChildren.isNotEmpty) {
      finalConfigurators.add(
        StyleConfigurator.noSelfClosing(
          prefix: 'w',
          propertyName: 'rPr',
          configurators: mergedRPrChildren.values.toList(),
        ),
      );
    }

    // Return fully resolved style with original metadata
    return Style(
      type: type,
      styleId: styleId,
      defaultValue: defaultValue,
      revisionIdPPr: revisionIdPPr,
      revisionIdRun: revisionIdRun,
      revisionIdRPr: revisionIdRPr,
      revisionIdDefault: revisionIdDefault,
      configurators: finalConfigurators,
    );
  }

  @override
  String toString() {
    return 'Style(id: $id, '
        'type: ${type.isEmpty ? 'no-type' : type}, '
        'styleId: $styleId, '
        'styleName: $styleName => [$configurators]';
  }

  /// Generates the XML representation of this style.
  String toXmlString() {
    return toXmlNode()!.toXmlString();
  }

  XmlElement? toXmlNode() {
    if (isInvalid) return null;
    return XmlElement.tag(
      'w:style',
      attributes: <XmlAttribute>[
        XmlAttribute('w:type'.toName(), type),
        XmlAttribute('w:styleId'.toName(), styleId),
        if (defaultValue != null && defaultValue is num)
          XmlAttribute('w:default'.toName(), defaultValue!.toString()),
        if (revisionIdDefault != null)
          XmlAttribute(
            'w:rsidDefault'.toName(),
            revisionIdDefault!,
          ),
        if (revisionIdPPr != null)
          XmlAttribute(
            'w:rsidP'.toName(),
            revisionIdPPr!,
          ),
        if (revisionIdRun != null)
          XmlAttribute(
            'w:rsidR'.toName(),
            revisionIdRun!,
          ),
        if (revisionIdRPr != null)
          XmlAttribute(
            'w:rsidRPr'.toName(),
            revisionIdRPr!,
          ),
      ],
      children: <XmlNode>[
        ...configurators.map(
          (
            StyleConfigurator configurator,
          ) =>
              configurator.toXmlNode(),
        ),
      ],
      isSelfClosing: false,
    );
  }
}

/// Represents a single XML element within a style definition.
///
/// StyleConfigurator objects form a tree structure that maps to Word's XML format.
/// Each configurator can be either self-closing (<element/>) or contain child
/// elements (<element>...</element>).
///
/// Example XML mapping:
/// ```xml
/// <w:rPr>
///   <w:b w:val="true"/>
///   <w:color w:val="FF0000"/>
/// </w:rPr>
/// ```
/// Corresponds to:
/// ```dart
/// StyleConfigurator.noSelfClosing(
///   propertyName: 'rPr',
///   prefix: 'w',
///   configurators: [
///     StyleConfigurator.selfClosing(
///       propertyName: 'b',
///       prefix: 'w',
///       value: true,
///     ),
///     StyleConfigurator.selfClosing(
///       propertyName: 'color',
///       prefix: 'w',
///       value: 'FF0000',
///     ),
///   ],
/// )
/// ```
class StyleConfigurator extends IterableConfigurators {
  /// Creates a self-closing XML element.
  ///
  /// Self-closing elements have no content and end with />.
  /// Typically used for simple properties like <w:b w:val="true"/>.
  ///
  /// [propertyName]: The XML element name (e.g., "b", "color", "sz")
  /// [prefix]: XML namespace prefix (e.g., "w" for WordProcessingML)
  /// [value]: The w:val attribute value, if applicable
  /// [attributes]: Additional XML attributes as key-value pairs
  StyleConfigurator.selfClosing({
    required this.propertyName,
    this.prefix = 'w',
    this.value,
    this.attributes,
  })  : isSelfClosing = true,
        super(configurators: const <StyleConfigurator>[]);

  /// Creates an invalid configurator placeholder.
  ///
  /// Useful for representing missing or erroneous configurators.
  StyleConfigurator.invalid()
      : propertyName = 'invalid',
        prefix = '',
        value = null,
        attributes = null,
        isSelfClosing = false,
        super(configurators: const <StyleConfigurator>[]);

  /// Creates a non-self-closing XML element that can contain child elements.
  ///
  /// Container elements have both opening and closing tags with content between.
  /// Typically used for grouping elements like <w:rPr>...</w:rPr>.
  ///
  /// [propertyName]: The XML element name
  /// [prefix]: XML namespace prefix
  /// [value]: The w:val attribute value
  /// [attributes]: Additional XML attributes
  /// [configurators]: Child elements contained within this element
  StyleConfigurator.noSelfClosing({
    required this.propertyName,
    this.prefix,
    this.value,
    this.attributes,
    super.configurators = const <StyleConfigurator>[],
  })  : isSelfClosing = false,
        assert(prefix == null || prefix.isNotEmpty, 'Prefix cannot be empty'),
        assert(
          propertyName.isNotEmpty,
          'propertyName cannot be empty',
        );

  /// The local name of the XML element (without namespace prefix).
  final String propertyName;

  /// XML namespace prefix (e.g., 'w', 'r', 'mc').
  final String? prefix;

  /// The value for the w:val attribute, if this element has one.
  final Object? value;

  /// Additional XML attributes beyond w:val.
  final Map<String, dynamic>? attributes;

  /// Whether this element is self-closing (true) or contains children (false).
  final bool isSelfClosing;

  /// The fully qualified XML element name including namespace prefix.
  String get qualifiedName =>
      prefix == null ? propertyName : '$prefix:$propertyName';

  /// Returns true if this configurator represents an invalid element.
  bool get isInvalid =>
      propertyName == 'invalid' ||
      (propertyName.isEmpty &&
          value == null &&
          (attributes == null || attributes!.isEmpty) &&
          configurators.isEmpty &&
          isSelfClosing);

  /// Returns true if this configurator contains child elements.
  bool get hasChildren => configurators.isNotEmpty;

  @override
  String toString() {
    return 'StyleConfigurator(name: $qualifiedName, '
        'value: $value, '
        'attributes: $attributes, '
        'children: ${configurators.length})';
  }

  /// Generates the XML representation of this configurator and its children.
  ///
  /// Produces properly formatted XML with attributes and appropriate closing.
  String toXmlString() {
    return toXmlNode().toXmlString();
  }

  XmlElement toXmlNode() {
    final List<XmlAttribute> xmlAttributes = <XmlAttribute>[];

    if (value != null) {
      xmlAttributes.add(
        XmlAttribute(
          'w:val'.toName(),
          value.toString(),
        ),
      );
    }

    if (attributes != null) {
      for (final MapEntry<String, dynamic> attr in attributes!.entries) {
        if (attr.key == 'w:val' && value != null) {
          continue;
        }
        xmlAttributes.add(
          XmlAttribute(
            attr.key.toName(),
            attr.value.toString(),
          ),
        );
      }
    }

    final List<XmlNode> childrenNodes = configurators
        .map(
          (StyleConfigurator e) => e.toXmlNode(),
        )
        .whereType<XmlElement>()
        .toList();

    final bool shouldBeSelfClosing = isSelfClosing || childrenNodes.isEmpty;

    return XmlElement(
      XmlName.fromString(
        qualifiedName,
      ),
      xmlAttributes,
      childrenNodes,
      shouldBeSelfClosing,
    );
  }
}

/// Base class for objects that contain collections of StyleConfigurators.
///
/// Provides utility methods for searching and accessing configurators
/// within the collection.
abstract class IterableConfigurators {
  IterableConfigurators({
    required Iterable<StyleConfigurator> configurators,
  }) : configurators = List<StyleConfigurator>.from(configurators);

  /// The collection of StyleConfigurator objects.
  final List<StyleConfigurator> configurators;

  void add(StyleConfigurator configurator) => configurators.add(configurator);
  void addAll(Iterable<StyleConfigurator> configurators) =>
      this.configurators.addAll(configurators);

  /// Gets the 'rFonts' configurator if present.
  StyleConfigurator? get fontFamily {
    return getConfiguratorOrNull('w:rFonts');
  }

  /// Gets the 'sz' configurator if present.
  StyleConfigurator? get fontSize {
    return getConfiguratorOrNull('w:sz');
  }

  StyleConfigurator? get fontSizeEastAsia {
    return getConfiguratorOrNull('w:szCs');
  }

  StyleConfigurator? get uiPriority {
    return getConfiguratorOrNull('w:uiPriority');
  }

  StyleConfigurator? get qFormat {
    return getConfiguratorOrNull('w:qFormat');
  }

  StyleConfigurator? get keepNext {
    return getConfiguratorOrNull('w:keepNext');
  }

  StyleConfigurator? get keepLines {
    return getConfiguratorOrNull('w:keepLines');
  }

  StyleConfigurator? get script {
    return getConfiguratorOrNull('w:vertAlign');
  }

  StyleConfigurator? get smallCaps {
    return getConfiguratorOrNull('w:smallCaps');
  }

  StyleConfigurator? get border {
    return getConfiguratorOrNull('w:pBdr');
  }

  StyleConfigurator? get widowControl {
    return getConfiguratorOrNull('w:widowControl');
  }

  StyleConfigurator? get shading {
    return getConfiguratorOrNull('w:shd');
  }

  StyleConfigurator? get paragraphBreakBefore {
    return getConfiguratorOrNull('w:pageBreakBefore');
  }

  StyleConfigurator? get caps {
    return getConfiguratorOrNull('w:caps');
  }

  StyleConfigurator? get alignment {
    return getConfiguratorOrNull('w:jc');
  }

  StyleConfigurator? get outlineLvl {
    return getConfiguratorOrNull('w:outlineLvl');
  }

  StyleConfigurator? get bold {
    return getConfiguratorOrNull('w:b');
  }

  StyleConfigurator? get italic {
    return getConfiguratorOrNull('w:i');
  }

  StyleConfigurator? get underline {
    return getConfiguratorOrNull(
      'w:u',
      predicate: (StyleConfigurator el) => el.value == 'single',
    );
  }

  StyleConfigurator? get strike {
    return getConfiguratorOrNull('w:strike');
  }

  StyleConfigurator? get dstrike {
    return getConfiguratorOrNull('w:dstrike');
  }

  StyleConfigurator? get highlight {
    return getConfiguratorOrNull('w:highlight');
  }

  StyleConfigurator? get color {
    return getConfiguratorOrNull('w:color');
  }

  /// Gets the 'link' configurator if present.
  ///
  /// The link element connects a character style to a paragraph style.
  /// Returns null if no link configurator exists.
  StyleConfigurator? get link {
    return getConfiguratorOrNull('link');
  }

  StyleConfigurator? get next {
    return getConfiguratorOrNull('w:next');
  }

  StyleConfigurator? get semiHidden {
    return getConfiguratorOrNull('w:semiHidden');
  }

  StyleConfigurator? get unhideWhenUsed {
    return getConfiguratorOrNull('w:unhideWhenUsed');
  }

  StyleConfigurator? get spacing {
    return getConfiguratorOrNull('w:spacing');
  }

  int? get spacingBefore {
    return spacing?.attributes?['w:before'];
  }

  int? get spacingAfter {
    return spacing?.attributes?['w:after'];
  }

  num? get lineSpacing {
    return spacing?.attributes?['w:line'];
  }

  String? get lineRule {
    return spacing?.attributes?['w:lineRule'];
  }

  StyleConfigurator? get indent {
    return getConfiguratorOrNull('w:ind');
  }

  StyleConfigurator? get hanging {
    return indent?.getConfiguratorOrNull('w:hanging');
  }

  StyleConfigurator? get leftIndent {
    return indent?.getConfiguratorOrNull('w:left');
  }

  StyleConfigurator? get firstLineIndent {
    return indent?.getConfiguratorOrNull('w:firstLine');
  }

  static StyleConfigurator? styleConfiguratorOrNull(
      StyleConfigurator configurator) {
    return configurator.isInvalid ? null : configurator;
  }

  /// Whether contains the [StyleConfigurator] in this instance
  ///
  /// Only support: [String] and [StyleConfigurator] object instances
  bool contains(Object object) {
    if (object is! String && object is! StyleConfigurator) {
      return false;
    }

    for (final StyleConfigurator config in configurators) {
      if (object is String &&
          (object.contains(':')
              ? config.qualifiedName == object
              : config.propertyName == object)) {
        return true;
      }
      if (object is StyleConfigurator && config == object) return true;
    }
    return false;
  }

  /// Gets the 'basedOn' configurator if present.
  ///
  /// The basedOn element defines style inheritance by referencing
  /// another style's ID. Returns null if no inheritance is defined.
  StyleConfigurator? get basedOn {
    return getConfiguratorOrNull('w:basedOn');
  }

  /// Gets the first 'name' configurator if present.
  StyleConfigurator? styleName({String? language}) {
    return styleConfiguratorOrNull(configurators.firstWhere(
      (StyleConfigurator e) {
        final dynamic lang = (e.attributes ?? <String, dynamic>{})['w:lang'];
        return language != null
          ? e.qualifiedName == 'w:name' && lang == language
          : e.qualifiedName == 'w:name' || e.propertyName == 'name';
      },
      orElse: StyleConfigurator.invalid,
    ));
  }

  /// Gets all the 'name' configurators if present.
  ///
  /// Usually we use them to know all names by language
  Iterable<StyleConfigurator> styleNames() {
    return configurators.where(
      (StyleConfigurator e) =>
          e.qualifiedName == 'w:name' || e.propertyName == 'name',
    );
  }

  /// Finds a configurator by name, returning null if not found.
  ///
  /// [matcher]: The name to search for (can be qualified like 'w:basedOn'
  ///            or unqualified like 'basedOn')
  /// [fullName]: If true, requires exact match including namespace prefix
  /// [predicate]: custom property to allow filtering with granular information
  ///
  /// Returns the matching configurator or null.
  StyleConfigurator? getConfiguratorOrNull(
    String matcher, {
    bool fullName = false,
    bool Function(StyleConfigurator)? predicate,
  }) {
    return styleConfiguratorOrNull(configurators.firstWhere(
      (StyleConfigurator e) => (fullName || matcher.contains(':'))
          ? e.qualifiedName == matcher &&
              (predicate == null ? true : predicate(e))
          : e.propertyName == matcher &&
              (predicate == null ? true : predicate(e)),
      orElse: StyleConfigurator.invalid,
    ));
  }

  /// Finds a configurator by name, returning an invalid configurator if not found.
  ///
  /// Similar to [getConfiguratorOrNull] but always returns a StyleConfigurator,
  /// which may be invalid if no match was found.
  StyleConfigurator getConfigurator(String matcher, {bool fullName = false}) {
    return configurators.firstWhere(
      (StyleConfigurator e) => fullName || matcher.contains(':')
          ? e.qualifiedName == matcher
          : e.propertyName == matcher,
      orElse: StyleConfigurator.invalid,
    );
  }

  /// Finds all configurators matching the given name.
  ///
  /// Returns an iterable containing all configurators whose qualified name
  /// or property name matches the given [matcher].
  Iterable<StyleConfigurator> findAllElements(String matcher) {
    if (configurators.isEmpty) return <StyleConfigurator>[];
    return configurators.where(
      (StyleConfigurator e) => matcher.contains(':')
          ? e.qualifiedName == matcher
          : e.propertyName == matcher,
    );
  }
}
