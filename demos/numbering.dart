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
  DocxElements.instance.ensureInitialized();
  final Uint8List? bytes = await runCompilation(
    MyApp(),
    logAll: true,
    options: options,
    checkStylReferences: true,
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
        // SdtRichText(
        //   alias: 'alias',
        //   tag: 'tag',
        //   placeholder: 'placeholder',
        //   showingPlacHdr: true,
        // ).run().paragraph(),
        Paragraph.text(
          id: 'paragraph-1',
          text: 'First list',
          styles: [
            Style.ref('title'),
          ],
        ),
        // Level 1
        NumberingList(
          id: 'list-1',
          refKey: orderedKey,
          children: [
            Text(
              id: 'text-0',
              'First ordered element',
            ),
            Text(
              id: 'text-1',
              'Second ordered element',
            ),
            // Level 2
            NumberingList.inherit(
              id: 'list-1-1',
              children: [
                Text(
                  id: 'text-2',
                  'First nested element',
                ),
                // Level 3
                NumberingList.inheritOne(
                  id: 'list-1-1-1',
                  child: Text('Second nested element'),
                ),
              ],
            ),
          ],
        ),
        Paragraph.text(
          id: 'paragraph-2',
          text: 'Second list (restart the count)',
          styles: [
            Style.ref('title'),
          ],
        ),
        Text(
          id: 'text-3',
          'Since every new instance of '
          'NumberingList. makes a new refId, '
          'then it\'s restarted automatically',
        ),
        NumberingList(
          id: 'list-2',
          refKey: orderedKey,
          children: [
            // We also allow using runs here
            TextRun.text(
              id: 'text-run-1',
              text: 'New ordered list item',
            ),
            // HyperlinkRun.pure(text: 'PUB DEV WEBSITE', link: 'https://www.pub.dev'),
          ],
        ),
        NumberingList(
          id: 'list-3',
          refKey: unorderedKey,
          listStyle: StyleBuilder.ul()
              .lineSpacing(SpacingInch(1.5))
              .borders(
                left: BorderStyle.dotted,
                leftSize: Point(2),
                leftColor: Colors.navy,
              )
              .build(),
          children: [
            Text(
              id: 'text-4',
              'Bulleted list element',
            ),
            Text(
              id: 'text-5',
              'Nested bulleted list element',
            ),
          ],
        ),
      ],
    );
  }
}
