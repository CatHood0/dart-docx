import 'package:xml/xml.dart';

import 'gradient_stop_options.dart';

/// Options for a gradient stop list.
class GradientStopListOptions {
  const GradientStopListOptions({
    required this.stops,
  });

  final List<GradientStopOptions> stops;

  XmlElement buildXml() {
    return XmlElement.tag(
      'a:gsLst',
      children: stops
          .map((
            GradientStopOptions e,
          ) =>
              e.buildXml())
          .toList(),
    );
  }
}
