import 'dart:math' as math;

import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../../core/extensions/style_to_from_node.dart';
import '../../exceptions/docx_compilation_exception.dart';

/// Fundamental document unit for organizing text content.
///
/// Paragraphs are the primary structural element in DOCX documents,
/// containing one or more text runs and optional formatting properties.
/// They support styling, alignment, numbering (lists), and page breaks.
///
/// Paragraphs can be thought of as analogous to `<p>` tags in HTML.
///
/// ## Direct Styling Properties
///
/// Instead of creating separate [Style] objects with [StyleBuilder], you can use
/// direct properties for common formatting. This simplifies common use cases:
///
/// ### Text Formatting
/// ```dart
/// Paragraph.text(
///   text: 'Formatted text',
///   textStyle: TextStyle(
///     bold: true,
///     italic: true,
///     underline: true,
///     strikethrough: true,
///     smallCaps: true,
///     caps: true,
///   ),
/// );
/// ```
///
/// ### Font Properties
/// ```dart
/// Paragraph.text(
///   text: 'Custom font',
///   textStyle: TextStyle(
///     fontSize: 12,  // In Points units
///     fontFamily: 'Arial',   // Font name
///     fontColor: Color(0xFF0000FF),   // Blue text
///     highlightColor: Color(0xFFFFFF00), // Yellow highlight
///   ),
/// );
/// ```
///
/// ### Spacing & Indentation
/// ```dart
/// Paragraph.text(
///   text: 'Indented text',
///   textStyle: TextStyle(
///     spacingBefore: 12,     // 240 twips
///     spacingAfter: 6,       // 120 twips
///     indentLeft: 0.5,       // 720 twips
///     indentRight: 0.25,     // 360 twips
///     firstLineIndent: 0.5,  // 720 twips
///   ),
/// );
/// ```
///
/// ### Borders & Shading
/// ```dart
/// Paragraph.text(
///   text: 'With border',
///   textStyle: TextStyle(
///     borders: Borders(
///       bottom: Border(
///         style: BorderStyle.single,
///         size: 6,
///         color: Color(0xFF000000),
///       ),
///     ),
///     shadingColor: Color(0xFFFFFFF0),
///     shadingPattern: ShadingPattern.clear,
///   ),
/// );
/// ```
///
/// ### Control Properties
/// ```dart
/// Paragraph.text(
///   text: 'Controlled paragraph',
///   widowControl: const WidowOrphanControl(),
///   keepNext: true,        // Keep with next paragraph
///   keepLines: true,       // Keep all lines together
///   outlineLevel: 0,       // Outline level for TOC
/// );
/// ```
///
/// ## Example usage:
/// ```dart
/// final paragraph = Paragraph(
///   children: [
///     TextRun.text(text: 'First line of text.'),
///     TextRun.text(text: ' Second line.'),
///   ],
///   styles: [Style.reference('Normal')],
///   alignment: Alignment.center,
///   numbering: Numbering(reference: 'bulletList', level: 0),
/// );
/// ```
///
/// See also:
/// - [StyleBuilder] for creating complex styles
/// - [Borders] for paragraph border configuration
/// - [WidowOrphanControl] for widow/orphan line control
//TODO: should we change the name to allow making more similar as Text and Text.rich?
class Paragraph extends DocxNode<List<RunBase>> {
  Paragraph({
    required Iterable<RunBase> children,
    Iterable<Style> styles = const <Style>[],
    this.pageBreak = ParagraphPageBreak.none,
    this.numbering,
    this.alignment,
    this.textStyle,
    super.id,
    super.parent,
  })  : styles = List.from(styles),
        super(child: <RunBase<dynamic>>[...children]) {
    int index = 0;
    for (final RunBase content in children) {
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1
        ..start = length
        ..end = length + content.dataLength;
      length += content.dataLength;
      index++;
    }
  }

  factory Paragraph.text({
    required String text,
    String? id,
    DocxNode? parent,
    Iterable<Style> styles = const <Style>[],
    Iterable<Style> runStyles = const <Style>[],
    ParagraphPageBreak pageBreak = ParagraphPageBreak.none,
    Numbering? numbering,
    Alignment? align,
    TextStyle? textStyle,
  }) {
    assert(
        text.contains('\n'), 'text property cannot contains new lines (\\n)');
    return Paragraph(
      id: id,
      parent: parent,
      styles: styles,
      numbering: numbering,
      alignment: align,
      pageBreak: pageBreak,
      textStyle: textStyle,
      children: <RunBase<dynamic>>[
        TextRun.text(
          text: text,
          styles: List.from(runStyles),
        ),
      ],
    );
  }

  factory Paragraph.empty() => Paragraph(
        children: <RunBase<dynamic>>[],
      );

  factory Paragraph.run(
    DocxNode node, {
    Iterable<Style> styles = const <Style>[],
    ParagraphPageBreak pageBreak = ParagraphPageBreak.none,
    Numbering? numbering,
    Alignment? align,
    String? id,
    DocxNode? parent,
    TextStyle? textStyle,
  }) =>
      Paragraph(
        id: id,
        parent: parent,
        styles: styles,
        numbering: numbering,
        alignment: align,
        pageBreak: pageBreak,
        textStyle: textStyle,
        children: <RunBase<dynamic>>[
          Run(
            component: node,
            wrapInRunMark: true,
          ),
        ],
      );

  /// All the styles applied to the paragraph
  List<Style> styles;
  Numbering? numbering;

  ParagraphPageBreak pageBreak;
  Alignment? alignment;
  TextStyle? textStyle;

  void setAlign(Alignment? align) {
    final temp = copy;
    alignment = align;
    didChangeConfigurations(temp, this);
  }

  void setPageBreak(ParagraphPageBreak pageBreak) {
    final temp = copy;
    this.pageBreak = pageBreak;
    didChangeConfigurations(temp, this);
  }

  void setStyle(Style style) {
    final Paragraph temp = copy;

    if (style.isReference) {
      final int refIndex = styles.indexWhere((e) => e.isReference);
      if (refIndex != -1) {
        styles[refIndex] = style;
      } else {
        styles.insert(0, style);
      }
      didChangeConfigurations(temp, this);
      return;
    }

    styles.add(style);
    didChangeConfigurations(temp, this);
  }

  void setTextStyle(TextStyle style) {
    final Paragraph temp = copy;

    textStyle = style;
    didChangeConfigurations(temp, this);
  }

  @override
  List<XmlElement> buildXml() {
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

    final List<RunBase> elements = List.from(child);

    if (elements.isEmpty) {
      elements.add(TextRun.empty());
    }

    for (final RunBase e in elements) {
      if (e.shouldIgnore() || e.isEmptyNode()) {
        continue;
      }
      final List<XmlNode> element = e.buildXml();
      paragraphChildren.addAll(element);
    }

    if (pageBreak == ParagraphPageBreak.after) {
      paragraphChildren.addAll(Run.pageBreak().buildXml());
    }

    return <XmlElement>[
      XmlElement.tag(
        xmlParagraphNode,
        attributes: <XmlAttribute>[],
        children: paragraphChildren,
        isSelfClosing: false,
      )
    ];
  }

  @override
  List<XmlElement> buildXmlStyle() {
    final List<XmlElement> pPrChildren = <XmlElement>[];

    final CompilerConfigProvider? configs = CompilerConfigProvider.of(this);
    if (DocxElements.instance.initializeByCompile && configs == null) {
      throw DocxCompilationException(
        message: 'Not found required CompilerConfigProvider '
            'build of styles in $runtimeType:$id => ${parent != null ? 'Parent defined' : '$parent'}',
        node: this,
        cause:
            'Not found required provider in tree ${parent == null ? 'with no parent definition' : ''}',
      );
    }
    if (numbering != null && isChildOf<NumberingStoreProvider>()) {
      if (numbering!.level > 9) {
        throw DocxCompilationException(
          message: 'Level cannot be greater than 9. Read more here: '
              'https://answers.microsoft.com/en-us/msoffice/forum/'
              'all/does-word-support-more-than-9-list-levels/'
              'd130fdcd-1781-446d-8c84-c6c79124e4d7',
          node: this,
          cause: 'Unsupported level "${numbering!.level}"',
        );
      }
      final NumberingStore provider = NumberingStoreProvider.of(this);
      bool isChildOfNumberingList = isChildOf<NumberingList>();
      if (!isChildOfNumberingList) {
        CompilerLogger.root.info(
          'Not found parent of type NumberingList '
          'manual check being executed',
        );
        final bool hasConcreteId =
            provider.hasConcreteInstance(numbering!.concreteRef, id);
        if (!hasConcreteId) {
          CompilerLogger.root.debug(
            'Registering concrete instance for '
            '$runtimeType:$id => ${numbering!.concreteRef}-$id',
          );
          provider.registerConcreteInstance(
            numbering!.reference,
            numbering!.refId ?? 0,
            nodeId: id,
          );
        }
      }
      final int concreteId = provider.getConcreteNumId(
        numbering!.concreteRef,
        nodeId: isChildOfNumberingList
            ? getAncestorOfExactType<NumberingList>((
                NumberingList l,
              ) =>
                    !l.inheritFromParent)!
                .id
            : id,
      )!;
      CompilerLogger.root.info(
        'Getting concrete id reference for $runtimeType:$id '
        '"${numbering!.reference}" ($concreteId)',
      );
      pPrChildren.add(numbering!.build(concreteId));
    }

    bool alreadyHasReference = false;

    if (configs?.checkStyleRefExistence == true &&
        textStyle?.headingLevel != null) {
      final Style? header = configs!.options.docStyles
          .getStyleById('Heading${textStyle?.headingLevel!}');
      if (header != null && !header.isInvalid) {
        alreadyHasReference = true;
        pPrChildren.addAll(header.forParagraphStyle(
          shouldShowStyleRef: true,
          useConfigurators: false,
        ));
      } else {
        CompilerLogger.root.warning(
          'Not found heading '
          'level style for ${textStyle?.headingLevel}. '
          'Heading will be ignored for '
          '$runtimeType:$id at $index with deep tree level $depth, '
          'child of ${parent?.runtimeType}',
        );
      }
    }

    // Build style from direct properties
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
    final Map<String, Style> appliedStyles = <String, Style>{};

    if (styles.isEmpty && configs?.normalStyleIfNeeded == true) {
      assert(
        configs == null || configs.normalStyle.isReference,
        'defaultNormalStyle in DocumentContext is '
        'not a reference. Please, ensure you are '
        'setting a reference style',
      );
      Style? st = configs?.normalStyle;
      if (alreadyHasReference) {
        final Style? normal = configs!.options.docStyles
            .getStyleById(configs.normalStyle.styleId);
        if (normal != null && !normal.isInvalid) {
          st = normal;
        } else {
          st = null;
          CompilerLogger.root.warning(
            'Not found style "${configs.normalStyle.styleId}". '
            'It will be ignored for '
            '$runtimeType:$id at $depth with deep tree level $depth, '
            'child of ${parent?.runtimeType}',
          );
        }
      }

      return <XmlElement>[
        ...?st?.forParagraphStyle(),
        ...pPrChildren,
      ];
    }

    // TODO: we need to create a part here to merge when we
    // have two or more references, to allow using both
    // without losing stuff like the styles of one or two styles

    for (final Style style in styles) {
      if (style.isInvalid || appliedStyles.containsKey(style.styleId)) {
        CompilerLogger.root.warning(
          'Skipping invalid or '
          'already applied style in $runtimeType:$id',
        );
        continue;
      }
      Style? st = style;
      // Resolve references
      if (alreadyHasReference && st.isReference) {
        final Style? stemp =
            configs!.options.docStyles.getStyleById(style.styleId);
        if (stemp != null && !stemp.isInvalid) {
          st = stemp;
          CompilerLogger.root.warning('Found style "${style.styleId}". '
              'Reference style provided will be replaced with '
              'its defined version in styles.xml to avoid conflitcts '
              '$runtimeType:$id at $index');
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
        shouldShowStyleRef: alreadyHasReference ? false : st.isReference,
        useConfigurators: !st.isReference,
      );
      // Set always the style ref at first index
      if (st.isReference) {
        CompilerLogger.root.warning(
          'Moving reference "${style.styleId}" to '
          '0 position for $runtimeType:$id',
        );
        pPrChildren.insertAll(0, xml);
        continue;
      }
      pPrChildren.addAll(xml);
    }
    return <XmlElement>[...pPrChildren];
  }

  /// Builds a Style from direct paragraph properties.
  ///
  /// This allows applying formatting directly without requiring StyleBuilder.
  Style? _buildDirectStyle() {
    final StyleBuilder builder = StyleBuilder.up();
    if (pageBreak != ParagraphPageBreak.none) builder.pageBreakBefore();
    if (alignment != null) builder.alignment(alignment!);

    if (isChildOf<Align>() && alignment == null) {
      final Alignment al = getAncestorOfExactType<Align>()!.alignment;
      CompilerLogger.root.debug(
          'Replace current align $alignment to found ancestor ${al.name}');
      builder.alignment(al);
    }

    if (textStyle != null) {
      return textStyle!.toStyle()!
        ..addAll(
          builder.build().configurators,
        );
    }

    return builder.build();
  }

  @override
  Paragraph get copy => Paragraph(
        id: id,
        children: child,
        alignment: alignment,
        pageBreak: pageBreak,
        numbering: numbering,
        styles: styles,
        textStyle: textStyle,
        parent: parent,
      );

  @override
  Paragraph copyWith({
    String? id,
    DocxNode? parent,
    Iterable<RunBase>? children,
    Iterable<Style>? styles,
    Numbering? numbering,
    ParagraphPageBreak? pageBreak,
    Alignment? alignment,
    TextStyle? textStyle,
  }) {
    return Paragraph(
      id: id ?? this.id,
      children: children ?? child,
      styles: styles ?? this.styles,
      alignment: alignment ?? this.alignment,
      pageBreak: pageBreak ?? this.pageBreak,
      numbering: numbering ?? this.numbering,
      textStyle: textStyle ?? this.textStyle,
      parent: parent ?? this.parent,
    );
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    if (shouldGetElement(this)) return this;
    for (final RunBase<dynamic> element in child) {
      if (!visitChildrenIfNeeded && shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final DocxNode? foundedEl = element.visitElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          return foundedEl;
        }
      }
    }
    return null;
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return toList();
    if (child.isEmpty) return <RunBase>[];
    final List<DocxNode> elements = <DocxNode>[];
    for (final RunBase element in child) {
      if (!visitChildrenIfNeeded && shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<DocxNode>? foundedEl = element.visitAllElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          elements.addAll(foundedEl);
        }
      }
    }
    return elements;
  }

  void addRun(RunBase run) {
    addRunAt(child.length, run);
  }

  void addRunFirst(RunBase run) {
    addRunAt(0, run);
  }

  void addRunAt(int index, RunBase run) {
    final Paragraph prev = copy;
    if (run.mounted || run.parent != this) {
      run.deactivate();
    }
    run
      ..parent = this
      ..index = index;

    if (index < child.length) {
      int insertStart;
      if (index == 0) {
        insertStart = 0;
      } else {
        insertStart = child[index - 1].end;
      }

      run
        ..start = insertStart
        ..end = insertStart + run.dataLength;

      int offset = run.dataLength;
      for (int i = index; i < child.length; i++) {
        child[i]
          ..start += offset
          ..end += offset;
      }

      child.insert(index, run);
      length += run.dataLength;
    } else {
      int insertStart = length;
      run
        ..start = insertStart
        ..end = insertStart + run.dataLength;
      child.insert(index, run);
      length += run.dataLength;
    }
    didChangeConfigurations(prev, this);
  }

  @override
  void addAll(List<DocxNode<dynamic>> components) {
    final Paragraph prev = copy;
    for (final DocxNode<dynamic> v in components) {
      if (v is RunBase) {
        v
          ..parent = this
          ..index = child.length
          ..start = length
          ..end = length + v.length;
        child.add(v);
        length += v.length;
        continue;
      }

      child.add(
        Run(component: v)
          ..parent = this
          ..index = child.length
          ..start = length
          ..end = length + 1,
      );
      length += v.length;
    }
    didChangeConfigurations(prev, this);
  }

  @override
  void insertText(
    String text, {
    int? offset,
    int? path,
    List<Object>? styles,
    bool mergeStyles = true,
  }) {
    offset ??= 0;
    if (path != null) {
      return;
    }

    final Paragraph prev = copy;

    final (int index, int remaining) = getIndexByOffset(offset);
    if (index == -1) {
      addRun(
        TextRun.text(
          text: text,
          styles: styles?.cast() ?? <Style>[],
        ),
      );
      return;
    }

    final RunBase<dynamic> run = child.elementAt(index);

    if (run is Run && (run.child is! TextRun && run.child is! HyperlinkRun)) {
      addRun(
        TextRun.text(
          text: text,
          styles: styles?.cast() ?? <Style>[],
        ),
      );
      return;
    }

    final DocxNode<dynamic> childData = run is Run ? run.child : run;
    final int local = math.min(childData.length, remaining);

    final int oldLength = length;

    if (childData is TextRun) {
      childData.insertText(
        text,
        offset: local,
        styles: styles,
        mergeStyles: true,
      );
      length = oldLength + text.length;
    } else if (childData is HyperlinkRun) {
      childData.insertText(
        text,
        offset: local,
        styles: styles,
        mergeStyles: true,
      );
      length = oldLength + text.length;
    }

    didChangeConfigurations(prev, this);
  }

  (int, int) getIndexByOffset(int offset, {int startOffset = 0}) {
    int accumulatedOffset = startOffset;

    final int index = child.indexWhere((RunBase<dynamic> e) {
      if ((accumulatedOffset + e.length) > offset) {
        return true;
      }
      accumulatedOffset += e.length;
      return false;
    });

    return (index, accumulatedOffset);
  }

  /// Returns a new Paragraph with the runs that matches with
  /// the positions specified
  Paragraph cut(int offset, int offsetEnd) {
    final (int index, int local) = getIndexByOffset(offset);
    if (index == -1) return Paragraph.empty();

    int remaining = offsetEnd - offset;
    int startOffset = offset - local;
    final List<RunBase> runs = <RunBase<dynamic>>[];

    for (int i = index; i < child.length; i++) {
      if (remaining <= 0) {
        break;
      }

      final (
        RunBase<dynamic> left,
        RunBase<dynamic> center,
        RunBase<dynamic> right
      ) = child[i].copy.cast<RunBase>().cutAll(startOffset, remaining);

      if (!center.isEmptyData && center.length > 0) {
        runs.add(center);
      }

      remaining -= center.length;
      startOffset = 0;
    }

    return Paragraph(children: runs, styles: styles.toList());
  }

  /// Delete all the text within the specified positions
  /// and returns a new Paragraph with the remaining runs
  Paragraph deleteRange(int offset, int offsetEnd) {
    final (int index, int local) = getIndexByOffset(offset);
    if (index == -1) return Paragraph.empty();

    int remaining = offsetEnd - offset;
    int startOffset = offset - local;
    final List<RunBase> runs = <RunBase<dynamic>>[];

    if (index > 0) {
      runs.addAll(child.sublist(0, index));
    }

    for (int i = index; i < child.length; i++) {
      if (remaining <= 0) {
        runs.addAll(child.sublist(i));
        break;
      }

      final (
        RunBase<dynamic> left,
        RunBase<dynamic> center,
        RunBase<dynamic> right
      ) = child[i].copy.cast<RunBase>().cutAll(startOffset, remaining);

      if (!left.isEmptyData && left.length > 0) {
        runs.add(left);
      }
      if (!right.isEmptyData && right.length > 0) {
        runs.add(right);
      }

      remaining -= center.length;
      startOffset = 0;
    }

    return Paragraph(children: runs, styles: styles.toList());
  }

  @override
  void removeById(String id, {List<int> path = const <int>[]}) {
    final prev = copy;

    final int index = child.indexWhere((e) => e.id == id);

    if (index == -1) return;
    final RunBase<dynamic> removed = child.removeAt(index)..deactivate();
    final int removedLength = removed.length;

    length -= removedLength;

    for (int i = index; i < child.length; i++) {
      child[i].index = i;
      child[i].start -= removedLength;
      child[i].end -= removedLength;
    }

    didChangeConfigurations(prev, this);
  }

  @override
  void remove(DocxNode element, {List<int> path = const <int>[]}) {
    if ((element.mounted && element.parent != this) || element is! RunBase) {
      return;
    }
    final Paragraph prev = copy;

    final RunBase<dynamic> prevElement = child[element.index];

    if (prevElement.id != element.id) {
      CompilerLogger.root.debug(
        'Ignoring remove by not matching '
        'id: prev=${prevElement.id}, target=${element.id}',
      );
      return;
    }
    final int removedLength = prevElement.length;

    child.removeAt(element.index).deactivate();
    length -= removedLength;

    for (int i = element.index; i < child.length; i++) {
      child[i].index = i;
      child[i].start -= removedLength;
      child[i].end -= removedLength;
    }

    didChangeConfigurations(prev, this);
  }

  @override
  void updateElement(DocxNode component, {int? index, bool strict = true}) {
    if (component is! RunBase) return;

    final int i = index ??
        child.indexWhere((RunBase<dynamic> el) => component.id == el.id);
    if (i <= -1) {
      CompilerLogger.root.warning(
        'Tried to updated an '
        'element using: $component, '
        'but there is no match for it',
      );
      return;
    }

    final RunBase<dynamic> element = child[i];
    if (strict &&
        (component.child.runtimeType != element.child.runtimeType ||
            component.id != element.id)) {
      CompilerLogger.root.warning(
        'Tried to updated an '
        'element using: $component, '
        'but strict mode found that there is no match for it',
      );
      return;
    }

    final int oldLength = element.length;

    element.deactivate();

    length -= oldLength;

    CompilerLogger.root.debug(
      'Replaced | $element | '
      'state using | $component | '
      'state at: $i in $runtimeType class type',
    );

    final RunBase newRun = component.copy.cast<RunBase>();
    final int newLength = newRun.length;

    length += newLength;

    newRun
      ..start = element.start
      ..end = element.start + newLength
      ..index = i
      ..parent = this;

    child[i] = newRun;

    if (oldLength != newLength) {
      final int delta = newLength - oldLength;
      for (int j = i + 1; j < child.length; j++) {
        child[j]
          ..start += delta
          ..end += delta;
      }
    }

    if (newRun.mounted) {
      newRun
        ..markAsDirty()
        ..init();
    }
  }
}

/// Controls page break behavior for paragraphs.
enum ParagraphPageBreak {
  /// Insert page break after this paragraph.
  after,

  /// Insert page break before this paragraph.
  before,

  /// No page break (default).
  none,
}
