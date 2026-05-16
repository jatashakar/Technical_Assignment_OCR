/// Structured passbook / bank document data after manual parsing.
class BankDetails {
  final String? accountHolderName;
  final String? accountNumber;
  final String? ifscCode;

  const BankDetails({
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
  });

  bool get hasAnyData =>
      (accountHolderName != null && accountHolderName!.isNotEmpty) ||
      (accountNumber != null && accountNumber!.isNotEmpty) ||
      (ifscCode != null && ifscCode!.isNotEmpty);
}
