import 'dart:convert';

import '../../../docx.dart';
import '../parser_events.dart';

class PlainTextToDocx extends Parser<String, List<int>?, BasicParserOptions> {
  PlainTextToDocx({
    required super.options,
  });

  final DocxPacker packer = DocxPacker.instance;

  @override
  Future<List<int>> build({required String data}) async {
    emitEvent(StartEvent());
    final bytes = await packer.execute(
      DocxDocument(
        root: DocumentRoot(sections: _documentContentBuilder(data: data).cast()),
        options: options.documentOptions,
      ),
    );
    emitEvent(CompleteEvent(bytes));
    return bytes!;
  }

  List<DocxTreeNode> _documentContentBuilder({required String data}) {
    final List<String> lines = const LineSplitter().convert(data);
    final List<DocxTreeNode> buffer = <DocxTreeNode>[];
    for (final String text in lines) {
      buffer.add(
        Paragraph(
          data: [
            TextRun(data: TextPart(text: text)),
          ],
        ),
      );
    }
    return buffer;
  }
}
