import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';
import 'package:docx/src/core/extensions/cast_ext.dart';

Future<void> main() async {
  final File outFile = File('test_resources/minimal_row.docx');

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
      title: ':)',
      author: 'ME',
      styles: DocumentStyles.base(),
      section: DocumentLayout(
        size: PageSize.letter,
        margins: DocumentMargins.fromCm(
          top: 1.52,
          right: 1.52,
          left: 1.52,
          bottom: 1.52,
          header: 1.1,
          footer: 1.1,
        ),
      ),
    ),
    root: DocxRoot(
      sections: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        minHeight: 5.ptToDxa(),
        children: <DocxNode<dynamic>>[
          Text('👈 LEFT'),
          Text('🎯 CENTER'),
          Text('RIGHT 👉'),
        ],
      ).toList(),
    ),
  );

  final Uint8List? bytes = await DocxPacker()
      .dynamicFontSearch(true)
      // add preserve to the <w:r> to avoid auto trim
      // behavior of Word
      .noTrimRuns()
      // if a paragraph has no default style defined
      // it will force to have one
      .setNormalIfNeeded(true)
      .execute(doc);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  } else {
    stderr.writeln('Failed to generate minimal_row.docx');
  }
}
