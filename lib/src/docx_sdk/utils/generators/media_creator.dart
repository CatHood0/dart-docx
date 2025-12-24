String generateMediaName(
  int lastId, {
  bool trim = true,
  bool isImage = false,
}) {
  return isImage
      ? 'image ${trim ? lastId : ' $lastId'}'
      : 'media ${trim ? lastId : ' $lastId'}';
}
