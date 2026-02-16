import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

Future<void> main() async {
  final File outFile = File('test_resources/numbering.docx');

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
      title: 'Numbering document',
      styles: DocumentStyles.base(),
    ),
    root: DocumentRoot(
      sections: <DocxTreeNode<dynamic>>[
        Paragraph.text(
          text: 'First ordered element',
          styles: <Style>[Style.reference('ListParagraph')],
          numbering: Numbering(
            reference: 'ordered',
            level: 0,
            refId: 1,
          ),
        ),
        Paragraph.text(
          text: 'Second ordered element',
          styles: <Style>[Style.reference('ListParagraph')],
          numbering: Numbering(
            reference: 'ordered',
            level: 0,
            refId: 1,
          ),
        ),
        Paragraph.text(
          text: 'First nested element',
          styles: <Style>[Style.reference('ListParagraph')],
          numbering: Numbering(
            reference: 'ordered',
            level: 1,
            refId: 1,
          ),
        ),
        Paragraph.text(
          text: 'Second nested element',
          styles: <Style>[Style.reference('ListParagraph')],
          numbering: Numbering(
            reference: 'ordered',
            level: 2,
            refId: 1,
          ),
        ),
        Paragraph.text(
          text: 'New ordered list item',
          styles: <Style>[Style.reference('ListParagraph')],
          numbering: Numbering(
            reference: 'ordered',
            level: 0,
            refId: 2,
          ),
        ),
        Paragraph.text(
          text: 'Bulleted list element',
          styles: <Style>[Style.reference('ListParagraph')],
          numbering: Numbering(
            reference: 'unordered',
            level: 0,
            refId: 1,
          ),
        ),
        Paragraph.text(
          text: 'Nested bulleted list element',
          styles: <Style>[Style.reference('ListParagraph')],
          numbering: Numbering(
            reference: 'unordered',
            level: 1,
            refId: 1,
          ),
        ),
      ],
    ),
  );

  final Uint8List? bytes = await DocxPacker()
      .dynamicFontSearch(true)
      .noTrimRuns()
      .execute(doc, applyCustomTheme: false);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  }
}
