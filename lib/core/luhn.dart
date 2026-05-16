/// Luhn (mod 10) check for payment card numbers — implemented manually per assignment.
bool isValidCard(String cardNumber) {
  final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 13 || digits.length > 19) {
    return false;
  }
  var sum = 0;
  var doubleDigit = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    final c = digits.codeUnitAt(i);
    if (c < 48 || c > 57) return false;
    var d = c - 48;
    if (doubleDigit) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
    doubleDigit = !doubleDigit;
  }
  return sum % 10 == 0;
}
