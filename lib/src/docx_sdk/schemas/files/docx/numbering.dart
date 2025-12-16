import '../../../../../docx.dart';
import '../../../xml_components/numbering/formats.dart';
import '../../../xml_components/numbering/level_options.dart';

List<NumberingOptions> genDefaultNumberingOptions() => <NumberingOptions>[
      NumberingOptions(
        refKey: 'unordered',
        levels: <LevelOptions>[
          LevelOptions(
            level: 0,
            format: LevelFormat.bullet,
            text: '\u25CF',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: inchToFromTwip(0.5).toInt(),
                  hanging: inchToFromTwip(0.25).toInt(),
                )
                .build(),
          ),
          LevelOptions(
            level: 1,
            format: LevelFormat.bullet,
            text: '\u25CF',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: inchToFromTwip(1).toInt(),
                  hanging: inchToFromTwip(0.25).toInt(),
                )
                .build(),
          ),
          LevelOptions(
            level: 2,
            format: LevelFormat.bullet,
            text: '\u25CF',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 2160,
                  hanging: inchToFromTwip(0.25).toInt(),
                )
                .build(),
          ),
          LevelOptions(
            level: 3,
            format: LevelFormat.bullet,
            text: '\u25CF',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 2880,
                  hanging: inchToFromTwip(0.25).toInt(),
                )
                .build(),
          ),
          LevelOptions(
            level: 4,
            format: LevelFormat.bullet,
            text: '\u25CF',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 3600,
                  hanging: inchToFromTwip(0.25).toInt(),
                )
                .build(),
          ),
          LevelOptions(
            level: 5,
            format: LevelFormat.bullet,
            text: '\u25CF',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 4320,
                  hanging: inchToFromTwip(0.25).toInt(),
                )
                .build(),
          ),
          LevelOptions(
            level: 6,
            format: LevelFormat.bullet,
            text: '\u25CF',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 5040,
                  hanging: inchToFromTwip(0.25).toInt(),
                )
                .build(),
          ),
          LevelOptions(
            level: 7,
            format: LevelFormat.bullet,
            text: '\u25CF',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 5760,
                  hanging: inchToFromTwip(0.25).toInt(),
                )
                .build(),
          ),
          LevelOptions(
            level: 8,
            format: LevelFormat.bullet,
            text: '\u25CF',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 6480,
                  hanging: inchToFromTwip(0.25).toInt(),
                )
                .build(),
          ),
        ],
      ),
      NumberingOptions(
        refKey: 'ordered',
        levels: <LevelOptions>[
          LevelOptions(
            level: 0,
            format: LevelFormat.decimal,
            text: '%1.',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 720,
                  hanging: 360,
                )
                .build(),
          ),
          LevelOptions(
            level: 1,
            format: LevelFormat.lowerLetter,
            text: '%1.',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 1440,
                  hanging: 360,
                )
                .build(),
          ),
          LevelOptions(
            level: 2,
            format: LevelFormat.lowerRoman,
            text: '%1.',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 2160,
                  hanging: 360,
                )
                .build(),
          ),
          LevelOptions(
            level: 3,
            format: LevelFormat.decimal,
            text: '%1.',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 2880,
                  hanging: 360,
                )
                .build(),
          ),
          LevelOptions(
            level: 4,
            format: LevelFormat.lowerLetter,
            text: '%1.',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 3600,
                  hanging: 360,
                )
                .build(),
          ),
          LevelOptions(
            level: 5,
            format: LevelFormat.lowerRoman,
            text: '%1.',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 4320,
                  hanging: 360,
                )
                .build(),
          ),
          LevelOptions(
            level: 6,
            format: LevelFormat.decimal,
            text: '%1.',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 5040,
                  hanging: 360,
                )
                .build(),
          ),
          LevelOptions(
            level: 7,
            format: LevelFormat.lowerLetter,
            text: '%1.',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 5760,
                  hanging: 360,
                )
                .build(),
          ),
          LevelOptions(
            level: 8,
            format: LevelFormat.lowerRoman,
            text: '%1.',
            start: 1,
            paragraphStyle: StyleBuilder.singularP()
                .indent(
                  left: 6480,
                  hanging: 360,
                )
                .build(),
          ),
        ],
      ),
    ];
