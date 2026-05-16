import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:technical_assignment_flutter_ocr/core/parsers/card_parser.dart';
import 'package:technical_assignment_flutter_ocr/models/card_details.dart';
import 'package:technical_assignment_flutter_ocr/services/ocr_service.dart';

class CardScanScreen extends StatefulWidget {
  const CardScanScreen({super.key});

  @override
  State<CardScanScreen> createState() => _CardScanScreenState();
}

class _CardScanScreenState extends State<CardScanScreen> {
  final _picker = ImagePicker();
  final _ocr = OcrService();
  XFile? _image;
  CardDetails? _details;
  String? _error;
  bool _busy = false;
  String? _rawPreview;

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _error = null;
      _details = null;
      _rawPreview = null;
    });
    try {
      final x = await _picker.pickImage(source: source, imageQuality: 88);
      if (x == null) return;
      setState(() {
        _image = x;
        _busy = true;
      });
      final text = await _ocr.recognizeFromFilePath(x.path);
      setState(() => _rawPreview = text.length > 400 ? '${text.substring(0, 400)}…' : text);
      final parsed = parseCard(text);
      setState(() {
        _details = parsed;
        _busy = false;
        if (!parsed.hasAnyData) {
          _error = 'No card data could be parsed. Try a clearer image.';
        } else if (!parsed.luhnValid && parsed.cardNumberDigits != null) {
          _error = 'Card number found but Luhn check failed — may be misread.';
        }
      });
    } catch (e) {
      setState(() {
        _busy = false;
        _error = 'OCR failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card scanner')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          if (_busy) const LinearProgressIndicator(),
          const SizedBox(height: 16),
          if (_image != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.file(File(_image!.path), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_details != null && _details!.hasAnyData) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Masked PAN', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    SelectableText(
                      _details!.maskedPan,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Divider(height: 24),
                    _row('Expiry', _details!.expiryMmYy ?? '—'),
                    _row('Cardholder', _details!.cardHolderName ?? '—'),
                    _row('Luhn valid', _details!.luhnValid ? 'Yes' : 'No'),
                  ],
                ),
              ),
            ),
          ],
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Material(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red.shade800),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: TextStyle(color: Colors.red.shade900))),
                    ],
                  ),
                ),
              ),
            ),
          if (_rawPreview != null) ...[
            const SizedBox(height: 16),
            Text('OCR snippet (debug)', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            SelectableText(_rawPreview!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: SelectableText(v)),
        ],
      ),
    );
  }
}
