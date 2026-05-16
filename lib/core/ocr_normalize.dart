/// Shared OCR character normalization (not a "parsing library" — character fixes only).
String ocrNormalizeForDigits(String s) {
  final buf = StringBuffer();
  for (final ch in s.split('')) {
    switch (ch) {
      case 'O':
      case 'o':
      case 'Q':
        buf.write('0');
        break;
      case 'I':
      case 'l':
      case '|':
      case 'i':
      case 'L':
        buf.write('1');
        break;
      case 'Z':
      case 'z':
        buf.write('2');
        break;
      case 'S':
      case 's':
        buf.write('5');
        break;
      case 'B':
        buf.write('8');
        break;
      default:
        buf.write(ch);
    }
  }
  return buf.toString();
}
