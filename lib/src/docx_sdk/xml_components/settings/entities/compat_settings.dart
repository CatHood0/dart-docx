import 'package:xml/xml.dart';

/// Represents a compatibility setting within the Word document settings.
class CompatSetting {
  /// Creates a new [CompatSetting].
  ///
  /// [name] is the name of the compatibility setting (e.g., 'compatibilityMode').
  /// [uri] is the URI associated with the setting.
  /// [val] is the value of the setting (e.g., '15' for Word 2013 compatibility).
  const CompatSetting({
    required this.name,
    required this.uri,
    required this.val,
  });

  /// The name of the compatibility setting.
  final String name;

  /// The URI associated with the compatibility setting.
  final String uri;

  /// The value of the compatibility setting.
  final String val;

  /// Builds the XML element for this compatibility setting.
  XmlElement buildXml() {
    return XmlElement(
      XmlName('w:compatSetting'),
      [
        XmlAttribute(XmlName('w:name'), name),
        XmlAttribute(XmlName('w:uri'), uri),
        XmlAttribute(XmlName('w:val'), val),
      ],
    );
  }
}
