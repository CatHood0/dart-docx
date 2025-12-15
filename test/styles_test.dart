import 'package:docx/docx.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Style.getDeepStyleRelation', () {
    Style createStyle({
      required String styleId,
      required String styleName,
      String type = 'paragraph',
      String? basedOnId,
      List<StyleConfigurator>? configurators,
    }) {
      final List<StyleConfigurator> allConfigurators = [];
      if (basedOnId != null) {
        allConfigurators.add(StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'basedOn',
          value: basedOnId,
        ));
      }
      if (configurators != null) {
        allConfigurators.addAll(configurators);
      }
      return Style(
        type: type,
        styleId: styleId,
        styleName: styleName,
        configurators: allConfigurators,
      );
    }

    test(
        'should return the same style '
        'if it has no basedOn property', () {
      final Style style = createStyle(styleId: 'Normal', styleName: 'Normal');
      final DocumentStylesSheet stylesSheet = DocumentStylesSheet(
        styles: [
          style,
        ],
      );

      final Style deepStyle = style.getDeepStyleRelation(stylesSheet);

      expect(deepStyle.styleId, 'Normal');
      expect(deepStyle.configurators, isEmpty);
    });

    test('should merge properties from a single parent style', () {
      final Style parentStyle = createStyle(
        styleId: 'Parent',
        styleName: 'Parent',
        configurators: [
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pPr',
            configurators: [
              StyleConfigurator.selfClosing(
                  prefix: 'w', propertyName: 'jc', value: 'left'),
              StyleConfigurator.selfClosing(
                  prefix: 'w', propertyName: 'spacing', value: 200),
            ],
          ),
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'rPr',
            configurators: [
              StyleConfigurator.selfClosing(
                  prefix: 'w', propertyName: 'sz', value: '24'),
            ],
          ),
          StyleConfigurator.selfClosing(
              prefix: 'w', propertyName: 'next', value: 'Sibling'),
        ],
      );

      final Style childStyle = createStyle(
        styleId: 'Child',
        styleName: 'Child',
        basedOnId: 'Parent',
        configurators: [
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pPr',
            configurators: [
              StyleConfigurator.selfClosing(
                prefix: 'w',
                propertyName: 'jc',
                value: 'center',
              ), // Override
            ],
          ),
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'uiPriority',
            value: '10',
          ), // New top-level
        ],
      );

      final DocumentStylesSheet stylesSheet =
          DocumentStylesSheet(styles: <Style>[parentStyle, childStyle]);
      final Style deepStyle = childStyle.getDeepStyleRelation(stylesSheet);

      expect(deepStyle.styleId, 'Child');

      final pPr = deepStyle.getConfigurator('w:pPr');
      expect(pPr, isNotNull);
      expect(pPr.getConfiguratorOrNull('w:jc')?.value, 'center'); // Overridden
      expect(pPr.getConfiguratorOrNull('w:spacing')?.value, 200); // Inherited

      final rPr = deepStyle.getConfiguratorOrNull('w:rPr');
      expect(rPr, isNotNull);
      expect(rPr!.getConfiguratorOrNull('w:sz')?.value, '24'); // Inherited

      expect(
        deepStyle.getConfiguratorOrNull('w:next')?.value,
        'Sibling',
      ); // Inherited top-level
      expect(
        deepStyle.getConfiguratorOrNull('w:uiPriority')?.value,
        '10',
      ); // New top-level
    });

    test(
        'should merge properties from a '
        'multi-level inheritance chain (A -> B -> C)', () {
      final Style styleA = createStyle(
        styleId: 'StyleA',
        styleName: 'Style A',
        configurators: [
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pPr',
            configurators: [
              StyleConfigurator.selfClosing(
                prefix: 'w',
                propertyName: 'jc',
                value: 'left',
              ),
              StyleConfigurator.selfClosing(
                prefix: 'w',
                propertyName: 'spacing',
                value: '100',
              ),
            ],
          ),
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'rPr',
            configurators: [
              StyleConfigurator.selfClosing(
                prefix: 'w',
                propertyName: 'sz',
                value: '20',
              ),
            ],
          ),
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'next',
            value: 'NextA',
          ),
        ],
      );

      final Style styleB = createStyle(
        styleId: 'StyleB',
        styleName: 'Style B',
        basedOnId: 'StyleA',
        configurators: <StyleConfigurator>[
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pPr',
            configurators: <StyleConfigurator>[
              StyleConfigurator.selfClosing(
                  prefix: 'w',
                  propertyName: 'spacing',
                  value: '150'), // Override
              StyleConfigurator.selfClosing(
                  prefix: 'w', propertyName: 'indent', value: '100'), // New
            ],
          ),
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'rPr',
            configurators: [
              StyleConfigurator.selfClosing(
                prefix: 'w',
                propertyName: 'b',
              ), // New bold
            ],
          ),
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'next',
            value: 'NextB',
          ), // Override
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'uiPriority',
            value: '5',
          ), // New top-level
        ],
      );

      final Style styleC = createStyle(
        styleId: 'StyleC',
        styleName: 'Style C',
        basedOnId: 'StyleB',
        configurators: [
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pPr',
            configurators: [
              StyleConfigurator.selfClosing(
                  prefix: 'w',
                  propertyName: 'jc',
                  value: 'right'), // Override from A
            ],
          ),
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'rPr',
            configurators: [
              StyleConfigurator.selfClosing(
                  prefix: 'w',
                  propertyName: 'sz',
                  value: '30'), // Override from A
              StyleConfigurator.selfClosing(
                  prefix: 'w', propertyName: 'i'), // New italic
            ],
          ),
          StyleConfigurator.selfClosing(
              prefix: 'w', propertyName: 'uiPriority', value: '15'), // Override
        ],
      );

      final DocumentStylesSheet stylesSheet =
          DocumentStylesSheet(styles: [styleA, styleB, styleC]);
      final deepStyle = styleC.getDeepStyleRelation(stylesSheet);

      expect(deepStyle.styleId, 'StyleC');

      final StyleConfigurator? pPr = deepStyle.getConfiguratorOrNull('w:pPr');
      expect(pPr, isNotNull);
      expect(
          pPr!.getConfiguratorOrNull('w:jc')?.value, 'right'); // C overrides A
      expect(pPr.getConfiguratorOrNull('w:spacing')?.value,
          '150'); // B overrides A
      expect(pPr.getConfiguratorOrNull('w:indent')?.value, '100'); // B new

      final rPr = deepStyle.getConfiguratorOrNull('w:rPr');
      expect(rPr, isNotNull);
      expect(rPr!.getConfiguratorOrNull('w:sz')?.value, '30'); // C overrides A
      expect(rPr.getConfiguratorOrNull('w:b'), isNotNull); // B new
      expect(rPr.getConfiguratorOrNull('w:i'), isNotNull); // C new

      expect(
        deepStyle.getConfiguratorOrNull('w:next')?.value,
        'NextB',
      ); // B overrides A
      expect(
        deepStyle.getConfiguratorOrNull('w:uiPriority')?.value,
        '15',
      ); // C overrides B
    });

    test(
        'should handle non-existent '
        'basedOn styles gracefully', () {
      final Style style = createStyle(
        styleId: 'Orphan',
        styleName: 'Orphan',
        basedOnId: 'NonExistent',
        configurators: [
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'foo',
            value: 'bar',
          ),
        ],
      );
      final DocumentStylesSheet stylesSheet = DocumentStylesSheet(
        styles: [
          style,
        ],
      );

      final Style deepStyle = style.getDeepStyleRelation(stylesSheet);

      // The 'w:basedOn' configurator is filtered out in getDeepStyleRelation,
      // so only 'w:foo' should remain as a top-level configurator.
      expect(
        deepStyle.configurators.length,
        1,
      );
      expect(
        deepStyle.getConfiguratorOrNull('w:foo')?.value,
        'bar',
      );
    });

    test(
        'should correctly merge nested '
        'configurators within w:pPr', () {
      final baseStyle = createStyle(
        styleId: 'Base',
        styleName: 'Base',
        configurators: [
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pPr',
            configurators: [
              StyleConfigurator.noSelfClosing(
                prefix: 'w',
                propertyName: 'spacing',
                configurators: [
                  StyleConfigurator.selfClosing(
                      prefix: 'w', propertyName: 'before', value: '100'),
                  StyleConfigurator.selfClosing(
                      prefix: 'w', propertyName: 'line', value: '240'),
                ],
              ),
              StyleConfigurator.noSelfClosing(
                prefix: 'w',
                propertyName: 'ind',
                configurators: [
                  StyleConfigurator.selfClosing(
                      prefix: 'w', propertyName: 'left', value: '300'),
                ],
              ),
            ],
          ),
        ],
      );

      final derivedStyle = createStyle(
        styleId: 'Derived',
        styleName: 'Derived',
        basedOnId: 'Base',
        configurators: [
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pPr',
            configurators: [
              StyleConfigurator.noSelfClosing(
                prefix: 'w',
                propertyName: 'spacing',
                configurators: [
                  StyleConfigurator.selfClosing(
                      prefix: 'w', propertyName: 'after', value: '50'), // New
                  StyleConfigurator.selfClosing(
                    prefix: 'w',
                    propertyName: 'before',
                    value: '200',
                  ), // Override
                ],
              ),
            ],
          ),
        ],
      );

      final stylesSheet =
          DocumentStylesSheet(styles: [baseStyle, derivedStyle]);
      final deepStyle = derivedStyle.getDeepStyleRelation(stylesSheet);

      // print(deepStyle?.toNode()?.toXmlString(pretty: true));
      final pPr = deepStyle.getConfiguratorOrNull('w:pPr');
      expect(pPr, isNotNull);

      final spacing = pPr!.getConfiguratorOrNull('w:spacing');
      // print(spacing?.toXmlNode.toXmlString(pretty: true));
      expect(spacing, isNotNull);
      expect(
        spacing!.getConfiguratorOrNull('w:before')?.value,
        '200',
      ); // Derived overrides Base
      expect(
        spacing.getConfiguratorOrNull('w:after')?.value,
        '50',
      ); // Derived new
      expect(
        spacing.getConfiguratorOrNull('w:line')?.value,
        '240',
      ); // Base inherited

      final ind = pPr.getConfiguratorOrNull('w:ind');
      expect(
        ind,
        isNotNull,
      );
      expect(
        ind!.getConfiguratorOrNull('w:left')?.value, // Look inside 'ind'
        '300',
      ); // Base inherited
    });

    test('should handle circular basedOn references without infinite loop', () {
      final styleA = createStyle(
        styleId: 'StyleA',
        styleName: 'Style A',
        basedOnId: 'StyleB', // Circular reference
      );
      final styleB = createStyle(
        styleId: 'StyleB',
        styleName: 'Style B',
        basedOnId: 'StyleA', // Circular reference
        configurators: [
          StyleConfigurator.selfClosing(
              prefix: 'w', propertyName: 'valueB', value: 'B'),
        ],
      );

      // A styles sheet with the circular styles
      final stylesSheet = DocumentStylesSheet(styles: [styleA, styleB]);

      // When calling getDeepStyleRelation on styleA, it should not loop infinitely
      final deepStyle = styleA.getDeepStyleRelation(stylesSheet);

      expect(deepStyle.styleId, 'StyleA');
      // Should contain styleA's initial configurators and styleB's if it was added before detection
      // The current logic inserts at the beginning and checks if already in hierarchy,
      // so it should stop before re-adding, meaning only one circular path is followed.
      // In this specific case, styleA starts, tries to get StyleB, adds StyleB.
      // StyleB tries to get StyleA, finds it in hierarchy, and stops.
      // So, the final hierarchy will be [StyleB, StyleA].
      final StyleConfigurator? valueBConfig =
          deepStyle.getConfiguratorOrNull('w:valueB');
      expect(valueBConfig?.value, 'B'); // Value from B should be present.
    });

    test(
        'should ensure the returned style ID and name are from the original style',
        () {
      final baseStyle = createStyle(
        styleId: 'Base',
        styleName: 'Base Name',
        configurators: [
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'someProp',
            value: 'base',
          ),
        ],
      );

      final childStyle = createStyle(
        styleId: 'Child',
        styleName: 'Child Name',
        basedOnId: 'Base',
        configurators: [
          StyleConfigurator.selfClosing(
              prefix: 'w', propertyName: 'anotherProp', value: 'child'),
        ],
      );

      final DocumentStylesSheet stylesSheet = DocumentStylesSheet(styles: [
        baseStyle,
        childStyle,
      ]);
      final deepStyle = childStyle.getDeepStyleRelation(stylesSheet);

      expect(deepStyle.styleId, 'Child');
      expect(deepStyle.styleName, 'Child Name');
      expect(deepStyle.getConfiguratorOrNull('w:someProp')?.value, 'base');
      expect(deepStyle.getConfiguratorOrNull('w:anotherProp')?.value, 'child');
    });
  });
}
