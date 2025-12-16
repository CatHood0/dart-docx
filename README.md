## Dart-DOCX: Easily generate .docx files with Dart

**Docx** is a powerful and versatile parser designed to allow us to create documents using a high level API. 

We designed also multiple parsers to be from/to formats, **HTML**, **Markdown**, **plain text**, and **Quill Delta**, are the planed ones. 

We can seamlessly transform content across popular formats and Word documents while preserving structure, formatting, and the richness of the original content (as well as we can, since, multiple formats does not support paginations, positioning, or some complex features that comes from word).

> [!IMPORTANT]
> I'm working yet to make easy the API to build docx components and customize them. 
>
> The other formats will be builded soon.
>
> For the modification capabilities, I guess them can be maded later.

## Key Features

*   **Programmatic DOCX Generation:** Create `.docx` files from scratch using an object-based Dart API.
*   **Rich Content Support:** Insert paragraphs, formatted text (bold, italic, etc.), images, hyperlinks, page breaks and tables.
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
    ),
    sections: <ComponentContainer<dynamic>>[
      Paragraph(
        data: <RunBase>[ 
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

  final File file = File('generated_document.docx');
  final bytes = await DocxMetadataPacker.instance.bytes(documentContent);
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

final paragraph = Paragraph(
    data: <TextBlockContainer>[
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
  data: <TextBlockContainer>[
      TextRun(
        data: TextPart(text: 'This text uses my custom style.'),
      ),
    ],
  ),
),
````
