// filepath: demos/novel.dart
import 'dart:io';
import 'package:docx/docx.dart';
import 'package:docx/src/docx_sdk/components/root/document_root.dart';
import 'package:docx/src/docx_sdk/packer/docx_metadata_packer.dart';

/// Mini-novel demo that generates a short story as a .docx file.
Future<void> main() async {
  Directory('demos_output').createSync(recursive: true);
  final File outFile = File('demos_output/mini_novel.docx');

  final List<DocxTreeNode<dynamic>> sections = <DocxTreeNode<dynamic>>[
    Paragraph(
      data: <RunBase<dynamic>>[
        TextRun(
          data: TextPart(
              text: 'A Short Walk at Midnight',
              styles: <Object>[Style.reference('Title')]),
        ),
      ],
    ),
    Paragraph(
      data: <RunBase<dynamic>>[
        TextRun(
          data: TextPart(
              text: 'by Anonymous',
              styles: <Object>[Style.reference('Author')]),
        ),
      ],
    ),
  ];

  // Chapters (few paragraphs)
  final String chapter1 =
      'The night was quiet. The town slept under a pale moon, and only the old clock tower dared to count the hours. ';
  final String chapter1More =
      'He walked without thinking, letting the cobblestones guide his steps toward the harbor.';

  sections
    ..add(
      Paragraph(
        data: <RunBase<dynamic>>[
          TextRun(data: TextPart(text: chapter1)),
        ],
      ),
    )
    ..add(
      Paragraph(
        data: <RunBase<dynamic>>[
          TextRun(data: TextPart(text: chapter1More)),
        ],
      ),
    )

    // Short second chapter
    ..add(
      Paragraph(
        data: <RunBase<dynamic>>[
          TextRun(
              data: TextPart(
                  text:
                      '\nChapter II\nHe stepped into the mist, and everything changed.')),
        ],
      ),
    );

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.blank(
      title: 'A Short Walk at Midnight',
      styles: DocumentStylesSheet.base().withNewStyles(
        <Style>[
          StyleBuilder.paragraph('Title')
              .fontSize(20)
              .bold()
              .alignment(Alignment.center)
              .build(),
          StyleBuilder.paragraph('Author')
              .fontSize(12)
              .italic()
              .alignment(Alignment.center)
              .build(),
          StyleBuilder.paragraph('Chapter')
              .fontSize(14)
              .bold()
              .spacing(after: 100)
              .build(),
        ],
      ),
    ),
    root: DocumentRoot(sections: sections),
  );

  final DocxMetadataPacker packer = DocxMetadataPacker();
  packer.dynamicFontSearch(true);
  final bytes = await packer.bytes(doc, applyCustomTheme: false);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
    print('Saved mini-novel to ${outFile.path}');
  } else {
    stderr.writeln('Failed to generate mini-novel .docx');
  }
}
