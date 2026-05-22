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
/// - [Borders] for paragraph border configuration
/// - [WidowOrphanControl] for widow/orphan line control
class Text extends ComponentContainer<String> {
  Text(
    String text, {
    Iterable<Style> styles = const <Style>[],
    this.textAlign,
    this.textStyle,
    super.id,
    super.parent,
  })  : styles = List.from(styles),
        super(child: text);

  /// All the styles applied to the paragraph
  List<Style> styles;
  TextAlign? textAlign;
  TextStyle? textStyle;

  @override
  List<XmlNode> buildXml() {
    //TODO: we need to make definitely rules to avoid styles being paragraph block definitions 
    // to use only inline ones
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
      final List<XmlNode> element = TextRun.text(
        text: e,
        parent: this,
        styles: styles,
        textStyle: textStyle,
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
        text: child,
        parent: parent,
        runStyles: styles,
        textStyle: textStyle,
      );

  @override
  List<XmlElement> buildXmlStyle() {
    final List<XmlElement> pPrChildren = <XmlElement>[];

    bool alreadyHasReference = false;

    final Style? directStyle = textStyle?.toStyle();
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

  @override
  Text get copy => Text(
        child,
        id: id,
        textAlign: textAlign,
        parent: parent,
        styles: styles,
        textStyle: textStyle,
      );

  @override
  Text copyWith({
    String? child,
    String? id,
    DocxNode<dynamic>? parent,
    Iterable<Style>? styles,
    TextAlign? textAlign,
    TextStyle? textStyle,
  }) {
    return Text(
      child ?? this.child,
      styles: styles ?? this.styles,
      textAlign: textAlign ?? this.textAlign,
      id: id ?? this.id,
      parent: parent ?? this.parent,
      textStyle: textStyle ?? this.textStyle,
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
