# Numbering and Lists Internals in dart-docx

## 1. Key Concepts

- **Numbering**: The configuration that associates a paragraph with a list (ordered or bulleted), indicating the list type, nesting level, and instance identifier.
- **NumberingOptions**: Defines the (abstract) template of a list, including the levels, format, text, and alignment for each level.
- **Abstract Numbering**: The general definition of a list (e.g., how levels look, number format, etc.). It does not represent a concrete list in the document.
- **Concrete Numbering**: A concrete instance of a list in the document, referencing an abstract definition and having its own identifier (`numId`).

## 2. Class Structure and Flow

### a) Defining a List Template

A list template is defined using `NumberingOptions`, which contains a list of `LevelOptions` (one for each nesting level):

```dart
final numbering = NumberingOptions(
  refKey: 'myList',
  levels: [
    LevelOptions(
      level: 0,
      format: NumberFormat.decimal, // or bullet
      text: '%1.',
      alignment: Alignment.left,
      start: 1,
    ),
    // Each time you need to apply a different format to a deeper level,
    // increase the placeholder number so that the level uses its own counter.
    // For example, use '%2.' for level 1, '%3.' for level 2, etc.
    LevelOptions(
      level: 1,
      format: NumberFormat.lowerLetter,
      text: '%2)',   // uses the counter of level 1 (the current level)
      alignment: Alignment.left,
      start: 1,
    ),
    LevelOptions(
      level: 2,
      format: NumberFormat.upperRoman,
      text: '%3.',   // uses the counter of level 2
      alignment: Alignment.left,
      start: 1,
    ),
  ],
);
```

**Important**: The `text` field uses placeholders like `%1`, `%2`, `%3`, etc.  
- `%1` is replaced by the number of level 0 (the top level).  
- `%2` is replaced by the number of level 1 (the first nested level).  
- `%3` is replaced by the number of level 2, and so on.  

To make each level display its own counter in its own format (e.g., decimal for level 0, lowercase letters for level 1, uppercase roman for level 2), you must set `text` to use the placeholder corresponding to that level (`%1` for level 0, `%2` for level 1, `%3` for level 2, etc.). If all levels use `%1`, they will all show the top‑level number, losing the expected nested formatting.

This configuration generates a `<w:abstractNum>` element in the final XML, defining how each list level looks.

### b) Instantiating a Concrete List

When a paragraph uses the `numbering` property, a concrete list instance (`ConcreteNumberingOptions`) is created (if it does not already exist). This instance references the abstract template and has its own `numId` and `copyId` (refId):

```dart
final paragraph = Paragraph.text(
  text: 'List item',
  numbering: Numbering(reference: 'myList', level: 0, refId: 1),
)
```

- `reference`: the key of the list template.
- `level`: the nesting level (0 = root, 1 = first sublevel, ...).
- `refId`: the instance identifier. Changing it restarts the numbering.

The system creates a `<w:num>` element in the XML, which references the `<w:abstractNum>` and defines the starting point of the numbering.

### c) Nesting Lists

Nesting is controlled by the `level` field in the `Numbering` class:

- `level: 0` → top level
- `level: 1` → first sublevel
- ...

Each time the level increases, the system looks up the corresponding definition in the template (`NumberingOptions.levels`).

### d) Separating and Restarting Lists

To separate lists (i.e., restart numbering), simply change the `refId`:

```dart
final paragraph = Paragraph.text(
  text: 'New list start',
  numbering: Numbering(reference: 'myList', level: 0, refId: 2),
)
```

This creates a new concrete instance of the list, restarting the numbering from the beginning.

## 3. Internal Flow Summary

1. **Definition**: List templates (`NumberingOptions`) are defined with one or more levels.
2. **Instantiation**: Every time a paragraph uses `Numbering`, a concrete instance (`ConcreteNumberingOptions`) is created (if needed) with its own `numId` and `copyId`.
3. **Nesting**: The `level` determines the formatting and indentation of the item.
4. **Separation**: Changing the `refId` restarts the numbering and creates a new list.

## 4. Visual Example

```dart
// Simple ordered list
final pr1 = Paragraph.text(
  text: 'Item 1',
  numbering: Numbering(reference: 'ordered', level: 0, refId: 1),
);
final pr2 = Paragraph.text(
  text: 'Item 2',
  numbering: Numbering(reference: 'ordered', level: 0, refId: 1),
);
// Nested item
final pr3 = Paragraph.text(
  text: 'Subitem',
  numbering: Numbering(reference: 'ordered', level: 1, refId: 1),
);
// Restarted list
final pr4 = Paragraph.text(
  text: 'New start',
  numbering: Numbering(reference: 'ordered', level: 0, refId: 2),
);
```

## 5. Technical Details

- The system limits nesting to 9 levels (for compatibility with Word).
- Each combination of `reference` and `refId` creates a unique concrete instance.
- The generated XML follows the standard Word structure: `<w:numbering>`, `<w:abstractNum>`, `<w:num>`, `<w:lvl>`, etc.
- Overrides allow defining a custom start number for each level.
