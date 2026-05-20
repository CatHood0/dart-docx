import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../../../../core/extensions/cast_ext.dart';
import '../../../../core/extensions/style_to_from_node.dart';
import '../../../compiler/inherited/compiler_config_provider.dart';

/// Fundamental document unit for organizing text content.
///
/// ### Text Formatting
/// ```dart
/// Text.text(
///   text: 'Formatted text',
///   bold: true,
///   italic: true,
///   underline: true,
///   strikethrough: true,
/// );
/// ```
///
/// ### Font Properties
/// ```dart
/// Text.text(
///   text: 'Custom font',
///   size: 12,  // In Points units
///   family: 'Arial',   // Font name
///   color: Color(0xFF0000FF),   // Blue text
///   backgroundColor: Color(0xFFFFFF00), // Yellow highlight
/// );
/// ```
///
/// See also:
/// - [StyleBuilder] for creating complex styles
/// - [ParagraphBorders] for paragraph border configuration
/// - [WidowOrphanControl] for widow/orphan line control
class Text extends ComponentContainer<String> {
  Text(
    String text, {
    Iterable<Style> styles = const <Style>[],
    this.textAlign,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.size,
    this.family,
    this.color,
    this.backgroundColor,
    this.lineSpacing,
    this.subscript = false,
    this.superscript = false,
    super.id,
    super.parent,
  })  : assert(!subscript && !superscript || subscript != superscript,
            'subscript and superscript must be different'),
        styles = List.from(styles),
        super(child: text);

  /// All the styles applied to the paragraph
  List<Style> styles;
  TextAlign? textAlign;

  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;

  // Font properties
  final num? size;
  final String? family;
  final Color? color;
  final Color? backgroundColor;

  final int? lineSpacing;
  final bool subscript;
  final bool superscript;

  @override
  List<XmlNode> buildXml() {
    // I hate this type assign. I'd prefer just making
    // a different context per element instead just one
    final List<XmlNode> paragraphChildren = <XmlNode>[];
    final List<XmlElement> paragraphStyles = buildXmlStyle();
    if (paragraphStyles.isNotEmpty) {
      paragraphChildren.add(
        XmlElement.tag(
          xmlParagraphBlockAttrsNode,
          children: paragraphStyles,
          isSelfClosing: false,
        ),
      );
    }

    final bool hasNewLines = child.contains('\n');
    for (final String e in child.split('\n')) {
      final List<XmlNode> element = TextRun.inheritFrom(
        text: e,
        element: this,
      ).buildXml();
      paragraphChildren.addAll([
        ...element,
        if (hasNewLines) ...Run.lineBreak().buildXml(),
      ]);
    }

    return <XmlElement>[
      super.paragraph(
        attributes: <XmlAttribute>[],
        children: paragraphChildren,
        isSelfClosing: false,
      ),
    ];
  }

  Paragraph toParagraph() => Paragraph.text(
        id: id,
        bold: bold,
        text: child,
        parent: parent,
        italic: italic,
        fontSize: size,
        fontColor: color,
        runStyles: styles,
        fontFamily: family,
        underline: underline,
        lineSpacing: lineSpacing,
        strikethrough: strikethrough,
        backgroundColor: backgroundColor,
      );

  @override
  List<XmlElement> buildXmlStyle() {
    final List<XmlElement> pPrChildren = <XmlElement>[];

    bool alreadyHasReference = false;

    final Style? directStyle = _buildDirectStyle();
    if (directStyle != null) {
      final List<XmlElement> directStyleXml = directStyle.forParagraphStyle(
        shouldShowStyleRef: false,
        useConfigurators: true,
      );
      pPrChildren.addAll(directStyleXml);
    }

    // to avoid applying the same styles every time, we prefer
    // having something like a memoizer to avoid expensive calls
    //
    // For example, you can have 3 styles that area based on 'Normal'
    // style, so...
    // do you want to apply the 'Normal' style 3 times?
    // right, you don't!
    //TODO: we need to register configurators
    final Map<String, Style> appliedStyles = <String, Style>{};

    final CompilerConfigProvider? configs = CompilerConfigProvider.of(this);
    if (styles.isEmpty && configs?.normalStyleIfNeeded == true) {
      assert(
        configs!.normalStyle.isReference,
        'defaultNormalStyle in DocumentContext is '
        'not a reference. Please, ensure you are '
        'setting a reference style',
      );
      Style? st = configs!.normalStyle;
      if (alreadyHasReference || configs.checkStyleRefExistence) {
        final Style? normal =
            configs.options.docStyles.getStyleById(configs.normalStyle.styleId);
        if (normal != null && !normal.isInvalid) {
          st = normal;
        } else {
          st = null;
          CompilerLogger.root.warning(
            'Not found style "${configs.normalStyle.styleId}". '
            'It will be ignored for '
            '$runtimeType:$id at $index with deep tree level $depth, '
            'child of ${parent?.runtimeType}',
          );
        }
      }

      return <XmlElement>[
        ...?st?.forParagraphStyle(),
        ...pPrChildren,
      ];
    }

    for (final Style style in styles) {
      if (style.isInvalid || appliedStyles.containsKey(style.styleId)) {
        continue;
      }
      Style? st = style;
      // Resolve references
      if (style.isReference && configs?.checkStyleRefExistence == true) {
        final Style? stemp =
            configs!.options.docStyles.getStyleById(style.styleId);
        if (stemp != null && !stemp.isInvalid) {
          st = stemp;
        } else {
          st = null;
          CompilerLogger.root.warning(
            'Not found style "${style.styleId}". '
            'It will be ignored for '
            '$runtimeType:$id at $index with deep tree level $depth, '
            'child of ${parent?.runtimeType}',
          );
        }
      }
      if (st == null) continue;
      // when a style isnt in DocumentStylesSheet, we prefer ignoring its
      // w:pStyle ref
      appliedStyles[st.styleId] = st;
      final List<XmlElement> xml = st.forParagraphStyle(
        shouldShowStyleRef: st.isReference,
        useConfigurators: !st.isReference,
      );
      pPrChildren.addAll(xml);
    }
    return <XmlElement>[...pPrChildren];
  }

  /// Builds a Style from direct paragraph properties.
  ///
  /// This allows applying formatting directly without requiring StyleBuilder.
  Style? _buildDirectStyle() {
    final StyleBuilder builder = StyleBuilder.up();
    if (textAlign != null) builder.alignment(textAlign!.toAlign);

    if (textAlign == null && isChildOf<Align>()) {
      final Alignment al = getAncestorOfExactType<Align>()!.alignment;
      CompilerLogger.root.debug(
          'Replace current align $textAlign to found ancestor ${al.name}');
      builder.alignment(al);
    }

    if (bold) builder.bold();
    if (italic) builder.italic();
    if (underline) builder.underline();
    if (strikethrough) builder.strikethrough();
    if (size != null) builder.fontSize(size!.ptToHalfPoints());
    if (family != null) builder.fontFamily(family!);
    if (color != null) builder.runColor(color!);
    if (backgroundColor != null) builder.highlight(backgroundColor!);

    if (lineSpacing != null) {
      builder.spacing(
        line: lineSpacing!.ptToTwips(),
        rule: LineRule.atLeast,
      );
    }
    return builder.build();
  }

  @override
  Text get copy => Text(
        child,
        id: id,
        textAlign: textAlign,
        parent: parent,
        styles: styles,
        bold: bold,
        italic: italic,
        underline: underline,
        strikethrough: strikethrough,
        size: size,
        family: family,
        color: color,
        subscript: subscript,
        superscript: superscript,
        backgroundColor: backgroundColor,
        lineSpacing: lineSpacing,
      );

  @override
  Text copyWith({
    String? child,
    String? id,
    DocxNode<dynamic>? parent,
    Iterable<Style>? styles,
    TextAlign? textAlign,
    bool? bold,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    num? size,
    String? family,
    Color? color,
    Color? backgroundColor,
    int? lineSpacing,
    bool? subscript,
    bool? superscript,
  }) {
    return Text(
      child ?? this.child,
      styles: styles ?? this.styles,
      textAlign: textAlign ?? this.textAlign,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      size: size ?? this.size,
      family: family ?? this.family,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      subscript: subscript ?? this.subscript,
      superscript: superscript ?? this.superscript,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? toList() : null;
  }
}
