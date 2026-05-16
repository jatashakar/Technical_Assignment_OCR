/// Structured card data after manual parsing (not from a parsing library).
class CardDetails {
  final String? cardNumberDigits;
  final String? expiryMmYy;
  final String? cardHolderName;
  final bool luhnValid;

  const CardDetails({
    this.cardNumberDigits,
    this.expiryMmYy,
    this.cardHolderName,
    this.luhnValid = false,
  });

  /// Masked display e.g. XXXX XXXX XXXX 1234
  String get maskedPan {
    final pan = cardNumberDigits;
    if (pan == null || pan.length < 4) return '—';
    final last4 = pan.substring(pan.length - 4);
    final hidden = 'XXXX XXXX XXXX';
    return '$hidden $last4';
  }

  bool get hasAnyData =>
      (cardNumberDigits != null && cardNumberDigits!.isNotEmpty) ||
      (expiryMmYy != null && expiryMmYy!.isNotEmpty) ||
      (cardHolderName != null && cardHolderName!.isNotEmpty);
}
