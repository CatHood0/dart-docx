import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

/// Simple demo that generates a basic document with a centered heart
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
          text: 'My first list item',
          styles: <Style>[
            Style.reference('ListParagraph'),
          ],
          numbering: Numbering(
            reference: 'ordered',
            level: 0,
            refId: 1,
          ),
        ),
        Paragraph.text(
          text: 'My first list item',
          styles: <Style>[
            Style.reference('ListParagraph'),
          ],
          numbering: Numbering(
            reference: 'ordered',
            level: 0,
            refId: 1,
          ),
        ),
      ],
    ),
  );

  final Uint8List? bytes =
      await DocxPacker().dynamicFontSearch(true).noTrimRuns().logPaths(<String>[
    DocxPaths.stylesXmlFilePath,
  ]).execute(doc, applyCustomTheme: false);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  }
}
