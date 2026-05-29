import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

const String orderedKey = 'ordered';
const String unorderedKey = 'unordered';

final DocumentOptions options = DocumentOptions.standard(
  title: 'Numbering document',
  styles: DocumentStyles.base().withNewStyles([
    StyleBuilder.paragraph('title')
        .name('Title')
        .fontSize(Point(16))
        .bold()
        .spacing(
          before: Point(12),
          after: Point(6),
        )
        .qFormat(true)
        .uiPriority(8)
        .build(),
  ]),
);

Future<void> main() async {
  final File outFile = File('test_resources/numbering.docx');
  final Uint8List? bytes = await runCompilation(
    MyApp(),
    logAll: false,
    options: options,
  );

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  DocxNode<dynamic> build() {
    return RootBody(
      sections: <DocxNode<dynamic>>[
        SdtRichText(
          alias: 'alias',
          tag: 'tag',
          placeholder: 'placeholder',
          showingPlacHdr: true,
        ).run().paragraph(),
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
    );
  }
}
