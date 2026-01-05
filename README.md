## Dart-DOCX: Easily generate .docx files with Dart

`dart-docx` s a high-level, declarative API for generating Microsoft Word (.docx) documents using Dart.

Planned parsers include HTML, Markdown, plain text, and Quill Delta, enabling structured transformations between common content formats and Word documents.

> [!WARNING]
> * Additional format parsers: planned
> * Incremental editing: planned / experimental

## Key Features

*   **Programmatic DOCX Generation:** Create `.docx` files from scratch using an object-based Dart API.
*   **Rich Content Support:** Insert paragraphs, formatted text (bold, italic, etc.), images, hyperlinks, page breaks, text frames, and tables.
*   **Customizable Styles:** Define and apply custom paragraph and character styles to your content.
*   **Document Properties Management:** Configure metadata such as title, author, subject, and more with no efforts.
*   **Media Handling:** Images can be provided as raw bytes or files; relationships and media packaging are handled automatically.
*   **Stream-Based Generation Events:** Generate documents asynchronously and monitor progress via a `Stream` of events.

## Installation

Add `docx` to your `pubspec.yaml` file:

```yaml
dependencies:
  docx: ^latest_version
```


## Basic Usage

### 1. Define the Document Content

Your document content is structured using classes that extend `DocxContent` and `ComponentContainer`. `DocxDocument` is the, and within it you can add `Paragraph`s, `TextRun`s, `Image`s, `HyperlinkRun`s, etc.

Here is an example of how to create a simple document with a paragraph and an image:

```dart
import 'dart:io';
import 'package:docx/docx.dart';

Future<void> main() async {
  final DocxDocument document = DocxDocument(
    options: DocumentOptions(
        title: 'My First DOCX Document',
        author: 'CodeCompanion',
        subject: 'docx_transformer example',
        // you can configure the 
        // columns in the document
        // section: SectionOptions(
        //   columns: ColumnSettings(),
        // ),
    ),
    sections: <DocxContent<dynamic>>[
      Paragraph(
        data: <RunBase>[ 
            TextRun(
              data: TextPart(
                text: 'This is a paragraph with bold text. ',
                styles: [
                  // we can use styles and attributes together
                  // if we want
                  Style.reference('code'), 
                  BoldAttribute(),
                ],
              ),
            ),
            HyperlinkRun(
              data: HyperlinkTextPart(
                hyperlink: 'https://github.com/your-user/your-repo',
                text: 'Visit my GitHub repository',
                style: <Style>[
                  Style.reference('Hyperlink')
                ],
              ),
            ),
            TextRun(
              data: TextPart(text: ' and here the paragraph ends.'),
            ),
        ],
        styles: <Style>[], 
        // decides where break the page
        pageBreak: ParagraphPageBreak.none,
      ),
      Paragraph(
        data: <RunBase>[
          TextRun(
            data: TextPart(text: 'Here is a line break.'),
          ),
        ],
      ),
      // loads and shows the image: 
      // * if it exists 
      // * if it can be used
      Paragraph(
        data: <RunBase<dynamic>>[
          Run(
            component: Drawing(
              data: LazyFloatingImage(
                data: ImageData(
                  buffer: File('test_resources/image.jpg'),
                  extension: 'jpg',
                  anchorConfig: AnchorConfig.block().copyWith(
                    horizontalAnchor: RelativeHorizontalAnchor.paragraph,
                    horizontalAlign: RelativeHorizontalAlign.left,
                    verticalAnchor: RelativeVerticalAnchor.paragraph,
                    verticalAlign: RelativeVerticalAlign.top,
                  ),
                  width: 0.5.toEmuFromInches(),
                  height: 0.55.toEmuFromInches(),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  final File file = File('generated_document.docx');
  final bytes = await DocxMetadataPacker.instance
      // to allow registering fonts used in the
      // runs that user pass, set this to true
      .dynamicFontSearch(true)
      .bytes(documentContent);
  await file.writeAsBytes(bytes!);

  print('DOCX document generated at: $outputPath');
}
```

### 2. Stream-Based Document Generation

For larger document operations or to display progress to the user, you can use `stream` which returns a `Stream<DocxEvent>`:

_Under active development_

<!-- ````dart -->
<!-- import 'dart:io'; -->
<!-- import 'package:docx/docx.dart'; -->
<!---->
<!-- Future<void> generateDocumentWithStream() async { -->
<!--   final DocumentOptions options = -->
<!--       DocumentOptions.blank(title: 'Stream Document'); -->
<!--     final DocxDocument document =   -->
<!--     contents: [ -->
<!--       Paragraph(data: [TextRun(data: TextPart(text: 'Test content.'))]) -->
<!--     ], -->
<!--   ); -->
<!---->
<!--   final DocxDocumentSdk docxSdk = DocxDocumentSdk(options: options); -->
<!--   final String outputPath = 'stream_document.docx'; -->
<!---->
<!--   await for (final event in docxSdk.createDocumentStream( -->
<!--     documentContent, -->
<!--     supportedFileExtensions: {'png'}, -->
<!--   )) { -->
<!--     if (event is StartEvent) { -->
<!--       print('Starting document generation...'); -->
<!--     } -->
<!--     if (event is ProgressEvent) { -->
<!--       print('Progress: ${event.current}/${event.total} - ${event.subject}'); -->
<!--     } -->
<!--     if (event is SearchingEvent) { -->
<!--       print(event.subject); -->
<!--     } -->
<!--     if (event is EndEvent) { -->
<!--       if (event.error != null) { -->
<!--         print('Error generating document: ${event.error}'); -->
<!--       } else { -->
<!--         print('Document generated successfully.'); -->
<!--         // You can save the Uint8List if needed -->
<!--         final Uint8List? bytes = Uint8List.fromList(event.result!); -->
<!--         if (bytes != null) { -->
<!--           await File(outputPath).writeAsBytes(bytes); -->
<!--           print('Document saved at: $outputPath'); -->
<!--         } -->
<!--       } -->
<!--     } -->
<!-- } -->
<!-- ```` -->

### Shapes

_Under active development_

### Images anchoring

The `docx` library provides flexible options for positioning images within your document. You can control whether an image flows with text like a character, or floats relative to paragraphs, margins, or even the page.

These APIs map directly to WordprocessingML concepts, but are exposed through a Dart-first declarative API.”

#### Basic Block image 

This is a common usage for most of the editors maded in Flutter}:.

````dart
final paragraph = Paragraph(
  data: [
    Run(
      // to follow Word standards, we need to wrap
      // shapes or images with Drawing component
      component: Drawing( 
        // there is also its own Lazy version
        data: FloatingImage(
          data: ImageData(
            buffer: await File('assets/image.png').readAsBytes(),
            extension: 'png',
            // Configure anchoring relative to the paragraph
            anchorConfig: AnchorConfig(
              wrapType: WrapType.none,
              wrapSide: null,
              verticalAnchor: RelativeVerticalAnchor.paragraph,
              horizontalAnchor: RelativeHorizontalAnchor.paragraph,
              horizontalAlign: RelativeHorizontalAlign.left,
              verticalAlign: RelativeVerticalAlign.top,
            ),
            width: 1.5.toEmuFromInches(),
            height: 1.5.toEmuFromInches(),
          ),
        ),
      ),
    ),
  ],
);
````

#### Other examples:

##### 1. Anchoring to a Paragraph (Floating Image)

This is a common way to insert images that can have text wrap around them or be positioned independently of the immediate text flow, but still tied to a specific paragraph. The image is placed within a paragraph and its position is relative to that paragraph.

````dart
// This image will be anchored to the paragraph it is contained within.
// Text can wrap around it (if wrapType is not none).
final paragraph = Paragraph(
  data: [
    TextRun(
      data: TextPart(text: 'Here is some text before the image. '),
    ),
    Run(
      // to follow Word standards, we need to wrap
      // shapes or images with Drawing component
      component: Drawing( 
        data: FloatingImage(
          data: ImageData(
            buffer: await File('assets/image.png').readAsBytes(),
            extension: 'png',
            // Configure anchoring relative to the paragraph
            anchorConfig: AnchorConfig(
              wrapType: WrapType.square,
              wrapSide: WrapSide.bothSides,
              horizontalAnchor: RelativeHorizontalAnchor.paragraph,
              horizontalAlign: RelativeHorizontalAlign.center,
              verticalAnchor: RelativeVerticalAnchor.paragraph,
              verticalAlign: RelativeVerticalAlign.center,
              // You can also specify exact offsets if needed
              // offsetX: 0.5.toEmuFromInches(), 
              // offsetY: 0.5.toEmuFromInches(),
            ),
            width: 1.5.toEmuFromInches(),
            height: 1.5.toEmuFromInches(),
          ),
        ),
      ),
    ),
    TextRun(
      data: TextPart(text: ' And here is some text after the image, demonstrating wrapping. This is a longer sentence to show how text flows around the image.'),
    ),
  ],
);
````

##### 2. Treating an Image as an Inline Character

When an image should behave exactly like a text character, flowing with the text and not allowing complex wrapping, use `InlineImage`. This is ideal for small icons or images that are part of the textual content itself.

```dart
final paragraph = Paragraph(
  data: [
    TextRun(
      data: TextPart(text: 'This is an example of an '),
    ),
    Run(
      // to follow Word standards, we need to wrap
      // shapes or images with Drawing component
      component: Drawing(
        data: LazyImage(
          data: ImageData(
            buffer: File(
              'assets/inline_icon.png'),
            extension: 'png',
            width: 0.2.toEmuFromInches(),
            height: 0.2.toEmuFromInches(),
          ),
          asInline: true,
        ),
      ),
    ),
    TextRun(
      data: TextPart(text: ' inline image, flowing with the text.'),
    ),
  ],
);
```

##### 3. Anchoring to a Character with Precise Positioning (Floating Image)

For more fine-grained control where the image's anchor point is a specific character, but the image still floats, you can use `FloatingImage` with `RelativeHorizontalAnchor.character`. This allows for exact offsets relative to that character.

```dart
final paragraph = Paragraph(
  data: [
    TextRun(
      data: TextPart(text: 'This text has an image '),
    ),
    Run(
      // to follow Word standards, we need to wrap
      // shapes or images with Drawing component
      component: Drawing( 
        data: FloatingImage(
          data: ImageData(
            buffer: await File('assets/logo.png').readAsBytes(),
            extension: 'png',
            anchorConfig: AnchorConfig(
              wrapType: WrapType.square,
              wrapSide: WrapSide.bothSides,
              // Anchor relative to a character. 
              // This requires careful positioning.
              horizontalAnchor: RelativeHorizontalAnchor.character,
              // Anchor to the line of the character
              verticalAnchor: RelativeVerticalAnchor.line,
              // Explicit offsets from the anchor point (character).
              // Adjust these values to precisely place the image.
              anchorOffsetX: 0.1.toEmuFromInches(), 
              // Move slightly above the line
              anchorOffsetY: -0.2.toEmuFromInches(),
            ),
            width: 0.75.toEmuFromInches(),
            height: 0.75.toEmuFromInches(),
          ),
        ),
      ),
    ),
    TextRun(
      data: TextPart(text: ' positioned precisely next to this point.'),
    ),
  ],
);
```

### Font Management

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
//   sections: [
//     // ... document content using these font names in styles ...
//     Paragraph(
//       data: [
//         TextRun(
//           data: TextPart(
//             text: 'This text uses the embedded My Custom Font.',
//             styles: [
//               StyleBuilder.character('myCustomFontStyle')
//                   .fontFamily('My Custom Font') // Reference the font by its name
//                   .fontSize(14)
//                   .build(),
//             ],
//           ),
//         ),
//       ],
//     ),
//     Paragraph(
//       data: [
//         TextRun(
//           data: TextPart(
//             text: 'This text uses the referenced Verdana font.',
//             styles: [
//               StyleBuilder.character('verdanaStyle')
//                   .fontFamily('Verdana')
//                   .fontSize(12)
//                   .build(),
//             ],
//           ),
//         ),
//       ],
//     ),
//   ],
// );
```

#### How `docx` Handles Fonts Internally

The `FontStore` (an internal component) automatically manages the complexities:
*   It generates unique IDs and obfuscation keys for embedded font files.
*   It constructs the `word/fontTable.xml` file, which lists all referenced and embedded fonts with their metadata.
*   For embedded fonts, it also creates `word/_rels/fontTable.xml.rels` (a separate relationships file) that links the `fontTable.xml` entries to the actual obfuscated binary font files (`.odttf`).
*   Finally, it adds these obfuscated font binaries to the `.docx` ZIP archive.

This abstraction means you only need to provide the `FontProperties` (and binary data for embedded fonts), and `docx` handles all the underlying WordML specification details.

## Style Customization

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
    .color('FF0000') // Red 
    .fontSize(12) // Font size of 12pt
    .bold() 
    .alignment(Alignment.center)
    .spacing(before: 200, after: 200)
    .qFormat(true) // show in the gallery of styles
    .build();

final paragraph = Paragraph(
    data: <RunBase<dynamic>>[
      TextRun(
        data: TextPart(text: 'This text uses my custom style.'),
      ),
    ],
    styles: <Style>[customRedCenteredParagraph],
  ),
),
```

**Optionally**, you can register this `Style` in a `DocumentStylesSheet` to avoid reusing the same instance every time. Just register it and use `Style.reference` constructor to reference the style and let to the component decided how get and build it.

```dart
DocumentStylesSheet myCustomStyles = DocumentStylesSheet(
  styles: [
    // Optional: keep default styles
    ...DefaultDocumentStyles.kDefaultDocumentStyleSheet.styles,
    customRedCenteredParagraph,
  ],
);

//Then, in your DocxDocumentSdk:
final DocumentOptions options = DocumentOptions(
  // ...
  styles: myCustomStyles,
);

final paragraph = Paragraph(
  styles: <Style>[Style.reference('CustomRedCentered')],
  data: <RunBase<dynamic>>[
      TextRun(
        data: TextPart(text: 'This text uses my custom style.'),
      ),
    ],
  ),
),
````

### Document Settings Configuration

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
   root: DocumentRoot(sections: <DocxTreeNode<dynamic>>[]),
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

## References

Most of the resources that let us build this library comes from:

[Office Xml Open](http://officeopenxml.com/WPcontentOverview.php)

> [!IMPORTANT]
> I'm working yet to make easy the API to build docx components and customize them. 
>
> The other formats will be builded soon.
>
> For the modification capabilities, I guess them can be maded later.

## Key Features

*   **Programmatic DOCX Generation:** Create `.docx` files from scratch using an object-based Dart API.
*   **Rich Content Support:** Insert paragraphs, formatted text (bold, italic, etc.), images, hyperlinks, page breaks, text frames, and tables.
*   **Customizable Styles:** Define and apply custom paragraph and character styles to your content.
*   **Document Properties Management:** Configure metadata such as title, author, subject, and more with no efforts.
*   **Media Handling:** Forget about saving images manually! Just pass them as `Byte`s or `File`s, and let us make our job in the background.
*   **Stream-Based Generation Events:** Generate documents asynchronously and monitor progress via a `Stream` of events.

## Installation

Add `docx` to your `pubspec.yaml` file:

```yaml
dependencies:
  docx: ^latest_version
```


## Basic Usage

### 1. Define the Document Content

Your document content is structured using classes that extend `DocxContent` and `ComponentContainer`. `DocxDocument` is the, and within it you can add `Paragraph`s, `TextRun`s, `Image`s, `HyperlinkRun`s, etc.

Here is an example of how to create a simple document with a paragraph and an image:

```dart
import 'dart:io';
import 'package:docx/docx.dart';

Future<void> main() async {
  final DocxDocument document = DocxDocument(
    options: DocumentOptions(
        title: 'My First DOCX Document',
        author: 'CodeCompanion',
        subject: 'docx_transformer example',
        // you can configure the 
        // columns in the document
        // section: SectionOptions(
        //   columns: ColumnSettings(),
        // ),
    ),
    sections: <DocxContent<dynamic>>[
      Paragraph(
        data: <RunBase>[ 
            TextRun(
              data: TextPart(
                text: 'This is a paragraph with bold text. ',
                styles: [
                  // we can use styles and attributes together
                  // if we want
                  Style.reference('code'), 
                  BoldAttribute(),
                ],
              ),
            ),
            HyperlinkRun(
              data: HyperlinkTextPart(
                hyperlink: 'https://github.com/your-user/your-repo',
                text: 'Visit my GitHub repository',
                style: <Style>[
                  Style.reference('Hyperlink')
                ],
              ),
            ),
            TextRun(
              data: TextPart(text: ' and here the paragraph ends.'),
            ),
        ],
        styles: <Style>[], 
        // decides where break the page
        pageBreak: ParagraphPageBreak.none,
      ),
      Paragraph(
        data: <RunBase>[
          TextRun(
            data: TextPart(text: 'Here is a line break.'),
          ),
        ],
      ),
      // loads and shows the image: 
      // * if it exists 
      // * if it can be used
      Paragraph(
        data: <RunBase<dynamic>>[
          Run(
            component: Drawing(
              data: LazyFloatingImage(
                data: ImageData(
                  buffer: File('test_resources/image.jpg'),
                  extension: 'jpg',
                  anchorConfig: AnchorConfig.block().copyWith(
                    horizontalAnchor: RelativeHorizontalAnchor.paragraph,
                    horizontalAlign: RelativeHorizontalAlign.left,
                    verticalAnchor: RelativeVerticalAnchor.paragraph,
                    verticalAlign: RelativeVerticalAlign.top,
                  ),
                  width: 0.5.toEmuFromInches(),
                  height: 0.55.toEmuFromInches(),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  final File file = File('generated_document.docx');
  final bytes = await DocxMetadataPacker.instance
      // to allow registering fonts used in the
      // runs that user pass, set this to true
      .dynamicFontSearch(true)
      .bytes(documentContent);
  await file.writeAsBytes(bytes!);

  print('DOCX document generated at: $outputPath');
}
```

### 2. Stream-Based Document Generation

For larger document operations or to display progress to the user, you can use `stream` which returns a `Stream<DocxEvent>`:

_I'll fix this section later, when stream implementation be corrected_

<!-- ````dart -->
<!-- import 'dart:io'; -->
<!-- import 'package:docx/docx.dart'; -->
<!---->
<!-- Future<void> generateDocumentWithStream() async { -->
<!--   final DocumentOptions options = -->
<!--       DocumentOptions.blank(title: 'Stream Document'); -->
<!--     final DocxDocument document =   -->
<!--     contents: [ -->
<!--       Paragraph(data: [TextRun(data: TextPart(text: 'Test content.'))]) -->
<!--     ], -->
<!--   ); -->
<!---->
<!--   final DocxDocumentSdk docxSdk = DocxDocumentSdk(options: options); -->
<!--   final String outputPath = 'stream_document.docx'; -->
<!---->
<!--   await for (final event in docxSdk.createDocumentStream( -->
<!--     documentContent, -->
<!--     supportedFileExtensions: {'png'}, -->
<!--   )) { -->
<!--     if (event is StartEvent) { -->
<!--       print('Starting document generation...'); -->
<!--     } -->
<!--     if (event is ProgressEvent) { -->
<!--       print('Progress: ${event.current}/${event.total} - ${event.subject}'); -->
<!--     } -->
<!--     if (event is SearchingEvent) { -->
<!--       print(event.subject); -->
<!--     } -->
<!--     if (event is EndEvent) { -->
<!--       if (event.error != null) { -->
<!--         print('Error generating document: ${event.error}'); -->
<!--       } else { -->
<!--         print('Document generated successfully.'); -->
<!--         // You can save the Uint8List if needed -->
<!--         final Uint8List? bytes = Uint8List.fromList(event.result!); -->
<!--         if (bytes != null) { -->
<!--           await File(outputPath).writeAsBytes(bytes); -->
<!--           print('Document saved at: $outputPath'); -->
<!--         } -->
<!--       } -->
<!--     } -->
<!-- } -->
<!-- ```` -->


### Images anchoring

The `docx` library provides flexible options for positioning images within your document. You can control whether an image flows with text like a character, or floats relative to paragraphs, margins, or even the page.

#### Basic Block image 

This is a common usage for most of the editors maded in Flutter}:.

````dart
final paragraph = Paragraph(
  data: [
    Run(
      // to follow Word standards, we need to wrap
      // shapes or images with Drawing component
      component: Drawing( 
        // there is also its own Lazy version
        // called LazyFloatingImage
        data: FloatingImage(
          data: ImageData(
            buffer: await File('assets/image.png').readAsBytes(),
            extension: 'png',
            // Configure anchoring relative to the paragraph
            anchorConfig: AnchorConfig(
              wrapType: WrapType.none,
              wrapSide: null,
              verticalAnchor: RelativeVerticalAnchor.paragraph,
              horizontalAnchor: RelativeHorizontalAnchor.paragraph,
              horizontalAlign: RelativeHorizontalAlign.left,
              verticalAlign: RelativeVerticalAlign.top,
            ),
            width: 1.5.toEmuFromInches(),
            height: 1.5.toEmuFromInches(),
          ),
        ),
      ),
    ),
  ],
);
````

#### Other examples:

##### 1. Anchoring to a Paragraph (Floating Image)

This is a common way to insert images that can have text wrap around them or be positioned independently of the immediate text flow, but still tied to a specific paragraph. The image is placed within a paragraph and its position is relative to that paragraph.

````dart
final paragraph = Paragraph(
  data: [
    TextRun(
      data: TextPart(text: 'Here is some text before the image. '),
    ),
    Run(
      // to follow Word standards, we need to wrap
      // shapes or images with Drawing component
      component: Drawing( 
        data: FloatingImage(
          data: ImageData(
            buffer: await File('assets/image.png').readAsBytes(),
            extension: 'png',
            // Configure anchoring relative to the paragraph
            anchorConfig: AnchorConfig(
              // text will try to be around this image
              wrapType: WrapType.square,
              wrapSide: WrapSide.bothSides,
              horizontalAnchor: RelativeHorizontalAnchor.paragraph,
              horizontalAlign: RelativeHorizontalAlign.center,
              verticalAnchor: RelativeVerticalAnchor.paragraph,
              verticalAlign: RelativeVerticalAlign.center,
              // You can also specify exact offsets if needed
              // offsetX: 0.5.toEmuFromInches(), 
              // offsetY: 0.5.toEmuFromInches(),
            ),
            width: 1.5.toEmuFromInches(),
            height: 1.5.toEmuFromInches(),
          ),
        ),
      ),
    ),
    TextRun(
      data: TextPart(text: ' And here is some text after the image, demonstrating wrapping. This is a longer sentence to show how text flows around the image.'),
    ),
  ],
);
````

##### 2. Treating an Image as an Inline Character

When an image should behave exactly like a text character, flowing with the text and not allowing complex wrapping, use `InlineImage`. This is ideal for small icons or images that are part of the textual content itself.

```dart
final paragraph = Paragraph(
  data: [
    TextRun(
      data: TextPart(text: 'This is an example of an '),
    ),
    Run(
      // to follow Word standards, we need to wrap
      // shapes or images with Drawing component
      component: Drawing(
        data: LazyImage(
          data: ImageData(
            buffer: File(
              'assets/inline_icon.png'),
            extension: 'png',
            width: 0.2.toEmuFromInches(),
            height: 0.2.toEmuFromInches(),
          ),
          asInline: true,
        ),
      ),
    ),
    TextRun(
      data: TextPart(text: ' inline image, flowing with the text.'),
    ),
  ],
);
```

##### 3. Anchoring to a Character with Precise Positioning (Floating Image)

For more fine-grained control where the image's anchor point is a specific character, but the image still floats, you can use `FloatingImage` with `RelativeHorizontalAnchor.character`. This allows for exact offsets relative to that character.

```dart
final paragraph = Paragraph(
  data: [
    TextRun(
      data: TextPart(text: 'This text has an image '),
    ),
    Run(
      // to follow Word standards, we need to wrap
      // shapes or images with Drawing component
      component: Drawing( 
        data: FloatingImage(
          data: ImageData(
            buffer: await File('assets/logo.png').readAsBytes(),
            extension: 'png',
            anchorConfig: AnchorConfig(
              wrapType: WrapType.square,
              wrapSide: WrapSide.bothSides,
              // Anchor relative to a character. 
              // This requires careful positioning.
              horizontalAnchor: RelativeHorizontalAnchor.character,
              // Anchor to the line of the character
              verticalAnchor: RelativeVerticalAnchor.line,
              // Explicit offsets from the anchor point (character).
              // Adjust these values to precisely place the image.
              anchorOffsetX: 0.1.toEmuFromInches(), 
              // Move slightly above the line
              anchorOffsetY: -0.2.toEmuFromInches(),
            ),
            width: 0.75.toEmuFromInches(),
            height: 0.75.toEmuFromInches(),
          ),
        ),
      ),
    ),
    TextRun(
      data: TextPart(text: ' positioned precisely next to this point.'),
    ),
  ],
);
```

### Font Management

Managing fonts is crucial for ensuring your document looks consistent across different systems. `docx` offers a flexible API to define the fonts used in your document. You can either **reference** fonts (expecting them to be installed on the user's system) or **embed** their binary data directly into the `.docx` file (guaranteeing fidelity).

All font definitions are added via the `DocumentOptions.fonts` property, which expects a list of `FontProperties` objects.

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
//   sections: [
//     // ... document content using these font names in styles ...
//     Paragraph(
//       data: [
//         TextRun(
//           data: TextPart(
//             text: 'This text uses the embedded My Custom Font.',
//             styles: [
//               StyleBuilder.character('myCustomFontStyle')
//                   .fontFamily('My Custom Font') // Reference the font by its name
//                   .fontSize(14)
//                   .build(),
//             ],
//           ),
//         ),
//       ],
//     ),
//     Paragraph(
//       data: [
//         TextRun(
//           data: TextPart(
//             text: 'This text uses the referenced Verdana font.',
//             styles: [
//               StyleBuilder.character('verdanaStyle')
//                   .fontFamily('Verdana')
//                   .fontSize(12)
//                   .build(),
//             ],
//           ),
//         ),
//       ],
//     ),
//   ],
// );
```

#### How `docx` Handles Fonts Internally

The `FontStore` (an internal component) automatically manages the complexities:
*   It generates unique IDs and obfuscation keys for embedded font files.
*   It constructs the `word/fontTable.xml` file, which lists all referenced and embedded fonts with their metadata.
*   For embedded fonts, it also creates `word/_rels/fontTable.xml.rels` (a separate relationships file) that links the `fontTable.xml` entries to the actual obfuscated binary font files (`.odttf`).
*   Finally, it adds these obfuscated font binaries to the `.docx` ZIP archive.

This abstraction means you only need to provide the `FontProperties` (and binary data for embedded fonts), and `docx` handles all the underlying WordML specification details.

## Style Customization

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

Creating a styles can sound difficult, but, it can be so easy using our `StyleBuilder` class. You just need to specify what you want and call `build` to use it!

```dart
import 'package:docx/docx.dart';

// Build your styles easily using our builder 
final Style customRedCenteredParagraph = StyleBuilder.paragraph('CustomRedCentered')
    .name('Red Centered Paragraph')
    .basedOn('Normal') // Based on common "Normal" style 
    .next('Normal') // Next paragraph must have applied normal paragraph 
    .color('FF0000') // Red 
    .fontSize(12) // Font size of 12pt
    .bold() 
    .alignment(Alignment.center)
    .spacing(before: 200, after: 200)
    .qFormat(true) // show in the gallery of styles
    .build();

final paragraph = Paragraph(
    data: <RunBase<dynamic>>[
      TextRun(
        data: TextPart(text: 'This text uses my custom style.'),
      ),
    ],
    styles: <Style>[customRedCenteredParagraph],
  ),
),
```

**Optionally**, you can register this `Style` in a `DocumentStylesSheet` to avoid use the same instance every time. Just register it and use `Style.reference` constructor to reference the style and let to the component decided how get and build it.

```dart
DocumentStylesSheet myCustomStyles = DocumentStylesSheet(
  styles: [
    // Optional: keep default styles
    ...DefaultDocumentStyles.kDefaultDocumentStyleSheet.styles,
    customRedCenteredParagraph,
  ],
);

//Then, in your DocxDocumentSdk:
final DocumentOptions options = DocumentOptions(
  // ...
  styles: myCustomStyles,
);

final paragraph = Paragraph(
  styles: <Style>[Style.reference('CustomRedCentered')],
  data: <RunBase<dynamic>>[
      TextRun(
        data: TextPart(text: 'This text uses my custom style.'),
      ),
    ],
  ),
),
````

### Document Settings Configuration
 
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
   root: DocumentRoot(sections: <DocxTreeNode<dynamic>>[]),
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
