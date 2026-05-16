import 'package:technical_assignment_flutter_ocr/core/ocr_normalize.dart';
import 'package:technical_assignment_flutter_ocr/models/bank_details.dart';

/// IFSC: 4 letters + literal 0 + 6 alphanumeric (India).
final RegExp _ifscPattern = RegExp(r'\b([A-Za-z]{4}0[A-Za-z0-9]{6})\b');

String? _findIfsc(String raw) {
  final m = _ifscPattern.firstMatch(raw.replaceAll(RegExp(r'\s+'), ' '));
  if (m == null) return null;
  return m.group(1)!.toUpperCase();
}

/// Account number: prefer 9–18 digit sequences; exclude substrings of IFSC.
String? _findAccountNumber(String raw, String? ifsc) {
  final normalized = ocrNormalizeForDigits(raw);
  final candidates = <String>[];
  final re = RegExp(r'\d{9,18}');
  for (final m in re.allMatches(normalized.replaceAll(RegExp(r'\s'), ''))) {
    candidates.add(m.group(0)!);
  }
  // Also from spaced digits
  final digitsOnly = normalized.replaceAll(RegExp(r'\D'), '');
  for (var len = 18; len >= 9; len--) {
    if (len > digitsOnly.length) continue;
    for (var start = 0; start + len <= digitsOnly.length; start++) {
      candidates.add(digitsOnly.substring(start, start + len));
    }
  }
  if (candidates.isEmpty) return null;
  // Dedupe, prefer longest distinct
  candidates.sort((a, b) => b.length.compareTo(a.length));
  for (final c in candidates.toSet()) {
    if (ifsc != null && ifsc.replaceAll(RegExp(r'\D'), '').contains(c)) {
      continue;
    }
    if (c.length >= 9 && c.length <= 18) return c;
  }
  return candidates.isNotEmpty ? candidates.first : null;
}

String? _findAccountName(String raw, String? ifsc, String? account) {
  final lines = raw.split(RegExp(r'[\r\n]+'));
  final skip = RegExp(
    r'(ifsc|account|a/c|no\.|number|passbook|branch|code|bank)',
    caseSensitive: false,
  );
  for (final line in lines) {
    var t = line.trim();
    if (t.length < 3 || t.length > 45) continue;
    if (skip.hasMatch(t) && !RegExp(r'[a-zA-Z]{3,}\s+[a-zA-Z]{3,}').hasMatch(t)) {
      continue;
    }
    if (ifsc != null && t.toUpperCase().contains(ifsc)) continue;
    if (account != null && t.replaceAll(RegExp(r'\D'), '') == account) continue;
    if (RegExp(r'^\d[\d\s\-/]*$').hasMatch(t)) continue;
    if (!RegExp(r'[a-zA-Z]').hasMatch(t)) continue;
    final words = t.split(RegExp(r'\s+')).where((w) => w.length > 1).toList();
    // if (words.length >= 2 && RegExp(r'^[a-zA-Z\s\.\'-]+$').hasMatch(t)) {
    //   return words.map((w) {
    //     return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
    //   }).join(' ');
    if (words.length >= 2 &&
        RegExp(r"^[a-zA-Z\s\.\'-]+$").hasMatch(t)) {
      // ...
      return words.map((w) {
        return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
      }).join(' ');
    }
  }
  return null;
}

/// Manual passbook / bank document parser — no parsing libraries.
BankDetails parsePassbook(String rawText) {
  if (rawText.trim().isEmpty) {
    return const BankDetails();
  }
  final ifsc = _findIfsc(rawText);
  final account = _findAccountNumber(rawText, ifsc);
  final name = _findAccountName(rawText, ifsc, account);
  return BankDetails(
    accountHolderName: name,
    accountNumber: account,
    ifscCode: ifsc,
  );
}
