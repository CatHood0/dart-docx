import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';
import 'package:docx/src/core/extensions/cast_ext.dart';

final PageSize pageSize = PageSize.a4;
final DocumentMargins margins = DocumentMargins.fromCm(
  top: 2.0,
  right: 2.5,
  left: 2.5,
  bottom: 2.0,
  header: 1.0,
  footer: 1.0,
  gutter: 0,
);

final DocumentOptions options = DocumentOptions.standard(
  title: 'Formulario de Contrato',
  section: DocumentLayout(
    size: pageSize,
    margins: margins,
  ),
  styles: DocumentStyles.base().withNewStyles(
    <Style>[
      StyleBuilder.paragraph('title')
          .name('Title')
          .fontSize(Point(24))
          .fontFamily('Arial')
          .bold()
          .alignment(Alignment.center)
          .spacing(
            before: SpacingInch(0.5),
            after: SpacingInch(2.0),
          )
          .build(),
      StyleBuilder.paragraph('section')
          .name('Section Header')
          .fontSize(Point(14))
          .fontFamily('Arial')
          .bold()
          .runColor(Color(0xFF1F4E79))
          .spacing(
            before: SpacingInch(1.0),
            after: SpacingInch(0.8),
          )
          .build(),
      StyleBuilder.paragraph('label')
          .name('Label')
          .fontSize(Point(11))
          .fontFamily('Arial')
          .bold()
          .runColor(Color(0xFF333333))
          .spacing(
            before: SpacingInch(0.2),
            after: SpacingInch(0.3),
          )
          .build(),
      StyleBuilder.paragraph('hint')
          .name('Hint')
          .fontSize(Point(9))
          .fontFamily('Arial')
          .italic()
          .runColor(Color(0xFF888888))
          .spacing(
            before: SpacingInch(0.0),
            after: SpacingInch(0.5),
          )
          .build(),
      StyleBuilder.paragraph('separator')
          .name('Separator')
          .spacing(
            before: SpacingInch(0.5),
            after: SpacingInch(0.5),
          )
          .build(),
    ],
  ),
  glossaryEntries: [
    // Placeholder for Full Name
    GlossaryEntry(
      name: 'PlcHdr_NombreCompleto',
      type: GlossaryEntryType.placeholder,
      category: 'Form Placeholders',
      description: 'Placeholder para nombre completo',
      behavior: GlossaryBehavior.content,
      body: [
        Paragraph(
          children: [
            TextRun.text(
              text: '[Escriba su nombre completo]',
              textStyle: TextStyle(
                italic: true,
                color: Color(0xFF888888),
                fontSize: Point(11),
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ],
    ),
    // Placeholder for Email
    GlossaryEntry(
      name: 'PlcHdr_CorreoElectronico',
      type: GlossaryEntryType.placeholder,
      category: 'Form Placeholders',
      description: 'Placeholder para correo electrónico',
      behavior: GlossaryBehavior.content,
      body: [
        Paragraph(
          children: [
            TextRun.text(
              text: '[Escriba su correo electrónico]',
              textStyle: TextStyle(
                italic: true,
                color: Color(0xFF888888),
                fontSize: Point(11),
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ],
    ),
    // Placeholder for contract clause
    GlossaryEntry(
      name: 'PlcHdr_ClausulaContrato',
      type: GlossaryEntryType.placeholder,
      category: 'Form Placeholders',
      description: 'Placeholder para cláusula del contrato',
      behavior: GlossaryBehavior.content,
      body: [
        Paragraph(
          children: [
            TextRun.text(
              text: '[Escriba la descripción del contrato aquí...]',
              textStyle: TextStyle(
                italic: true,
                color: Color(0xFF888888),
                fontSize: Point(11),
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ],
    ),
    // Placeholder for salary
    GlossaryEntry(
      name: 'PlcHdr_Salario',
      type: GlossaryEntryType.placeholder,
      category: 'Form Placeholders',
      description: 'Placeholder para salario anual',
      behavior: GlossaryBehavior.content,
      body: [
        Paragraph(
          children: [
            TextRun.text(
              text: '[Escriba el salario anual]',
              textStyle: TextStyle(
                italic: true,
                color: Color(0xFF888888),
                fontSize: Point(11),
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ],
    ),
    // Placeholder for notes
    GlossaryEntry(
      name: 'PlcHdr_NotasAdicionales',
      type: GlossaryEntryType.placeholder,
      category: 'Form Placeholders',
      description: 'Placeholder para notas adicionales',
      behavior: GlossaryBehavior.content,
      body: [
        Paragraph(
          children: [
            TextRun.text(
              text: '[Escriba sus notas adicionales aquí...]',
              textStyle: TextStyle(
                italic: true,
                color: Color(0xFF888888),
                fontSize: Point(10),
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ],
    ),
    // Placeholder for signature
    GlossaryEntry(
      name: 'PlcHdr_Firma',
      type: GlossaryEntryType.placeholder,
      category: 'Form Placeholders',
      description: 'Placeholder para firma',
      behavior: GlossaryBehavior.content,
      body: [
        Paragraph(
          children: [
            TextRun.text(
              text: '[Inserte su firma aquí]',
              textStyle: TextStyle(
                italic: true,
                color: Color(0xFF888888),
                fontSize: Point(11),
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ],
    ),
    // Placeholder for document type
    GlossaryEntry(
      name: 'PlcHdr_TipoDocumento',
      type: GlossaryEntryType.placeholder,
      category: 'Form Placeholders',
      description: 'Placeholder para tipo de documento',
      behavior: GlossaryBehavior.content,
      body: [
        Paragraph(
          children: [
            TextRun.text(
              text: '[Seleccione tipo de documento]',
              textStyle: TextStyle(
                italic: true,
                color: Color(0xFF888888),
                fontSize: Point(11),
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ],
    ),
    // Placeholder for country
    GlossaryEntry(
      name: 'PlcHdr_Pais',
      type: GlossaryEntryType.placeholder,
      category: 'Form Placeholders',
      description: 'Placeholder para país de residencia',
      behavior: GlossaryBehavior.content,
      body: [
        Paragraph(
          children: [
            TextRun.text(
              text: '[Escriba o seleccione su país]',
              textStyle: TextStyle(
                italic: true,
                color: Color(0xFF888888),
                fontSize: Point(11),
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ],
    ),
    // Placeholder for contract type
    GlossaryEntry(
      name: 'PlcHdr_TipoContrato',
      type: GlossaryEntryType.placeholder,
      category: 'Form Placeholders',
      description: 'Placeholder para tipo de contrato',
      behavior: GlossaryBehavior.content,
      body: [
        Paragraph(
          children: [
            TextRun.text(
              text: '[Seleccione tipo de contrato]',
              textStyle: TextStyle(
                italic: true,
                color: Color(0xFF888888),
                fontSize: Point(11),
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ],
    ),
    // Placeholder for start date
    GlossaryEntry(
      name: 'PlcHdr_FechaInicio',
      type: GlossaryEntryType.placeholder,
      category: 'Form Placeholders',
      description: 'Placeholder para fecha de inicio',
      behavior: GlossaryBehavior.content,
      body: [
        Paragraph(
          children: [
            TextRun.text(
              text: '[Seleccione fecha de inicio]',
              textStyle: TextStyle(
                italic: true,
                color: Color(0xFF888888),
                fontSize: Point(11),
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ],
    ),
    // Placeholder for end date
    GlossaryEntry(
      name: 'PlcHdr_FechaFin',
      type: GlossaryEntryType.placeholder,
      category: 'Form Placeholders',
      description: 'Placeholder para fecha de fin',
      behavior: GlossaryBehavior.content,
      body: [
        Paragraph(
          children: [
            TextRun.text(
              text: '[Seleccione fecha de fin]',
              textStyle: TextStyle(
                italic: true,
                color: Color(0xFF888888),
                fontSize: Point(11),
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Demo showing all SDT (Structured Document Tag) components:
/// - SdtPlainText: for single-line text inputs
/// - SdtRichText: for multi-paragraph rich text
/// - SdtDropDownList: for fixed selection options
/// - SdtComboBox: for editable drop-down selection
/// - SdtDate: for date picker controls
/// - SdtCheckbox: for binary on/off selection
///
/// This creates a contract form template with various content controls.
Future<void> main() async {
  final File outFile = File('test_resources/sdt_demo.docx');

  DocxElements.instance.ensureInitialized();
  DocxElements.instance.debugMode(true);
  final Uint8List? bytes = await runCompilation(
    SdtDemoApp(),
    logAll: true,
    options: options,
    checkStylReferences: true,
  );

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
    print('SDT Demo generated: ${outFile.path}');
  }
}

class SdtDemoApp extends StatelessWidget {
  @override
  DocxNode<dynamic> build() {
    return RootBody(
      sections: <DocxNode<dynamic>>[
        // Title
        Paragraph.text(
          id: 'title',
          text: 'FORMULARIO DE CONTRATO',
          styles: Style.ref('title').toList(),
        ),

        // Contract Description (Rich Text)
        Paragraph.text(
          id: 'section1',
          text: '1. DESCRIPCIÓN DEL CONTRATO',
          styles: Style.ref('section').toList(),
        ),

        // SdtRichText for contract clause
        SdtRichText(
          id: 'sdt_rich_1',
          tag: 'main_clause',
          alias: 'Cláusula Principal',
          placeholder: 'PlcHdr_ClausulaContrato',
          content: <DocxNode>[
            Paragraph(
              id: 'clause_para_1',
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'PRIMERA. ',
                  textStyle: TextStyle(
                    bold: true,
                    fontSize: Point(11),
                    fontFamily: 'Arial',
                  ),
                ),
                TextRun.text(
                  text: 'El presente contrato se rige por las siguientes condiciones: ',
                  textStyle: TextStyle(
                    fontSize: Point(11),
                    fontFamily: 'Arial',
                  ),
                ),
              ],
            ),
            Paragraph(
              id: 'clause_para_2',
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'SEGUNDA. ',
                  textStyle: TextStyle(
                    bold: true,
                    fontSize: Point(11),
                    fontFamily: 'Arial',
                  ),
                ),
                TextRun.text(
                  text: 'Las partes acuerdan los términos establecidos en este documento.',
                  textStyle: TextStyle(
                    fontSize: Point(11),
                    fontFamily: 'Arial',
                  ),
                ),
              ],
            ),
          ],
        ),

        // Personal Information Section
        Paragraph.text(
          id: 'section2',
          text: '2. INFORMACIÓN PERSONAL',
          styles: Style.ref('section').toList(),
        ),

        // Full Name - Plain Text
        Paragraph.text(
          id: 'label_name',
          text: 'Nombre Completo:',
          styles: Style.ref('label').toList(),
        ),
        Paragraph.text(
          id: 'hint_name',
          text: 'Ingrese su nombre y apellido tal como aparece en su documento de identidad',
          styles: Style.ref('hint').toList(),
        ),
        SdtPlainText(
          id: 'sdt_name',
          alias: 'Nombre Completo',
          tag: 'full_name',
          placeholder: 'PlcHdr_NombreCompleto',
          content: <RunBase>[
            TextRun.text(
              text: 'Juan Pérez García',
              textStyle: TextStyle(
                fontSize: Point(11),
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),

        // Email - Plain Text
        Paragraph.text(
          id: 'label_email',
          text: 'Correo Electrónico:',
          styles: Style.ref('label').toList(),
        ),
        Paragraph.text(
          id: 'hint_email',
          text: 'Ejemplo: usuario@correo.com',
          styles: Style.ref('hint').toList(),
        ),
        SdtPlainText(
          id: 'sdt_email',
          alias: 'Email',
          tag: 'email',
          placeholder: 'PlcHdr_CorreoElectronico',
          content: <RunBase>[],
        ),

        // Document Type - DropDownList
        Paragraph.text(
          id: 'label_doc_type',
          text: 'Tipo de Documento:',
          styles: Style.ref('label').toList(),
        ),
        Paragraph.text(
          id: 'hint_doc_type',
          text: 'Seleccione el tipo de documento de identidad',
          styles: Style.ref('hint').toList(),
        ),
        SdtDropDownList(
          id: 'sdt_doc_type',
          alias: 'Tipo de Documento',
          tag: 'document_type',
          placeholder: 'PlcHdr_TipoDocumento',
          items: <SdtListItem>[
            SdtListItem(displayText: 'DNI - Documento Nacional de Identidad', value: 'dni'),
            SdtListItem(displayText: 'Pasaporte', value: 'passport'),
            SdtListItem(displayText: 'NIE - Número de Identificación de Extranjero', value: 'nie'),
            SdtListItem(displayText: 'Carné de Conducir', value: 'license'),
          ],
          selectedValue: 'dni',
        ),

        // Country - ComboBox (editable)
        Paragraph.text(
          id: 'label_country',
          text: 'País de Residencia:',
          styles: Style.ref('label').toList(),
        ),
        Paragraph.text(
          id: 'hint_country',
          text: 'Seleccione o escriba su país de residencia',
          styles: Style.ref('hint').toList(),
        ),
        SdtComboBox(
          id: 'sdt_country',
          alias: 'País',
          tag: 'country',
          placeholder: 'PlcHdr_Pais',
          items: <SdtListItem>[
            SdtListItem(displayText: 'España', value: 'es'),
            SdtListItem(displayText: 'Francia', value: 'fr'),
            SdtListItem(displayText: 'Alemania', value: 'de'),
            SdtListItem(displayText: 'Italia', value: 'it'),
            SdtListItem(displayText: 'Portugal', value: 'pt'),
            SdtListItem(displayText: 'Otro', value: 'other'),
          ],
          selectedValue: 'es',
        ),

        // Contract Details Section
        Paragraph.text(
          id: 'section3',
          text: '3. DETALLES DEL CONTRATO',
          styles: Style.ref('section').toList(),
        ),

        // Contract Type - DropDownList
        Paragraph.text(
          id: 'label_contract_type',
          text: 'Tipo de Contrato:',
          styles: Style.ref('label').toList(),
        ),
        Paragraph.text(
          id: 'hint_contract_type',
          text: 'Seleccione el tipo de contrato laboral',
          styles: Style.ref('hint').toList(),
        ),
        SdtDropDownList(
          id: 'sdt_contract_type',
          alias: 'Tipo de Contrato',
          tag: 'contract_type',
          placeholder: 'PlcHdr_TipoContrato',
          items: <SdtListItem>[
            SdtListItem(displayText: 'Contrato Indefinido', value: 'permanent'),
            SdtListItem(displayText: 'Contrato Temporal', value: 'temporary'),
            SdtListItem(displayText: 'Contrato de Prácticas', value: 'internship'),
            SdtListItem(displayText: 'Contrato de Autónomo', value: 'freelance'),
          ],
          selectedValue: 'permanent',
        ),

        // Start Date - Date Picker
        Paragraph.text(
          id: 'label_start_date',
          text: 'Fecha de Inicio:',
          styles: Style.ref('label').toList(),
        ),
        Paragraph.text(
          id: 'hint_start_date',
          text: 'Seleccione la fecha de inicio del contrato',
          styles: Style.ref('hint').toList(),
        ),
        SdtDate(
          id: 'sdt_start_date',
          alias: 'Fecha de Inicio',
          tag: 'start_date',
          dateFormat: 'dd/MM/yyyy',
          locale: 'es-ES',
          calendar: SdtCalendar.gregorian,
          placeholder: 'PlcHdr_FechaInicio',
          value: DateTime(2026, 6, 1),
        ),

        // End Date - Date Picker
        Paragraph.text(
          id: 'label_end_date',
          text: 'Fecha de Fin:',
          styles: Style.ref('label').toList(),
        ),
        Paragraph.text(
          id: 'hint_end_date',
          text: 'Seleccione la fecha de finalización del contrato (dejar en blanco si es indefinido)',
          styles: Style.ref('hint').toList(),
        ),
        SdtDate(
          id: 'sdt_end_date',
          alias: 'Fecha de Fin',
          tag: 'end_date',
          dateFormat: 'dd/MM/yyyy',
          locale: 'es-ES',
          calendar: SdtCalendar.gregorian,
          placeholder: 'PlcHdr_FechaFin',
          value: DateTime(2027, 6, 1),
        ),

        // Salary - Plain Text (number)
        Paragraph.text(
          id: 'label_salary',
          text: 'Salario Anual (EUR):',
          styles: Style.ref('label').toList(),
        ),
        Paragraph.text(
          id: 'hint_salary',
          text: 'Ingrese el salario bruto anual en euros (sin decimales)',
          styles: Style.ref('hint').toList(),
        ),
        SdtPlainText(
          id: 'sdt_salary',
          alias: 'Salario',
          tag: 'annual_salary',
          placeholder: 'PlcHdr_Salario',
          maxLength: 10,
          content: <RunBase>[
            TextRun.text(
              text: '35.000',
              textStyle: TextStyle(
                fontSize: Point(11),
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),

        // Terms and Conditions Section
        Paragraph.text(
          id: 'section4',
          text: '4. TÉRMINOS Y CONDICIONES',
          styles: Style.ref('section').toList(),
        ),

        // Checkbox for terms acceptance
        SdtCheckbox(
          id: 'sdt_terms',
          alias: 'Aceptar Términos',
          tag: 'accept_terms',
          checked: true,
          checkedState: SdtCheckboxState.checked,
          uncheckedState: SdtCheckboxState.unchecked,
        ),

        // Space after checkbox
        Paragraph.text(
          id: 'terms_text',
          text: 'He leído y acepto los términos y condiciones del contrato.',
          textStyle: TextStyle(
            fontSize: Point(10),
            fontFamily: 'Arial',
          ),
        ),

        // Second checkbox
        SdtCheckbox(
          id: 'sdt_newsletter',
          alias: 'Suscribir a Newsletter',
          tag: 'subscribe_newsletter',
          checked: false,
          checkedState: SdtCheckboxState.checkmark,
          uncheckedState: SdtCheckboxState.unchecked,
        ),

        Paragraph.text(
          id: 'newsletter_text',
          text: 'Deseo recibir información sobre productos y ofertas.',
          textStyle: TextStyle(
            fontSize: Point(10),
            fontFamily: 'Arial',
          ),
        ),

        // Privacy checkbox
        SdtCheckbox(
          id: 'sdt_privacy',
          alias: 'Aceptar Política de Privacidad',
          tag: 'accept_privacy',
          checked: true,
        ),

        Paragraph.text(
          id: 'privacy_text',
          text: 'Acepto la política de privacidad y el tratamiento de mis datos personales conforme al RGPD.',
          textStyle: TextStyle(
            fontSize: Point(10),
            fontFamily: 'Arial',
          ),
        ),

        // Signature Section
        Paragraph.text(
          id: 'section5',
          text: '5. FIRMA',
          styles: Style.ref('section').toList(),
        ),

        // Notes - Rich Text
        Paragraph.text(
          id: 'label_notes',
          text: 'Notas Adicionales:',
          styles: Style.ref('label').toList(),
        ),
        Paragraph.text(
          id: 'hint_notes',
          text: 'Escriba cualquier observación o nota adicional relevante',
          styles: Style.ref('hint').toList(),
        ),
        SdtRichText(
          id: 'sdt_notes',
          alias: 'Notas Adicionales',
          tag: 'additional_notes',
          placeholder: 'PlcHdr_NotasAdicionales',
          content: <DocxNode>[
            Paragraph(
              id: 'notes_para_1',
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'Observaciones: ',
                  textStyle: TextStyle(
                    bold: true,
                    fontSize: Point(10),
                    fontFamily: 'Arial',
                  ),
                ),
                TextRun.text(
                  text: 'El contrato está sujeto a condiciones específicas del sector.',
                  textStyle: TextStyle(
                    fontSize: Point(10),
                    fontFamily: 'Arial',
                  ),
                ),
              ],
            ),
          ],
        ),

        // Picture placeholder
        Paragraph.text(
          id: 'label_signature',
          text: 'Firma:',
          styles: Style.ref('label').toList(),
        ),
        Paragraph.text(
          id: 'hint_signature',
          text: 'Haga clic aquí para insertar su firma',
          styles: Style.ref('hint').toList(),
        ),
        SdtPicture(
          id: 'sdt_signature',
          alias: 'Firma',
          tag: 'signature_image',
          placeholder: 'PlcHdr_Firma',
        ),

        // Date of signature
        Paragraph.text(
          id: 'label_sig_date',
          text: 'Fecha de Firma:',
          styles: Style.ref('label').toList(),
        ),
        SdtDate(
          id: 'sdt_sig_date',
          alias: 'Fecha de Firma',
          tag: 'signature_date',
          dateFormat: 'dd/MM/yyyy',
          locale: 'es-ES',
          calendar: SdtCalendar.gregorian,
          placeholder: 'Seleccione la fecha de firma',
          value: DateTime.now(),
        ),

        // Locked fields demonstration
        Paragraph.text(
          id: 'section6',
          text: '6. CAMPOS DEL SISTEMA',
          styles: Style.ref('section').toList(),
        ),
        Paragraph.text(
          id: 'hint_locked',
          text: 'Los siguientes campos son de solo lectura y se completan automáticamente',
          styles: Style.ref('hint').toList(),
        ),

        // Locked Plain Text
        Paragraph.text(
          id: 'label_id',
          text: 'ID de Empleado:',
          styles: Style.ref('label').toList(),
        ),
        SdtPlainText(
          id: 'sdt_employee_id',
          alias: 'ID de Empleado',
          tag: 'employee_id',
          placeholder: '[Campo automático]',
          lock: StdLock.lock,
          content: <RunBase>[
            TextRun.text(
              text: 'EMP-2026-001',
              textStyle: TextStyle(
                fontSize: Point(11),
                fontFamily: 'Arial',
                italic: true,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),

        // Temporary field
        Paragraph.text(
          id: 'label_temp',
          text: 'Código de Verificación:',
          styles: Style.ref('label').toList(),
        ),
        Paragraph.text(
          id: 'hint_temp',
          text: 'Este código expire al cerrar el documento',
          styles: Style.ref('hint').toList(),
        ),
        SdtPlainText(
          id: 'sdt_temp_field',
          alias: 'Código de Verificación',
          tag: 'temp_field',
          placeholder: '[Código temporal]',
          temporary: true,
          content: <RunBase>[
            TextRun.text(
              text: 'TMP-1234-ABCD',
              textStyle: TextStyle(
                fontSize: Point(11),
                fontFamily: 'Arial',
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
