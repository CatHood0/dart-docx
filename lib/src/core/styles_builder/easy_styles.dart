import '../../../docx.dart';
import '../../docx_sdk/utils/language_codes.dart';

class EasyStyles {
  static Style get normal => StyleBuilder.paragraph('Normal')
      .name(
        'Normal',
        LanguageCodes.englishUS,
      )
      .fontFamily('Times New Roman')
      .fontSize(12.toHalfPointsFromPoints())
      .alignment(Alignment.left)
      .spacing(before: 0, after: 160)
      .lineSpacing(240)
      .lang(DocxLanguage(language: LanguageCodes.englishUS))
      .qFormat(true)
      .build();

  static Style get listParagraph => StyleBuilder.paragraph('ListParagraph')
      .names({
        'List Paragraph': LanguageCodes.englishUS,
        'Lista de Parrafo': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .basedOn('Normal')
      .keepNext(true)
      .keepLines(true)
      .activateWindowControl()
      .indent(left: 720, hanging: 360)
      .build();

  static Style get defaultParagraphFont =>
      StyleBuilder.character('DefaultParagraphFont')
          .names({
            'Default Paragraph Font': LanguageCodes.englishUS,
            'Estilo de Parrafo Predeterminado': List<String>.from(<String>[
              LanguageCodes.spanishES,
              LanguageCodes.spanishMX,
            ]),
          })
          .defaultValue(true)
          .build();

  static Style get hyperlink => StyleBuilder.character('Hyperlink')
      .names({
        'Hyperlink': LanguageCodes.englishUS,
        'Hipervínculo': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .runColor(Color.rgb(0x0563C1))
      .underline()
      .build();

  static Style get heading1 => StyleBuilder.paragraph('Heading1')
      .names(<String, dynamic>{
        'Heading 1': LanguageCodes.englishUS,
        'Título 1': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(24.toHalfPointsFromPoints())
      .bold()
      .spacing(before: 480)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(0)
      .uiPriority(9)
      .qFormat(true)
      .build();

  static Style get heading2 => StyleBuilder.paragraph('Heading2')
      .names(<String, dynamic>{
        'Heading 2': LanguageCodes.englishUS,
        'Título 2': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(18.toHalfPointsFromPoints())
      .bold()
      .spacing(before: 360, after: 80)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(1)
      .uiPriority(9)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading3 => StyleBuilder.paragraph('Heading3')
      .names(<String, dynamic>{
        'Heading 3': LanguageCodes.englishUS,
        'Título 3': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(14.toHalfPointsFromPoints())
      .bold()
      .spacing(before: 280, after: 80)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(2)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading4 => StyleBuilder.paragraph('Heading4')
      .names(<String, dynamic>{
        'Heading 4': LanguageCodes.englishUS,
        'Título 4': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(12.toHalfPointsFromPoints())
      .bold()
      .spacing(before: 240, after: 40)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(3)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading5 => StyleBuilder.paragraph('Heading5')
      .names(<String, dynamic>{
        'Heading 5': LanguageCodes.englishUS,
        'Título 5': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(12.toHalfPointsFromPoints())
      .bold()
      .spacing(before: 220, after: 40)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(4)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading6 => StyleBuilder.paragraph('Heading6')
      .names(<String, dynamic>{
        'Heading 6': LanguageCodes.englishUS,
        'Título 6': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(10.toHalfPointsFromPoints())
      .bold()
      .spacing(before: 200, after: 40)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(5)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static List<Style> get standardDocumentStyles => <Style>[
        normal,
        listParagraph,
        defaultParagraphFont,
        hyperlink,
        heading1,
        heading2,
        heading3,
        heading4,
        heading5,
        heading6,
      ];
}
