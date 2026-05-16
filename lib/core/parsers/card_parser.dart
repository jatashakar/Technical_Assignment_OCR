import 'dart:math';

import 'package:technical_assignment_flutter_ocr/core/luhn.dart';
import 'package:technical_assignment_flutter_ocr/core/ocr_normalize.dart';
import 'package:technical_assignment_flutter_ocr/models/card_details.dart';

/// Substrings of length 13–19, **longest first**, so a full 16-digit PAN wins over a 13-digit prefix.
Iterable<String> _panSubstringsLongestFirst(String digits) sync* {
  if (digits.length < 13) return;
  final maxLen = min(19, digits.length);
  for (var len = maxLen; len >= 13; len--) {
    for (var start = 0; start + len <= digits.length; start++) {
      yield digits.substring(start, start + len);
    }
  }
}

String? _pickBestPan(String rawText) {
  final normalized = ocrNormalizeForDigits(rawText);
  final digitsOnly = normalized.replaceAll(RegExp(r'\D'), '');
  if (digitsOnly.length < 13) return null;

  for (final sub in _panSubstringsLongestFirst(digitsOnly)) {
    if (isValidCard(sub)) return sub;
  }

  // No Luhn match: return longest tail slice for UI / error feedback
  for (var len = min(19, digitsOnly.length); len >= 13; len--) {
    return digitsOnly.substring(digitsOnly.length - len);
  }
  return null;
}

String? _findExpiry(String raw) {
  final t = raw.replaceAll(RegExp(r'\s+'), ' ');
  final re1 = RegExp(
    r'(?:exp|expiry|valid|thru|through)?\s*[:.]?\s*(0[1-9]|1[0-2])\s*[/\-\s]\s*(\d{2})\b',
    caseSensitive: false,
  );
  final m1 = re1.firstMatch(t);
  if (m1 != null) {
    return '${m1.group(1)}/${m1.group(2)}';
  }
  final compact = t.replaceAll(RegExp(r'[/\-\s]'), '');
  final re2 = RegExp(r'(0[1-9]|1[0-2])(\d{2})');
  final m2 = re2.firstMatch(compact);
  if (m2 != null) {
    return '${m2.group(1)}/${m2.group(2)}';
  }
  return null;
}

String? _findHolderName(String raw) {
  final lines = raw.split(RegExp(r'[\r\n]+'));
  final bad = RegExp(
    r'^\s*(valid|thru|exp|expiry|bank|card|number|visa|master|amex|debit|credit|passbook|account|ifsc)',
    caseSensitive: false,
  );
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.length < 4 || trimmed.length > 40) continue;
    if (bad.hasMatch(trimmed)) continue;
    if (RegExp(r'^\d[\d\s\-/]*$').hasMatch(trimmed)) continue;
    final noSpace = trimmed.replaceAll(' ', '');
    if (RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$', caseSensitive: false).hasMatch(noSpace)) {
      continue;
    }
  //  if (!RegExp(r'^[a-zA-Z\s\.\'-;]{4,}$').hasMatch(trimmed)) continue;
        if (!RegExp(r"^[a-zA-Z\s\.\'-]{4,}$").hasMatch(trimmed)) {
      continue;
    }
    final words = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      return words.map((w) {
        if (w.isEmpty) return w;
        if (w.length == 1) return w.toUpperCase();
        return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
      }).join(' ');
    }
  }
  return null;
}

/// Manual card parser — no third-party parsing libraries.
CardDetails parseCard(String rawText) {
  if (rawText.trim().isEmpty) {
    return const CardDetails();
  }
  final pan = _pickBestPan(rawText);
  final expiry = _findExpiry(rawText);
  final name = _findHolderName(rawText);
  final valid = pan != null && isValidCard(pan);
  return CardDetails(
    cardNumberDigits: pan,
    expiryMmYy: expiry,
    cardHolderName: name,
    luhnValid: valid,
  );
}
