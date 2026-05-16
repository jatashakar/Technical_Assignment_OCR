import 'package:flutter_test/flutter_test.dart';
import 'package:technical_assignment_flutter_ocr/core/parsers/passbook_parser.dart';

void main() {
  test('parsePassbook extracts IFSC and account-style number', () {
    const raw = '''
      STATE BANK OF INDIA
      Account Name: RAJESH KUMAR
      A/C No: 123456789012
      IFSC: SBIN0001234
    ''';
    final b = parsePassbook(raw);
    expect(b.ifscCode, 'SBIN0001234');
    expect(b.accountNumber, isNotNull);
    expect(b.accountNumber, contains('123456789012'));
  });
}
