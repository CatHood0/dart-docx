import 'dart:convert';

import '../../../docx.dart';

class PlainTextToDocx extends Parser<String, List<int>?, BasicParserOptions> {
  PlainTextToDocx({
    required super.options,
  });

  final DocxPacker packer = DocxPacker.instance;

  @override
  Future<List<int>> build({required String data}) async {
    final bytes = await packer.execute(
      DocxDocument(
        root: DocxRoot(sections: _documentContentBuilder(data: data).cast()),
        options: options.documentOptions,
      ),
    );
    return bytes!;
  }

  List<DocxNode> _documentContentBuilder({required String data}) {
    final List<String> lines = const LineSplitter().convert(data);
    final List<DocxNode> buffer = <DocxNode>[];
    for (final String text in lines) {
      buffer.add(
        Paragraph(
          children: [
            TextRun(textPart: TextPart(text: text)),
          ],
        ),
      );
    }
    return buffer;
  }
}
