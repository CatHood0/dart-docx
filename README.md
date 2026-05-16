## Dart-DOCX: Easily generate .docx files with Dart

`docx` is a high-level, declarative API for generating Microsoft Word (.docx) documents using Dart.


> [!NOTE]
> * HTML, Markdown, plain text, and Quill Delta, are being planned. At this point, is useless since we're still working on the bidirectional parsing.
> * Incremental editing is partially implemented. But does not work at all points. Stuff like graphics, images and tables are still a difficult part. 
> * Shape effects (e.g., shadows, gradients) are experimental at this points. They're like "magic" stuff that I don't at all what they do.

## Examples

The following documents were generated entirely using the `docx` declarative API.
Each example is available as runnable code under the `demos/` directory.

### Literary document
![](./assets/novel.png)

→ [novel.dart](https://github.com/Flutter-Document-Kit/dart-docx-toolkit/blob/master/demos/novel.dart)

## Curriculum

#### Viewer compatibility
| Editor | Screenshot | Notes |
|--------|------------|-------|
| **Google docs** | ![](./assets/google_docs_curriculum_template.png) | The template used |
| **OnlyOffice** | ![](./assets/curriculum_onlyoffice.png) | Good fidelity with the template |
| **LibreOffice** | ![](./assets/curriculum_libreoffice.png) | Good compatibility, minor spacing differences |
| **Microsoft Word** | ![](./assets/curriculum_word.png) | Good fidelity like OnlyOffice |

→ [cv.dart](https://github.com/Flutter-Document-Kit/dart-docx-toolkit/blob/master/demos/cv.dart)

### Tables
![](./assets/tables.png)

→ [tables.dart](https://github.com/Flutter-Document-Kit/dart-docx-toolkit/blob/master/demos/tables.dart)

### Newspapers (Example) 


| LibreOffice | Word Online |
|-------------|-------------|
| ![](./assets/newspaper_libreoffice.png) | ![](./assets/newspaper_word.png)|
 

→ [newspapers.dart](https://github.com/Flutter-Document-Kit/dart-docx-toolkit/blob/master/demos/newspapers.dart)

### Rows 

| LibreOffice | Word Online |
|-------------|-------------|
| ![](./assets/rows_libreoffice.png) | ![](./assets/rows_word.png) |

→ [rows_alignment.dart](https://github.com/Flutter-Document-Kit/dart-docx-toolkit/blob/master/demos/row_alignments.dart)

### Vector shapes (DrawingML)
![](./assets/heart_shape.png)

→ [heart_shape.dart](https://github.com/Flutter-Document-Kit/dart-docx-toolkit/blob/master/demos/heart_shape.dart)
→ [heart_with_border.dart](https://github.com/Flutter-Document-Kit/dart-docx-toolkit/blob/master/demos/heart_with_border.dart)


## Key Features

*   **Programmatic DOCX Generation:** Create `.docx` files from scratch using an object-based Dart API.
*   **Rich Content Support:** Insert paragraphs, formatted text (bold, italic, etc.), images, numberings, rows, columns, hyperlinks, page breaks, text frames, and tables.
*   **Customizable Styles:** Define and apply custom paragraph and character styles to your content.
*   **Document Properties Management:** Configure metadata such as title, author, subject, and more with no efforts.
*   **Media Handling:** Images can be provided as raw bytes or files; relationships and media packaging are handled automatically.
*   **Stream-Based Generation Events:** Generate documents asynchronously and monitor progress via a `Stream` of events.

## Installation (NOT AVAILABLE YET)

Add `docx` to your `pubspec.yaml` file:

```yaml
dependencies:
  docx: ^latest_version
```

## Basic Usage

### 1. Define the Document Content

Your document content is structured using classes that extend `DocxContent` and `ComponentContainer`. `DocxDocument` is the, and within it you can add `Paragraph`s, `TextRun`s, `Image`s, `HyperlinkRun`s, etc.

Here is an example of how to create a simple document:

```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

Future<void> main() async {
  final DocxDocument document = DocxDocument(
    options: DocumentOptions.standard(
      title: 'My First DOCX Document',
      author: 'me',
      subject: 'example',
    ),
    root: DocumentRoot(
      sections: <DocxNode<dynamic>>[
        Paragraph(
          data: <RunBase>[
            TextRun.text(
              text: 'This is a paragraph with bold text. ',
              styles: <Object>[
                // we can use styles and attributes together
                // to allow referencing complex styles
                Style.ref('code'),
                BoldAttribute(),
              ],
            ),
            HyperlinkRun.pure(
              link: 'https://flutter.dev',
              text: 'Flutter',
              bold: true,
              color: Color(0xFF0563C1),
            ),
            TextRun.text(text: ' and here the paragraph ends.'),
          ],
          // You can have the same effect if you wrap
          // this component with a Align
          alignment: Alignment.left,
          pageBreak: ParagraphPageBreak.none,
        ),
      ],
    ),
  );

  final File file = File('example.docx');
  final Uint8List? bytes = await DocxPacker.instance
      .dynamicFontSearch(true)
      .noTrimRuns()
      .execute(document);
  await file.writeAsBytes(bytes!);
}
```

### 2. Stream-Based Document Generation

For larger document operations or to display progress to the user, you can use `stream` which returns a `Stream<DocxEvent>`:

_Experimental yet_

```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

Future<void> main() async {
  final DocxDocument doc = DocxDocument(
    // ...
  );

  final Uint8List? bytes = await DocxPacker()
      .dynamicFontSearch(true)
      .setNormalIfNeeded(true)
      .noTrimRuns()
      .stream(
        (Stream<DocxEvent> eventStream) {
          final subscription = eventStream.listen((DocxEvent event) {
            switch (event) {
              case DocxEventStart():
                print('Initializating compilation...');
                break;
              
              case DocxEventSearching(:final subject):
                print('Searching: $subject');
                break;
              
              case DocxEventProgress(:final subject, :final current, :final total):
                final progress = ((current / total) * 100).toStringAsFixed(1);
                print('$subject: $current/$total ($progress%)');
                break;
              
              case DocxEventUnknownProgress(:final subject):
                print('⚙️ $subject...');
                break;
              
              case DocxEventEnd(:final result, :final error):
                if (error != null) {
                  print('❌ Error: $error');
                } else {
                  print('✅ Compilation end sucessfully');
                }
                break;
              
              default:
                print('📨 Event: $event');
            }
          });

          subscription.onError((error) {
            print('⚠️ Stream-error: $error');
          });
          
          // El stream will be closed when compilation ends 
       })
      .execute(doc, applyCustomTheme: false);

  if (bytes != null) {
    await File('document.docx').writeAsBytes(bytes);
  }
}
```

### Paragraph 

Paragraphs support rich text formatting including bold, italic, underline, strikethrough, font size, font family, and text color. Multiple formatting styles can be combined within a single paragraph or applied to specific text runs.

#### Example: Paragraph with mixed formatting
```dart
final pr = Paragraph(
  children: [
    TextRun.text(text: 'Normal text '),
    TextRun.text(text: 'bold text', styles: [BoldAttribute()]),
    TextRun.text(text: ' and '),
    TextRun.text(text: 'colored text', styles: [
      StyleBuilder.uc()
          .runColor(Colors.red)
          .build(),
    ]),
    // or
    TextRun.text(text: 'bold text', bold: true),
    TextRun.text(text: ' and '),
    TextRun.text(text: 'colored text', color: Colors.red),
  ],
)
```

Horizontal alignment (left, center, right, justified) and vertical spacing control are fully supported. Spacing can be configured for before/after paragraphs and line spacing within paragraphs with various spacing rules.

#### Example: Centered paragraph with custom spacing
```dart
final pr  = Paragraph.text(
  text: 'Centered Content',
  alignment: Alignment.center,
  styles: [
    StyleBuilder.up()
        .spacing(before: 240, after: 120, line: 360)
        .build(),
  ],
);
// or
final pr2 = Paragraph.text(
  text: 'Centered Content 2',
  alignment: Alignment.center,
  // internally it transform your point units
  // to native twips units
  spacingBefore: 12,      // 240 twips 
  spacingAfter: 6,        // 120 twips 
  lineSpacing: 18,        // 360 twips 
);
```

Paragraph indentation can be controlled for first line, left, right, and hanging indents. This enables complex document layouts including block quotes, nested content, and specialized formatting requirements.

#### Example: Paragraph with first line indent
```dart
final pr = Paragraph.text(
  text: 'Indented paragraph content',
  styles: [
    StyleBuilder.up()
        .indent(firstLine: 720, left: 1440)
        .build(),
  ],
);
// or
final pr2 = Paragraph.text(
  text: 'Indented paragraph content',
  // internally it transform your point units
  // to native twips units
  indentLeft: 0.5,        // 720 twips 
  indentRight: 0.25,      // 360 twips 
  firstLineIndent: 0.5,   // 720 twips
);
```

The system provides control over line breaks, page breaks, and text flow. Paragraphs can be configured to keep lines together or keep with next paragraph, preventing awkward page breaks in document flow.

#### Example: Paragraph with break control
```dart
final pr = Paragraph.text(
  text: 'Important paragraph that should not break',
  styles: [
    StyleBuilder.up()
        .keepLines(true)
        .keepNext(true)
        .build(),
  ],
);
//or
final pr2 = Paragraph.text(
  text: 'Important paragraph that should not break',
  keepLines: true,
  keepNext: true,
);
```

### List and Numberings

You can create list items with configurable numbering styles and levels. `Paragraph` being configured to be an item. By default, this library supports: ordered (numbered) and unordered (bulleted) lists styles with proper indentation and formatting using `NumberingOptions` class.

#### Example: Paragraph as list item
```dart
final pr = Paragraph.text(
  text: 'List item content',
  // It's mandatory injecting this style
  // since it's part of the standard of word
  // (i guess, since if it's not in the
  // styles of the paragraph, list does not
  // work correctly)
  styles: [Style.ref('ListParagraph')],
  numbering: Numbering(
    // Default list style implemented by
    // the docx library
    reference: 'unordered',
    level: 0,
    refId: 1,
  ),
);
```

If you want leave to us all the boring stuff, you can just use:

#### NumberingList

`NumberingList` manage: the references, ids, list styles (it injects the `ListParagraph` style), and indentation levels (uses the `<node>.getAncestorOfExactType<NumberingList>` to get always the exact level where a `NumberingList` is). 

It only support these types: `Paragraph`, `Text`, `TextRun`, `HyperlinkRun` and others `NumberingList` nested. 

_Every time that you define a new `NumberingList`, the count is restarted to "1" (depends on the `NumberingOptions` specified, but you probably already get what I'm trying to say)_

```dart
final list = NumberingList(
  refKey: '<your-list-key>',
  children: [
    Text('First ordered element'),
    Text('Second ordered element'),
    Paragraph.text(text: '3rd ordered element'),
    // inherit constructor allow to the component to know
    // that needs to search into the context to get
    // the most parent NumberingList that contains a defined
    // key to be used
    //
    // Level 2
    NumberingList.inherit(
      children: [
        Text('First nested element'),
        // Level 3
        NumberingList.inheritOne(
          child: Text('Second nested element'),
        ),
      ],
    ),
  ],
);
```

See more about in [Numbering definition](./docs/numbering_internals.md) and an example of this in [Numbering Demo](./demos/numbering.dart)

### Images anchoring

The `docx` library provides flexible options for positioning images within your document. You can control whether an image flows with text like a character, or floats relative to paragraphs, margins, or even the page.

These APIs map directly to `WordprocessingML` concepts, but are exposed through a Dart-first declarative API.

#### Basic Block image 

This is a common usage for most of the editors maded in Flutter}:.

```dart
final Paragraph pr =  LazyFloatingImage(
  data: ImageData.fileSized(
    file: File('assets/image.png'),
    size: 1.5,
    unit: Unit.inch,
    // Configure anchoring relative to the paragraph
    anchorConfig: AnchorConfig(
      wrapType: WrapType.noWrap,
      wrapSide: null,
      verticalAnchor: VerticalAnchorPosition.paragraph,
      horizontalAnchor: HorizontalAnchorPosition.paragraph,
      horizontalPosition: AnchorPosition.left,
      verticalPosition: AnchorPosition.top,  
    ),
  ),
).drawing().paragraph();
```

#### Other examples:

##### 1. Anchoring to a Paragraph (Floating Image)

This is a common way to insert images that can have text wrap around them or be positioned independently of the immediate text flow, but still tied to a specific paragraph. The image is placed within a paragraph and its position is relative to that paragraph.

```dart
// This image will be anchored to the paragraph it is contained within.
// Text can wrap around it (if wrapType is not none).
final paragraph = Paragraph(
  data: [
    TextRun.text(text: 'Here is some text before the image. '),
    LazyFloatingImage(
      data: ImageData.fileSized(
        file: File('assets/image.png'),
        size: 1.5,
        unit: Unit.inch,
        anchorConfig: AnchorConfig(
          wrapType: WrapType.square,
          wrapSide: WrapSide.bothSides,
          horizontalAnchor: HorizontalAnchorPosition.paragraph,
          verticalAnchor: VerticalAnchorPosition.paragraph,
          horizontalPosition: AnchorPosition.center,
          verticalPosition: AnchorPosition.center,
        ),
      ),
    ).drawing().run(),
    TextRun(text: ' And here is some text after the image, demonstrating '
       'wrapping. This is a longer sentence to show how '
       'text flows around the image.',
    ),
  ],
);
```

##### 2. Treating an Image as an Inline Character

When an image should behave exactly like a text character, flowing with the text and not allowing complex wrapping, use `InlineImage`. This is ideal for small icons or images that are part of the textual content itself.

```dart
final paragraph = Paragraph(
  children: [
    TextRun.text(text: 'This is an example of an '),
    LazyImage(
      asInline: true,
      data: ImageData.fileSized(
        file: File('assets/inline_icon.png'),
        size: 0.2,
        unit: Unit.inch,
      ),
    ).drawing().run(),
    TextRun.text(text: ' inline image, flowing with the text.'),
  ],
);
```

##### 3. Anchoring to a Character with Precise Positioning (Floating Image)

For more fine-grained control where the image's anchor point is a specific character, but the image still floats, you can use `FloatingImage` with `RelativeHorizontalAnchor.character`. This allows for exact offsets relative to that character.

```dart
// This image will be anchored to the paragraph it is contained within.
// Text can wrap around it (if wrapType is not none).
final paragraph = Paragraph(
  data: [
    TextRun.text(text: 'This text has an image '),
    LazyFloatingImage(
      data: ImageData.fileSized(
        file: File('assets/image.png'),
        size: 0.85,
        unit: Unit.inch,
        anchorConfig: AnchorConfig(
          wrapType: WrapType.square,
          wrapSide: WrapSide.bothSides,
          // Anchor relative to a character. 
          // This requires careful positioning.
          horizontalAnchor: HorizontalAnchorPosition.character,
          // Anchor to the line of the character
          verticalAnchor: VerticalAnchorPosition.line,
          // Explicit offsets from the anchor point (character).
          // Adjust these values to precisely place the image.
          anchorOffsetX: 0.1.inchesToEmu(), 
          // Move slightly above the line
          anchorOffsetY: -0.2.inchesToEmu(),
        ),
      ),
    ).drawing().run(),
    TextRun(text: ' positioned precisely next to this point.'),
  ],
);
```

### Tables

The table system supports configurable multi-row, multi-column structures with precise dimensional control. Tables can be created with fixed or percentage-based widths, with column definitions in various units (twips, points, inches, centimeters, millimeters). Layout options include fixed column widths and auto-fit behavior where columns adjust to content.

#### Creating a basic 2x2 table with centered alignment and custom widths
```dart
final table = Table(
  tableConfig: TableProperties.auto(alignment: Alignment.center),
  columns: GridColumn.intrinsic().repeat(2),
  rows: <TableRow>[
    TableRow(
      cells: [
        TableCell.one(
          cellConfig: TableCellConfig.auto(),
          child: Paragraph.text(text: 'Header 1'),
        ),
        TableCell.one(
          cellConfig: TableCellConfig.auto(),
          child: Paragraph.text(text: 'Header 2'),
        ),
      ],
    ),
  ],
);
```

Complex table layouts are supported through horizontal (colspan) and vertical (rowspan) cell merging. The system handles both starting and continuing merged cells across multiple rows, enabling sophisticated table designs for data presentation and forms.

#### Example: Creating merged cells with colspan and rowspan
```dart
final cell = TableCell.one(
  cellConfig: TableCellConfig(
    // Spans 2 columns horizontally
    columnSpan: 2, 
    // Spans 3 rows vertically
    rowSpan: 3,
  ),
  child: Paragraph.text(text: 'Merged Area'),
);
```

Tables and individual cells support comprehensive border styling with configurable styles (single, double, dashed, dotted, wavy), thickness (measured in eighths of a point), spacing, and color specifications. Borders can be applied to the entire table or customized per cell side.

#### Example: Table with custom border styling
```dart
final config = TableProperties(
  borders: TableBorders(
    top: TableBorder(style: BorderStyle.double, size: 8, color: Colors.red),
    bottom: TableBorder(style: BorderStyle.dashed, size: 4),
    insideHorizontal: TableBorder(style: BorderStyle.dotted),
  ),
)

// Or use
final config2 = TableProperties(
  borders: TableBorders.symmetric(
    vertical: TableBorder(style: BorderStyle.double, size: 8, color: Colors.red),
    insideHorizontal: TableBorder(style: BorderStyle.dotted),
  ),
);

// Or
final config3 = TableProperties(
  borders: TableBorders.all(
    TableBorder(style: BorderStyle.double, size: 8, color: Colors.red),
  ),
);
```

Individual cells can have customized background colors and shading patterns. The system supports solid fills and various pattern types including diagonal stripes, horizontal stripes, and cross patterns with configurable colors.

#### Example: Cell with background shading
```dart
final cellConfig = TableCellConfig(
  shading: Shading.diagonalCross(fill: Color(0xFFCCCC)),
)
```

Cell content can be vertically aligned to top, center, or bottom positions within the cell boundaries. This is particularly useful for cells with fixed heights or when creating consistently aligned content across rows.

#### Example: Vertically centered cell content
```dart
final cellConfig = TableCellConfig(
  verticalAlignment: VerticalAlignment.center,
  // If the row has not the required height 
  // you wont see the effect of VerticalAligment
  //
  // Sometimes you'll need to specify a width
  //
  // You can use TableHeightRule.atLeast to allow
  // resizing if the cell requires it
  height: 1000,
)
```

`TableRow` supports configurable height with 3 different height rules: 
    - automatic: based on content.
    - at-least: take the height specified, and expands itself just when required. 
    - exact: fixed height regardless of content. 


#### Example: Row with fixed height and page break protection

Rows can be prevented from splitting across page boundaries and can be designated as repeating headers for multi-page tables.

```dart
final row = TableRow(
  heightRule: TableHeightRule.exact,
  height: 1008,
  canSplit: false,
  cells: [/* cell definitions */],
)
```

#### Example: Header Row 

Commonly used to separate header cells from the content of the table

```dart
final row = TableRow.header(
  cells: [/* cell definitions */],
)
```

#### Example: Aligned Row 

`TableRow` only supported: `left`, `center` and `right` alignments, other ones will throw an `Exception`.

_**Note:** if you have an `Align` wrapping your `Table` at some point, `TableRow` will get that alignment and applies it to its content_

```dart
final row = TableRow(
  alignment: Alignment.left, 
  cells: [/* cell definitions */],
)
```


### Row Layout

The `Row` component is a container that groups multiple elements to be rendered in a horizontal layout using tables internally. It provides a declarative API similar to Flutter's Row widget, allowing you to control horizontal and vertical alignment of child elements.

#### MainAxisAlignment Variants

Controls how children are distributed horizontally within the row:

- `MainAxisAlignment.start` - Children aligned to the start (left in LTR). This is the default alignment.
- `MainAxisAlignment.center` - Children centered within the row.
- `MainAxisAlignment.end` - Children aligned to the end (right in LTR).
- `MainAxisAlignment.spaceBetween` - Children distributed with maximum space between them. First and last items are at the edges.

##### Example: Header with Logo and Navigation

```dart
final r = Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: <DocxNode<dynamic>>[
    LazyImage(
      asInline: true,
      data: ImageData.fileSized(
        file: './assets/logo.png',
        unit: Unit.pixels96,
        size: 50,
      ),
    ).drawing().run().paragraph(),
    Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <DocxNode<dynamic>>[
        Paragraph.text(text: 'Home  '),
        Paragraph.text(text: 'About  '),
        Paragraph.text(text: 'Contact'),
      ],
    ),
  ],
);
```

##### Example: Centered Content

```dart
final row = Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: <DocxNode<dynamic>>[
    LazyImage(...).drawing().run().paragraph(),
    Paragraph.text(text: 'Centered Content'),
    LazyImage(...).drawing().run().paragraph(),
  ],
);
```

#### CrossAxisAlignment Variants

Controls vertical positioning when children have different heights:

- `CrossAxisAlignment.start` - Children aligned to the top of the row.
- `CrossAxisAlignment.center` - Children vertically centered within the row.
- `CrossAxisAlignment.end` - Children aligned to the bottom of the row.

##### Example: Vertical Alignment Variants

```dart
final row = Row(
  mainAxisAlignment: MainAxisAlignment.start,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: <DocxNode<dynamic>>[
    LazyImage(...).drawing().run().paragraph(),
    Paragraph.text(
      text: 'This text is vertically centered with the image.',
    ),
  ],
);
```

#### Fixed Width Row

Using fixed width gives precise control over the total row width. Each child gets an equal share:

```dart
final row = Row(
  width: 200.ptToDxa(),
  mainAxisAlignment: MainAxisAlignment.start,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: <DocxNode<dynamic>>[
    Column(children: [Paragraph.text(text: 'Column 1')]),
    Column(children: [Paragraph.text(text: 'Column 2')]),
    Column(children: [Paragraph.text(text: 'Column 3')]),
  ],
);
```

#### Nested Rows

Rows can be nested to create complex layouts like grids or cards with multiple sections:

```dart
final row = Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: <DocxNode<dynamic>>[
    Column(
      children: <DocxNode<dynamic>>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <DocxNode<dynamic>>[
            LazyImage(...).drawing().run().paragraph(),
            Paragraph.text(text: 'Feature 1'),
          ],
        ),
        Paragraph.text(text: 'Description of feature 1.'),
      ],
    ),
    Column(
      children: <DocxNode<dynamic>>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <DocxNode<dynamic>>[
            LazyImage(...).drawing().run().paragraph(),
            Paragraph.text(text: 'Feature 2'),
          ],
        ),
        Paragraph.text(text: 'Description of feature 2.'),
      ],
    ),
  ],
);
```

See more examples in [row.dart](https://github.com/Flutter-Document-Kit/dart-docx-toolkit/blob/master/demos/row.dart) and [row_alignments.dart](https://github.com/Flutter-Document-Kit/dart-docx-toolkit/blob/master/demos/row_alignments.dart).

### Column Layout

The `Column` component is a container that groups multiple elements vertically. It is commonly used in multi-column document layouts, such as newspapers or newsletters.

#### Basic Usage

```dart
final column = Column(
  children: <DocxNode<dynamic>>[
    Paragraph.text(text: 'First paragraph'),
    Paragraph.text(text: 'Second paragraph'),
    Paragraph.text(text: 'Third paragraph'),
  ],
);
```

#### Multi-Column Layouts

Columns are used in page layouts to create newspaper-style multi-column documents. The `ColumnOptions` in `DocumentLayout` defines the number of columns and their widths:

```dart
final DocxDocument doc = DocxDocument(
  options: DocumentOptions.standard(
    section: DocumentLayout(
      size: PageSize.letter,
      columns: ColumnOptions(
        numColumns: 2,
        equalWidth: false,
        columnWidths: <ColumnWidth>[
          ColumnWidth.points(width: 320.0, spaceAfter: 18),
          ColumnWidth.points(width: 170.0, spaceAfter: 0),
        ],
      ),
    ),
    // set the content as expected
    // Word will adapt the layout
    // all for us 
  ),
);
```

See a complete example in [newspaper.dart](https://github.com/Flutter-Document-Kit/dart-docx-toolkit/blob/master/demos/newspaper.dart).

### Text

The `Text` component is a fundamental document unit for organizing text content. It provides a simple way to create text with optional formatting without the need for creating `Paragraph` and `TextRun` objects.

#### Basic Usage

```dart
final text = Text('Simple text content');
```

#### Text Formatting

```dart
final text = Text(
  'Formatted text',
  bold: true,
  italic: true,
  underline: true,
  strikethrough: true,
)
```

#### Font Properties

```dart
final text = Text(
  'Custom font text',
  size: 12,  // In points
  family: 'Arial',
  color: Colors.blue,
  backgroundColor: Colors.yellow,
);
```

#### Special Text Features

Subscript and superscript text are supported:

```dart
final text = Text(
  text: 'x',
  superscript: true,
);

final text2 =Text.text(
  text: 'H2O',
  subscript: true,
);
```

#### Text Alignment

```dart
final text = Text(
  text: 'Centered text',
  textAlign: TextAlign.center,
);
```

#### Text in Row Layouts

The `Text` component works seamlessly with `Row` for simple horizontal layouts:

```dart
final row = Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  minHeight: 5.ptToDxa(),
  children: <DocxNode<dynamic>>[
    Text('Left'),
    Text('Center'),
    Text('Right'),
  ],
)
```

![minimal row](./assets/minimal_row.png)

### Shapes

_Under active development_

## Style Customization

> [!IMPORTANT]
> This section is outdated. I'm working to update this part with the recent API changes.

`docx` provides a flexible system for defining custom Word styles that are reflected in `word/styles.xml`. This is achieved through the `Style` and `StyleConfigurator` classes.

*   **`Style`**: Represents a full paragraph or character style in Word (e.g., "Normal", "Heading1", "Hyperlink").
    *   `type`: `'paragraph'` or `'character'`.
    *   `styleId`: The internal ID used in the Word XML.
    *   `configurators`: A list of `StyleConfigurator`s that define the properties of this style.

*   **`StyleConfigurator`**: Represents an individual XML node within a style definition. You can specify if it's a self-closing tag or if it contains children.
    *   `propertyName`: The XML element name (e.g., `b` for bold, `sz` for font size).
    *   `prefix`: The XML namespace prefix (e.g., `w` for `w:b`).
    *   `value`: The value for the `w:val` attribute if applicable.
    *   `attributes`: A map of other XML attributes.
    *   `isAutoClosure`: `true` for `<w:b/>`, `false` for `<w:pPr>...</w:pPr>`.

### Styles can be easy 

Creating styles can sound difficult, but it becomes straightforward using our `StyleBuilder` class. You just need to specify what you want and call `build` to use it!

```dart
import 'package:docx/docx.dart';

// Build your styles easily using our builder 
final Style customRedCenteredParagraph = StyleBuilder.paragraph('CustomRedCentered')
    .name('Red Centered Paragraph')
    .basedOn('Normal') // Based on common "Normal" style 
    .next('Normal') // Next paragraph must have applied normal paragraph 
    .color(Colors.grey) 
    .fontSize(12.ptToHalfPoints()) // Font size of 12pt
    .bold() 
    .alignment(Alignment.center)
    .spacing(before: 200, after: 200)
    .qFormat(true) // show in the gallery of styles
    .build();

final paragraph = Paragraph.text(
    text: 'This text uses my custom style.',
    styles: <Style>[customRedCenteredParagraph],
);
```

**Optionally**, you can register this `Style` in a `DocumentStylesSheet` to avoid reusing the same instance every time. Just register it and use `Style.reference` constructor to reference the style and let to the component decided how get and build it.

```dart
DocumentStylesSheet myCustomStyles = DocumentStylesSheet.base().withNewStyles(
  <Style>[customRedCenteredParagraph],
);

//Then, in your DocxDocumentSdk:
final DocumentOptions options = DocumentOptions(
  // ...
  styles: myCustomStyles,
);

final paragraph = Paragraph.text(
  text: 'This text uses my custom style.',
  styles: <Style>[Style.reference('CustomRedCentered')],
);
````

### Font Management

> [!IMPORTANT]
> This feature is still **experimental**. We are working to ensure that this works as expected!

Managing fonts is crucial for ensuring your document looks consistent across different systems. `docx` offers a flexible API to define the fonts used in your document. You can either **reference** fonts (expecting them to be installed on the user's system) or **embed** their binary data directly into the `.docx` file (guaranteeing fidelity).

All font definitions are added via the `DocumentOptions.fonts` property, which expects a list of `FontProperties` objects.

> [!WARNING]
> Ensure you have the appropriate license to embed font files.

#### 1. Referencing Fonts (Simple Usage)

Referenced fonts are simply specified by their name. The viewing application (like Microsoft Word) will then attempt to use a font with that name installed on the user's system.

*   **When to use:** For common system fonts (e.g., Arial, Times New Roman, Calibri) where you expect the viewing system to have them. This keeps the document file size smaller.
*   **How to add:** Use the `FontProperties.referenced` factory constructor.

```dart
import 'package:docx/docx.dart';

// Define a font that is expected to be available on the user's system.
// Word will use this name to find a matching font.
final FontProperties arialFont = FontProperties.referenced(
  name: 'Arial',
  family: 'swiss', // Optional: generic family classification (e.g., 'roman', 'swiss', 'script')
  charset: CharacterSet.ansi, // Optional: character set
);

// Example of integrating with DocumentOptions:
// final DocumentOptions options = DocumentOptions(
//   title: 'My Document',
//   fonts: [arialFont], // Add your referenced fonts here
//   // ... other options
// );
```

#### 2. Embedding Fonts (Guaranteed Fidelity)

Embedded fonts include their binary data (e.g., `.ttf` or `.otf` file contents) directly within the `.docx` file. This ensures that your document will render with the exact font you specified, even if the viewing system does not have that font installed.

*   **When to use:** For custom fonts, brand-specific fonts, or any font where visual consistency is paramount. This will increase the `.docx` file size.
*   **How to add:** Use the `FontProperties.embedded` factory constructor. This requires you to provide the font's binary data (`Uint8List`) and its original file extension.

```dart
import 'dart:io'; // For reading font files from disk
import 'package:flutter/services.dart' show rootBundle; // For loading font assets in Flutter
import 'package:docx/docx.dart';

// --- Example: Loading font bytes (choose one method based on your environment) ---

// Option A: Load from a local file path (e.g., for server-side Dart or CLI apps)
Future<Uint8List> _loadFontFromFile(String filePath) async {
  return await File(filePath).readAsBytes();
}

// Option B: Load from Flutter assets (make sure to list font in pubspec.yaml assets section)
Future<Uint8List> _loadFontFromAssets(String assetPath) async {
  return await rootBundle.load(assetPath).then((data) => data.buffer.asUint8List());
}

// --- Then, create the embedded FontProperties instance ---
Future<List<FontProperties>> _getCustomFonts() async {
  // Replace 'test_resources/MyCustomFont.ttf' with your actual font file path or asset path
  final Uint8List customFontBytes = await _loadFontFromFile('test_resources/MyCustomFont.ttf'); 

  final FontProperties myCustomFont = FontProperties.embedded(
    name: 'My Custom Font', // The exact font name as it appears in the font file
    bytes: customFontBytes, // The binary content of your font file
    extension: 'ttf', // The original file extension (e.g., 'ttf', 'otf')
    characterSet: CharacterSet.ansi,
    altName: 'Arial', // Optional: A fallback font name if embedding fails or is not supported
  );

  // You can combine embedded and referenced fonts in the same list:
  final FontProperties verdanaFont = FontProperties.referenced(
    name: 'Verdana',
    family: 'swiss',
  );

  return [myCustomFont, verdanaFont];
}

// --- Finally, pass your list of FontProperties to DocumentOptions ---
// Example in your DocxDocument creation:
// final DocxDocument document = DocxDocument(
//   options: DocumentOptions(
//     title: 'Document with Custom Fonts',
//     fonts: await _getCustomFonts(), // Your list of FontProperties here
//     // ... other options
//   ),
//   sections: [...],
// );
//
// You just need to reference that font family name in your defined styles
```

#### How `docx` Handles Fonts Internally

The `FontStore` (an internal component) automatically manages the complexities:
*   It generates unique IDs and obfuscation keys for embedded font files.
*   It constructs the `word/fontTable.xml` file, which lists all referenced and embedded fonts with their metadata.
*   For embedded fonts, it also creates `word/_rels/fontTable.xml.rels` (a separate relationships file) that links the `fontTable.xml` entries to the actual obfuscated binary font files (`.odttf`).
*   Finally, it adds these obfuscated font binaries to the `.docx` ZIP archive.

This abstraction means you only need to provide the `FontProperties` (and binary data for embedded fonts), and `docx` handles all the underlying WordML specification details.

### Document Settings Configuration

> [!IMPORTANT]
> This feature is still **experimental**. We are working to ensure that this works as expected!

> [!NOTE]
> This section targets advanced use cases and mirrors word/settings.xml closely.
 
Beyond basic document properties like title and author, `DocumentOptions` also allows for fine-grained control over various internal settings of the DOCX file. These are managed through the `settings` property, which accepts a `SettingsOptions` object. This gives you deep customization capabilities for how Word handles footnotes, endnotes, mathematical equations, and general document behaviors.
 
```dart
import 'package:docx/docx.dart';
 
 // Configure specific mathematical properties
final customMathProperties = MathPropertiesOptions(
   mathFont: 'Latin Modern Math',
   breakBinary: BreakBinaryType.after,
   displayLoop: DisplayLoopType.breakValue,
   integerLimit: true,
);
 
 // Configure specific footnote properties
final customFootnoteProperties = NotePropertiesOptions(
   position: NotePosition.beneathText,
   numberFormat: NoteNumberFormat.upperRoman,
   numberStart: 'X',
   numberRestart: NoteNumberRestart.section,
   fieldAugmentation: true,
   layout: NoteLayout.column, // Primarily for footnotes
   additionalNoteIds: ['10'],
);
 
 // Configure specific endnote properties
final customEndnoteProperties = NotePropertiesOptions(
   position: NotePosition.docEnd,
   numberFormat: NoteNumberFormat.decimal,
   numberStart: '5',
   numberRestart: NoteNumberRestart.continuous,
);
 
 // Combine all custom settings
final customDocSettings = SettingsOptions(
   zoomPercent: '120',
   trackRevisions: true,
   defaultTabStop: '1440', // 1 inch
   decimalSymbol: ',',
   mathProperties: customMathProperties,
   footnoteProperties: customFootnoteProperties,
   endnoteProperties: customEndnoteProperties,
   // ... other settings ...
);
 
final DocxDocument document = DocxDocument(
   options: DocumentOptions(
     title: 'Advanced Settings Document',
     author: 'yeah-me',
     settings: customDocSettings,
   ),
   root: DocumentRoot(sections: <DocxNode<dynamic>>[]),
);
 
```
 
#### `SettingsOptions`
 
This class encapsulates various document-wide settings found in the `word/settings.xml` part of a DOCX file. It provides control over general behaviors, compatibility, and references to more specific configuration groups.
 
Key configurable fields include:
 
*   `zoomPercent`: Document view zoom level (e.g., `'100'`).
*   `trackRevisions`: Enables/disables revision tracking (`true`/`false`).
*   `defaultTabStop`: Default tab stop distance in TWIPs (e.g., `'720'` for 0.5 inch).
*   `characterSpacingControl`: How character spacing is handled (e.g., `'doNotCompress'`).
*   `decimalSymbol`: The character used as a decimal separator (e.g., `'.'`).
*   `listSeparator`: The character used as a list separator (e.g., `','`).
*   `themeFontLanguage`, `themeFontLanguageEastAsia`: Default languages for theme fonts.
*   `colorSchemeMapping`: A map defining the document's color scheme.
*   `compatSettings`: A list of `CompatSetting` objects to define document compatibility behaviors.
*   `mathProperties`: An instance of `MathPropertiesOptions` for mathematical equation settings.
*   `footnoteProperties`: An instance of `NotePropertiesOptions` for footnote behaviors.
*   `endnoteProperties`: An instance of `NotePropertiesOptions` for endnote behaviors.
 
#### `MathPropertiesOptions`
 
This class provides options to configure how mathematical equations are rendered and behaved within the document, corresponding to the `m:mathPr` element.
 
Key configurable fields (using enums for constrained values):
 
*   `mathFont`: The default font for mathematical text (e.g., `'Cambria Math'`).
*   `breakBinary` (`BreakBinaryType` enum): How binary operators break across lines (`.before`, `.after`, `.repeat`).
*   `breakBinarySubtraction` (`BreakBinarySubtractionType` enum): How subtraction operators break (`.minusMinus`, `.before`, `.after`).
*   `displayLoop` (`DisplayLoopType` enum): Whether math zones display on a single line or wrap (`.noBreak`, `.breakValue`).
*   `integerLimit`: Enables/disables the math auto-correct integer limit (`true`/`false`).
*   `wrapIndent`: Indent for wrapped math objects in TWIPs.
 
#### `NotePropertiesOptions` (for Footnotes and Endnotes)
 
This flexible class is used to configure properties for both footnotes (`w:footnotePr`) and endnotes (`w:endnotePr`), offering precise control over their appearance and numbering.
 
Key configurable fields (using enums for constrained values):
 
*   `position` (`NotePosition` enum): Where the notes are placed (`.pageBottom`, `.docEnd`, `.beneathText`).
*   `numberFormat` (`NoteNumberFormat` enum): The numbering style (`.decimal`, `.lowerRoman`, `.upperRoman`, etc.).
*   `numberStart`: The initial number or letter for the sequence (as a `String`).
*   `numberRestart` (`NoteNumberRestart` enum): How numbering restarts (`.continuous`, `.section`, `.page`).
*   `fieldAugmentation`: Whether field codes in note references are augmented.
*   `layout` (`NoteLayout` enum): The layout of footnotes (`.column`, `.section`). *Note: Primarily applicable to footnotes.*
*   `additionalNoteIds`: A list of custom IDs for additional note elements (beyond the standard -1 and 0 for separators/continuations).

## Acknowledge

Most of the resources that let us build this library comes from:

* [Office Xml Open](http://officeopenxml.com/WPcontentOverview.php)
* [Ecma-376](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oe376/db9b9b72-b10b-4e7e-844c-09f88c972219)
* [Microsoft Open XML SDK docs](https://learn.microsoft.com/en-us/office/open-xml/open-xml-sdk) 
* [OPC DOCX](https://www.loc.gov/preservation/digital/formats/fdd/fdd000397.shtml)
* [Latent Styles](https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_latentStyles_topic_ID0EFKMT.html)
