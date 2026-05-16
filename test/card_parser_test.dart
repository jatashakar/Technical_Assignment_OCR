import 'package:flutter_test/flutter_test.dart';
import 'package:technical_assignment_flutter_ocr/core/parsers/card_parser.dart';

void main() {
  test('parseCard extracts PAN, expiry, and name from noisy OCR-like text', () {
    const raw = '''
      BANK CARD
      4111 1111 1111 1111
      JOHN DOE
      VALID THRU 12/29
    ''';
    final d = parseCard(raw);
    expect(d.cardNumberDigits, '4111111111111111');
    expect(d.luhnValid, isTrue);
    expect(d.expiryMmYy, '12/29');
    expect(d.cardHolderName, isNotNull);
    expect(d.cardHolderName!.toLowerCase(), contains('john'));
  });

  test('parseCard reads compact expiry in noisy text', () {
    final d = parseCard('foo 1228 bar');
    expect(d.expiryMmYy, '12/28');
  });
}
