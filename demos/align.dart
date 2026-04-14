import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

Future<void> main() async {
  final File outFile = File('test_resources/align.docx');

  final PageSize pageSize = PageSize.letter;
  final DocumentMargins margins = DocumentMargins.fromCm(
    top: 1.52,
    right: 1.52,
    left: 1.52,
    bottom: 1.52,
    header: 1.1,
    footer: 1.1,
  );

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
      title: 'Minimal',
      styles: DocumentStyles.empty(),
      section: DocumentLayout(
        size: pageSize,
        margins: margins,
      ),
    ),
    root: DocumentRoot(
      sections: <DocxTreeNode<dynamic>>[
        Align(
          alignment: Alignment.center,
          child: Paragraph.text(
            text: 'Hello World',
            level: 1,
          ),
        ),
      ],
    ),
  );

  final Uint8List? bytes = await DocxPacker()
      .dynamicFontSearch(false)
      .noTrimRuns()
      .setNormalIfNeeded(true)
      .checkStylReferences()
      .logPath(DocxPaths.documentFilePath)
      .execute(
        doc,
        applyCustomTheme: true,
      );

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  } else {
    stderr.writeln('Failed to generate align.docx');
  }
}
