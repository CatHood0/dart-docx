import 'dart:convert';

import '../../../docx.dart';
import '../../docx_sdk/packer/docx_metadata_packer.dart';
import '../parser_events.dart';

class PlainTextToDocx extends Parser<String, List<int>?, BasicParserOptions> {
  PlainTextToDocx({
    required super.options,
  });

  final DocxMetadataPacker packer = DocxMetadataPacker.instance;

  @override
  Future<List<int>> build({required String data}) async {
    emitEvent(StartEvent());
    final bytes = await packer.bytes(
      DocxDocument(
        sections: _documentContentBuilder(data: data).cast(),
        options: options.documentOptions,
      ),
    );
    emitEvent(CompleteEvent(bytes));
    return bytes!;
  }

  List<DocxContent> _documentContentBuilder({required String data}) {
    final List<String> lines = const LineSplitter().convert(data);
    final List<DocxContent> buffer = <DocxContent>[];
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
