/// Represents the editor properties that are always
/// showed like: number of lines, paragraphs, characters, etc
class EditorMetadata {
  EditorMetadata({
    required this.paragraphs,
    required this.lines,
    required this.characters,
    required this.charactersWithSpaces,
    required this.words,
    required this.pages,
  });

  EditorMetadata.zero()
      : paragraphs = 0,
        lines = 0,
        characters = 0,
        charactersWithSpaces = 0,
        words = 0,
        pages = 0;

  final int paragraphs;
  final int lines;
  final int characters;
  final int charactersWithSpaces;
  final int words;
  final int pages;
}
