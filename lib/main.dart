import 'package:flutter/material.dart';
import 'package:technical_assignment_flutter_ocr/ui/card_scan_screen.dart';
import 'package:technical_assignment_flutter_ocr/ui/passbook_scan_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OcrAssignmentApp());
}

class OcrAssignmentApp extends StatelessWidget {
  const OcrAssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card & Passbook OCR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Technical Assignment — OCR')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Scan a payment card or a passbook page. '
              'Structured fields are parsed manually from OCR text (no parsing libraries).',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CardScanScreen()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('1 — Card scanner'),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const PassbookScanScreen()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('2 — Passbook / bank document scanner'),
              ),
            ),
            const Spacer(),
            Text(
              'Libraries: google_mlkit_text_recognition, image_picker.\n'
              'Parsing & Luhn: custom Dart code in lib/core.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
