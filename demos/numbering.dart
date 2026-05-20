import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

const String orderedKey = 'ordered';
const String unorderedKey = 'unordered';

Future<void> main() async {
  final File outFile = File('test_resources/numbering.docx');

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
      title: 'Numbering document',
      styles: DocumentStyles.base().withNewStyles([
        StyleBuilder.paragraph('title')
            .name('Title')
            .fontSize(16.ptToHalfPoints())
            .bold()
            .spacing(
              before: 12.ptToTwips(),
              after: 6.ptToTwips(),
            )
            .qFormat(true)
            .uiPriority(8)
            .build(),
      ]),
    ),
    root: DocxRoot(
      sections: <DocxNode<dynamic>>[
        Paragraph.text(
          text: 'First list',
          styles: [
            Style.ref('title'),
          ],
        ),
        // Level 1
        NumberingList(
          refKey: orderedKey,
          children: [
            Text('First ordered element'),
            Text('Second ordered element'),
            // Level 2
            NumberingList.inherit(
              children: [
                Text('First nested element'),
                // Level 3
                NumberingList.inheritOne(
                  child: Text('Second nested element'),
                ),
              ],
            ),
          ],
        ),
        Paragraph.text(
          text: 'Second list (restart the count)',
          styles: [
            Style.ref('title'),
          ],
        ),
        Text(
          'Since every new instance of '
          'NumberingList. makes a new refId, '
          'then it\'s restarted automatically',
        ),
        NumberingList(
          refKey: orderedKey,
          children: [
            // We also allow using runs here
            TextRun.text(text: 'New ordered list item'),
            // HyperlinkRun.pure(text: 'PUB DEV WEBSITE', link: 'https://www.pub.dev'),
          ],
        ),
        NumberingList(
          refKey: unorderedKey,
          children: [
            Text('Bulleted list element'),
            Text('Nested bulleted list element'),
          ],
        ),
      ],
    ),
  );

  final Uint8List? bytes = await DocxPacker()
      .autoRegisterFonts(true)
      .noTrimRuns()
      // .logPath(DocxPaths.numberingXmlFilePath)
      .normalStyleIfNeeded()
      .logLevel(LogLevel.all)
      .log(print)
      .setStandardStores()
      .execute(
        doc,
        applyCustomTheme: false,
        stages: DocxPipeline.defaultStages,
      );

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  }
}
