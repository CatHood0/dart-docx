## Generate Word Documents (DOCX) easily with Dart

**Docx** is a powerful and versatile parser designed to allow us to create documents using a high level API. It also converts from/to different formats, including **HTML**, **Markdown**, **plain text**, and **Quill Delta**. We can seamlessly transform content across popular formats and Word documents while preserving structure, formatting, and the richness of the original content.

## Key Features

*   **Programmatic DOCX Generation:** Create `.docx` files from scratch using an object-based Dart API.
*   **Rich Content Support:** Insert paragraphs, formatted text (bold, italic, etc.), images, and hyperlinks.
*   **Customizable Styles:** Define and apply custom paragraph and character styles to your content.
*   **Document Properties Management:** Configure metadata such as title, author, subject, and more.
*   **Media Handling:** Embed images into your document, with support for multiple file extensions.
*   **Stream-Based Generation Events:** Generate documents asynchronously and monitor progress via a `Stream` of events.

## Installation

Add `docx` to your `pubspec.yaml` file:

```yaml
dependencies:
  docx: ^latest_version
```


## Basic Usage

The core of the library is the `DocxDocumentSdk` class, which orchestrates the creation of all internal XML components of a `.docx` file from a `DocxComponentContainer`.

### 1. Define the Document Content

Your document content is structured using classes that extend `DocxContent` and `ComponentContainer`. `DocxComponentContainer` is the root container, and within it you can add `Paragraph`s, `TextRun`s, `Image`s, `HyperlinkRun`s, etc.

Here is an example of how to create a simple document with a paragraph and an image:

```dart
import 'dart:io';
import 'package:docx/docx.dart';

Future<void> main() async {
  // 1. Set up document options
  final DocumentOptions options = DocumentOptions(
    title: 'My First DOCX Document',
    author: 'CodeCompanion',
    subject: 'docx_transformer example',
  );

  // 2. Define the document content
  final DocxComponentContainer documentContent = DocxComponentContainer(
    contents: [
      Paragraph(
        data: <TextRunBase>[ 
            TextRun(
              data: TextPart(
                text: 'This is a paragraph with bold text. ',
                styles: [BoldAttribute()], // Apply bold
              ),
            ),
            HyperlinkRun(
              data: HyperlinkTextPart(
                hyperlink: 'https://github.com/your-user/your-repo',
                text: 'Visit my GitHub repository',
              ),
              style: Style.reference('Hyperlink'),
            ),
            TextRun(
              data: TextPart(text: ' and here the paragraph ends.'),
            ),
        ],
      ),
      Paragraph(
        data: [
            TextRun(
              data: TextPart(text: 'Here is a line break.'),
            ),
        ],
      ),
      // loads and shows the image if exists or if it can be used
      LazyImage(
        data: LazyImageData(
          file: File('test_resources/image.jpg'),
          extension: 'jpg',
          width: 300, 
          height: 400,
        ),
      ),
    ],
  );

  // 3. Create an instance of DocxDocumentSdk
  final DocxDocumentSdk docxSdk = DocxDocumentSdk(options: options);

  // 4. Generate the document and save it
  final String outputPath = 'generated_document.docx';
  await docxSdk.save(
    documentContent,
    filePath: outputPath,
    supportedFileExtensions: {'jpg', 'png'}, // Supported image extensions
  );

  print('DOCX document generated at: $outputPath');
}
```

### 2. Stream-Based Document Generation

For larger document operations or to display progress to the user, you can use `createDocumentStream` which returns a `Stream<DocxEvent>`:

````dart
import 'dart:io';
import 'package:docx/docx.dart';

Future<void> generateDocumentWithStream() async {
  final DocumentOptions options =
      DocumentOptions.blank(title: 'Stream Document');
  final DocxComponentContainer documentContent = DocxComponentContainer(
    contents: [
      Paragraph(data: [TextRun(data: TextPart(text: 'Test content.'))])
    ],
  );

  final DocxDocumentSdk docxSdk = DocxDocumentSdk(options: options);
  final String outputPath = 'stream_document.docx';

  await for (final event in docxSdk.createDocumentStream(
    documentContent,
    supportedFileExtensions: {'png'},
  )) {
    if (event is StartEvent) {
      print('Starting document generation...');
    }
    if (event is ProgressEvent) {
      print('Progress: ${event.current}/${event.total} - ${event.subject}');
    }
    if (event is SearchingEvent) {
      print(event.subject);
    }
    if (event is EndEvent) {
      if (event.error != null) {
        print('Error generating document: ${event.error}');
      } else {
        print('Document generated successfully.');
        // You can save the Uint8List if needed
        final Uint8List? bytes = Uint8List.fromList(event.result!);
        if (bytes != null) {
          await File(outputPath).writeAsBytes(bytes);
          print('Document saved at: $outputPath');
        }
      }
    }
}
````

## Style Customization

`docx` provides a flexible system for defining custom Word styles that are reflected in `word/styles.xml`. This is achieved through the `Style` and `StyleConfigurator` classes.

*   **`Style`**: Represents a full paragraph or character style in Word (e.g., "Normal", "Heading1", "Hyperlink").
    *   `type`: `'paragraph'` or `'character'`.
    *   `styleId`: The internal ID used in the Word XML.
    *   `styleName`: The name displayed in the Word UI.
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
```

To use this style, you would add it to your DocumentStylesSheet
and then reference 'CustomRedCentered' in your Paragraph component.

```dart
DocumentStylesSheet myCustomStyles = DocumentStylesSheet(
  styles: [
    ...DefaultDocumentStyles.kDefaultDocumentStyleSheet.styles, // Optional: keep default styles
    customRedCenteredParagraph,
  ],
);

//Then, in your DocxDocumentSdk:
final DocumentOptions options = DocumentOptions(
  // ...
  styles: myCustomStyles,
);

final paragraph = Paragraph(
  // use reference constructor to allow to the sdk searching the style
  // into styles.xml or DocumentStylesSheet
  styles: Style.reference(styleId: 'CustomRedCentered', styleName: ''),
  data: <TextBlockContainer>[
      TextRun(
        data: TextPart(text: 'This text uses my custom style.'),
      ),
    ],
  ),
),
````
