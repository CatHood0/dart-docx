import '../../../../../docx.dart';

/// SDT (Structured Document Tags) Content Controls
///
/// This module provides Content Control components for Word documents.
///
/// ## Available Components:
/// - [SdtPlainText] - Single-line plain text input
/// - [SdtRichText] - Multi-paragraph rich text input
/// - [SdtDropDownList] - Drop-down list with fixed options
/// - [SdtComboBox] - Editable drop-down (allows custom text)
/// - [SdtDate] - Date picker with calendar
/// - [SdtCheckbox] - Checkbox control
/// - [SdtPicture] - Image placeholder control

export 'sdt_checkbox.dart';
export 'sdt_combo_box.dart';
export 'sdt_date.dart';
export 'sdt_drop_down_list.dart';
export 'sdt_enums.dart';
export 'sdt_list_item.dart';
export 'sdt_picture.dart';
export 'sdt_plain_text.dart';
export 'sdt_rich_text.dart';

abstract class Sdt<T> extends DocxNode<T> {
  Sdt({
    required super.child,
    super.id,
    super.parent,
    this.sdtId,
  });

  /// Optional unique identifier for the SDT.
  /// Note: This is different from DocxNode.id which is auto-generated.
  final int? sdtId;
}
