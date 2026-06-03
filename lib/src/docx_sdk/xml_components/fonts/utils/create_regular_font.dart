import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../../../../docx.dart';

const Uuid _uuid = Uuid();

/// Generates [FontProperties] for a common "regular" font, often used for embedded fonts.
/// This simplifies the creation process by pre-populating common signature, family, and pitch settings.
///
/// [name] The actual name of the font (e.g., "Arial").
/// [bytes] The actual binary data of the font file.
/// [extension] The original file extension of the font (e.g., 'ttf', 'otf').
/// [characterSet] The character set of the font. Defaults to `CharacterSet.ansi`.
/// [altName] An optional alternative name for the font.
/// [fontKey] An optional GUID used for font obfuscation. If not provided, a new one will be generated.
FontProperties createRegularEmbeddedFontProperties({
  required String name,
  required Uint8List bytes,
  required String extension,
  CharacterSet characterSet = CharacterSet.ansi,
  String? altName,
  String? fontKey, // Now optional, can be generated
}) {
  final String actualFontKey = fontKey ?? generateFontGuid();

  return FontProperties(
    name: name,
    altName: altName,
    panose1: '020F0502020204030204', // Example Panose1, adjust as needed
    sigUsb0: 'E0002AFF',
    sigUsb1: 'C000247B',
    sigUsb2: '00000009',
    sigUsb3: '00000000',
    sigCsb0: '000001FF',
    sigCsb1: '00000000',
    charset: characterSet,
    family: 'auto',
    pitch: 'variable',
    fontBinaryData: FontBinaryData(
      fontKey: actualFontKey,
      bytes: bytes,
      extension: extension,
    ),
    // embedRId will be set by FontStore when the font is added
  );
}

/// Generates a basic [FontProperties] for a font that is *not* embedded,
/// but merely referenced by name in the document.
FontProperties createReferencedFontProperties({
  required String name,
  CharacterSet characterSet = CharacterSet.ansi,
  String? altName,
  String? panose1,
  String? family,
  String? pitch,
  String? sigUsb0,
  String? sigUsb1,
  String? sigUsb2,
  String? sigUsb3,
  String? sigCsb0,
  String? sigCsb1,
}) {
  return FontProperties(
    name: name,
    altName: altName,
    panose1: panose1,
    charset: characterSet,
    family: family,
    pitch: pitch,
    sigUsb0: sigUsb0,
    sigUsb1: sigUsb1,
    sigUsb2: sigUsb2,
    sigUsb3: sigUsb3,
    sigCsb0: sigCsb0,
    sigCsb1: sigCsb1,
    fontBinaryData: null, // Not embedded
  );
}

/// Generates a unique GUID string suitable for fontKey.
String generateFontGuid() {
  return _uuid.v4().toUpperCase().replaceAll('-', '');
}
