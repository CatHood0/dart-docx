import 'dart:typed_data';

import '../../../docx.dart';
import 'docx_compiler.dart';
import 'events/docx_event.dart';
import 'packer/docx_metadata_packer.dart';

//TODO: add insert, delete, and replacement capabilities
class DocxSdk {
  DocxSdk({DocxDocument? object}) : lastDocumentObject = object;
  DocxDocument? lastDocumentObject;

  // to allow modifying certain parts of the docx result
  // we can implement these methods
  void insert(
    int start,
    Object data,
  ) {}
  void replace(
    int start,
    int end,
    Object data,
  ) {}
  void delete(
    int start,
    int end,
  ) {}
}
