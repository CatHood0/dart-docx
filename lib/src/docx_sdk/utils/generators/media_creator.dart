String generateMediaName(
  int lastId, {
  bool trim = true,
  bool isImage = false,
  String? suffix,
}) {
  return isImage
      ? 'image-${suffix != null ? '$suffix-' : ''}${trim ? lastId : ' $lastId'}'
      : 'media-${suffix != null ? '$suffix-' : ''}${trim ? lastId : ' $lastId'}';
}
