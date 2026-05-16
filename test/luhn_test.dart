import 'package:flutter_test/flutter_test.dart';
import 'package:technical_assignment_flutter_ocr/core/luhn.dart';

void main() {
  test('isValidCard accepts known-good Visa test PAN', () {
    expect(isValidCard('4111111111111111'), isTrue);
    expect(isValidCard('4111 1111 1111 1111'), isTrue);
  });

  test('isValidCard rejects invalid check digit', () {
    expect(isValidCard('4111111111111112'), isFalse);
  });

  test('isValidCard rejects too short', () {
    expect(isValidCard('411111111111'), isFalse);
  });
}
