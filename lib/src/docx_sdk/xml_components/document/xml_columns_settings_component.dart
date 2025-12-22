import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';

/// Represents the `<w:cols>` element in WordML, defining the column layout
/// for a section of the document.
///
/// This component is typically a child of `<w:sectPr>`.
class XmlColumnsSettingsComponent extends XmlComponentBase<ColumnSettings> {
  XmlColumnsSettingsComponent({
    required ColumnSettings settings,
  }) : super(
          value: settings,
          xmlKey: 'w:cols',
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    final List<XmlAttribute> attributes = [];

    // w:num attribute
    if (value.numColumns != null) {
      attributes.add(
        XmlAttribute(
          'w:num'.toName(),
          value.numColumns.toString(),
        ),
      );
    }

    // w:space attribute
    if (value.space != null) {
      attributes.add(
        XmlAttribute(
          'w:space'.toName(),
          value.space.toString(),
        ),
      );
    }

    // w:sep attribute
    if (value.separator != null) {
      attributes.add(
        XmlAttribute(
          'w:sep'.toName(),
          value.separator! ? '1' : '0',
        ),
      );
    }

    // w:equalWidth attribute
    // Only add if explicitly false, or if true but numColumns is not set (Word default is 1)
    if (!value.equalWidth) {
      attributes.add(
        XmlAttribute('w:equalWidth'.toName(), '0'),
      );
    } else if (value.equalWidth == true && value.numColumns != null) {
      // If equalWidth is true and numColumns is set, explicitly set equalWidth to 1
      attributes.add(
        XmlAttribute(
          'w:equalWidth'.toName(),
          '1',
        ),
      );
    }

    final List<XmlNode> children = [];

    // Add individual <w:col> elements if equalWidth is false and columnWidths are provided
    if (value.equalWidth == false && value.columnWidths != null) {
      for (final ColumnWidthSetting colSetting in value.columnWidths!) {
        final List<XmlAttribute> colAttrs = [
          XmlAttribute(
            'w:w'.toName(),
            colSetting.width.toString(),
          ),
        ];
        if (colSetting.spaceAfter != null) {
          colAttrs.add(
            XmlAttribute(
              'w:space'.toName(),
              colSetting.spaceAfter.toString(),
            ),
          );
        }
        children.add(
          XmlElement.tag(
            'w:col',
            attributes: colAttrs,
            isSelfClosing: true,
          ),
        );
      }
    }

    return XmlElement.tag(
      xmlKey,
      attributes: attributes,
      children: children,
    );
  }
}
