String abbreviation(String text) {
  return text
      .split(' ')
      .map((String part) => part[0])
      .reduce((prev, current) => prev + current)
      .toUpperCase();
}