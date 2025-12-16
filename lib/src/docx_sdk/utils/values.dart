int ensureInteger(num number) {
    if (number.isNaN ) {
        throw Exception('Invalid value "$number" specified. Must be an integer.');
    }
  return number.floor();
}


