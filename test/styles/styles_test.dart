import 'package:docx/docx.dart';
import 'package:test/test.dart';

void main() {
  group('Style.getDeepStyleRelation', () {
    Style createStyle({
      required String styleId,
      String? styleName,
      String type = 'paragraph',
      String? basedOnId,
      List<StyleConfigurator>? configurators,
    }) {
      final List<StyleConfigurator> allConfigurators = <StyleConfigurator>[];
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
      final Style style = createStyle(styleId: 'Normal');
      final DocumentStyles stylesSheet = DocumentStyles(
        latentStyles: LatentStyles.base(),
        styles: <String, Style>{
          style.styleId: style,
        },
      );

      final Style deepStyle = style.resolveStyle(stylesSheet);

      expect(deepStyle.styleId, 'Normal');
      expect(deepStyle.configurators, isEmpty);
    });

    test('should merge properties from a single parent style', () {
      final Style parentStyle = createStyle(
        styleId: 'Parent',
        styleName: 'Parent',
        configurators: <StyleConfigurator>[
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pPr',
            configurators: <StyleConfigurator>[
              StyleConfigurator.selfClosing(
                  prefix: 'w', propertyName: 'jc', value: 'left'),
              StyleConfigurator.selfClosing(
                  prefix: 'w', propertyName: 'spacing', value: 200),
            ],
          ),
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'rPr',
            configurators: <StyleConfigurator>[
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
        configurators: <StyleConfigurator>[
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pPr',
            configurators: <StyleConfigurator>[
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

      final DocumentStyles stylesSheet = DocumentStyles(
        latentStyles: LatentStyles.base(),
        styles: <String, Style>{
          parentStyle.styleId: parentStyle,
          childStyle.styleId: childStyle,
        },
      );
      final Style deepStyle = childStyle.resolveStyle(stylesSheet);

      expect(deepStyle.styleId, 'Child');

      final StyleConfigurator pPr = deepStyle.getConfigurator('w:pPr');
      expect(pPr, isNotNull);
      expect(pPr.getConfiguratorOrNull('w:jc')?.value, 'center'); // Overridden
      expect(pPr.getConfiguratorOrNull('w:spacing')?.value, 200); // Inherited

      final StyleConfigurator? rPr = deepStyle.getConfiguratorOrNull('w:rPr');
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
        configurators: <StyleConfigurator>[
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pPr',
            configurators: <StyleConfigurator>[
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
            configurators: <StyleConfigurator>[
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
            configurators: <StyleConfigurator>[
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
        configurators: <StyleConfigurator>[
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pPr',
            configurators: <StyleConfigurator>[
              StyleConfigurator.selfClosing(
                  prefix: 'w',
                  propertyName: 'jc',
                  value: 'right'), // Override from A
            ],
          ),
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'rPr',
            configurators: <StyleConfigurator>[
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

      final DocumentStyles stylesSheet = DocumentStyles(
        latentStyles: LatentStyles.base(),
        styles: <String, Style>{
          styleA.styleId: styleA,
          styleB.styleId: styleB,
          styleC.styleId: styleC,
        },
      );
      final Style deepStyle = styleC.resolveStyle(stylesSheet);

      expect(deepStyle.styleId, 'StyleC');

      final StyleConfigurator? pPr = deepStyle.getConfiguratorOrNull('w:pPr');
      expect(pPr, isNotNull);
      expect(
          pPr!.getConfiguratorOrNull('w:jc')?.value, 'right'); // C overrides A
      expect(pPr.getConfiguratorOrNull('w:spacing')?.value,
          '150'); // B overrides A
      expect(pPr.getConfiguratorOrNull('w:indent')?.value, '100'); // B new

      final StyleConfigurator? rPr = deepStyle.getConfiguratorOrNull('w:rPr');
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
        configurators: <StyleConfigurator>[
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'foo',
            value: 'bar',
          ),
        ],
      );
      final DocumentStyles stylesSheet = DocumentStyles(
        latentStyles: LatentStyles.base(),
        styles: <String, Style>{
          style.styleId: style,
        },
      );

      final Style deepStyle = style.resolveStyle(stylesSheet);

      expect(
        deepStyle.configurators.length,
        2,
      );
      expect(
        deepStyle.getConfiguratorOrNull('w:foo')?.value,
        'bar',
      );
    });

    test(
        'should correctly merge nested '
        'configurators within w:pPr', () {
      final Style baseStyle = createStyle(
        styleId: 'Base',
        styleName: 'Base',
        configurators: <StyleConfigurator>[
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pPr',
            configurators: <StyleConfigurator>[
              StyleConfigurator.noSelfClosing(
                prefix: 'w',
                propertyName: 'spacing',
                configurators: <StyleConfigurator>[
                  StyleConfigurator.selfClosing(
                      prefix: 'w', propertyName: 'before', value: '100'),
                  StyleConfigurator.selfClosing(
                      prefix: 'w', propertyName: 'line', value: '240'),
                ],
              ),
              StyleConfigurator.noSelfClosing(
                prefix: 'w',
                propertyName: 'ind',
                configurators: <StyleConfigurator>[
                  StyleConfigurator.selfClosing(
                      prefix: 'w', propertyName: 'left', value: '300'),
                ],
              ),
            ],
          ),
        ],
      );

      final Style derivedStyle = createStyle(
        styleId: 'Derived',
        styleName: 'Derived',
        basedOnId: 'Base',
        configurators: <StyleConfigurator>[
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pPr',
            configurators: <StyleConfigurator>[
              StyleConfigurator.noSelfClosing(
                prefix: 'w',
                propertyName: 'spacing',
                configurators: <StyleConfigurator>[
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

      final DocumentStyles stylesSheet = DocumentStyles(
        latentStyles: LatentStyles.base(),
        styles: <String, Style>{
          baseStyle.styleId: baseStyle,
          derivedStyle.styleId: derivedStyle,
        },
      );
      final Style deepStyle = derivedStyle.resolveStyle(stylesSheet);

      final StyleConfigurator? pPr = deepStyle.getConfiguratorOrNull('w:pPr');
      expect(pPr, isNotNull);

      final StyleConfigurator? spacing = pPr!.spacing;
      expect(spacing, isNotNull);
      expect(
        spacing!.getConfiguratorOrNull('w:before')?.value,
        '200',
      );
      expect(
        spacing.getConfiguratorOrNull('w:after')?.value,
        '50',
      ); // Derived new
      expect(
        spacing.getConfiguratorOrNull('w:line')?.value,
        '240',
      ); // Base inherited

      final StyleConfigurator? ind = pPr.getConfiguratorOrNull('w:ind');
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
      final Style styleA = createStyle(
        styleId: 'StyleA',
        styleName: 'Style A',
        basedOnId: 'StyleB', // Circular reference
      );
      final Style styleB = createStyle(
        styleId: 'StyleB',
        styleName: 'Style B',
        basedOnId: 'StyleA', // Circular reference
        configurators: <StyleConfigurator>[
          StyleConfigurator.selfClosing(
              prefix: 'w', propertyName: 'valueB', value: 'B'),
        ],
      );

      // A styles sheet with the circular styles
      final DocumentStyles stylesSheet = DocumentStyles(
        latentStyles: LatentStyles.base(),
        styles: <String, Style>{
          styleA.styleId: styleA,
          styleB.styleId: styleB,
        },
      );

      // When calling getDeepStyleRelation on styleA, it should not loop infinitely
      final Style deepStyle = styleA.resolveStyle(stylesSheet);

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
      final Style baseStyle = createStyle(
        styleId: 'Base',
        styleName: 'Base Name',
        configurators: <StyleConfigurator>[
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'someProp',
            value: 'base',
          ),
        ],
      );

      final Style childStyle = createStyle(
        styleId: 'Child',
        styleName: 'Child Name',
        basedOnId: 'Base',
        configurators: <StyleConfigurator>[
          StyleConfigurator.selfClosing(
              prefix: 'w', propertyName: 'anotherProp', value: 'child'),
        ],
      );

      final DocumentStyles stylesSheet = DocumentStyles(
        latentStyles: LatentStyles.base(),
        styles: <String, Style>{
          baseStyle.styleId: baseStyle,
          childStyle.styleId: childStyle,
        },
      );
      final Style deepStyle = childStyle.resolveStyle(stylesSheet);

      expect(deepStyle.styleId, 'Child');
      expect(deepStyle.styleName()!.value!, 'Child Name');
      expect(deepStyle.getConfiguratorOrNull('w:someProp')?.value, 'base');
      expect(deepStyle.getConfiguratorOrNull('w:anotherProp')?.value, 'child');
    });
  });
}
