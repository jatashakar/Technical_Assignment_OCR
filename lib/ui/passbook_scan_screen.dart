import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:technical_assignment_flutter_ocr/core/parsers/passbook_parser.dart';
import 'package:technical_assignment_flutter_ocr/models/bank_details.dart';
import 'package:technical_assignment_flutter_ocr/services/ocr_service.dart';

class PassbookScanScreen extends StatefulWidget {
  const PassbookScanScreen({super.key});

  @override
  State<PassbookScanScreen> createState() => _PassbookScanScreenState();
}

class _PassbookScanScreenState extends State<PassbookScanScreen> {
  final _picker = ImagePicker();
  final _ocr = OcrService();
  XFile? _image;
  BankDetails? _details;
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
      setState(() => _rawPreview = text.length > 500 ? '${text.substring(0, 500)}…' : text);
      final parsed = parsePassbook(text);
      setState(() {
        _details = parsed;
        _busy = false;
        if (!parsed.hasAnyData) {
          _error = 'No bank fields parsed. Try a clearer image or ensure IFSC / account are visible.';
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
      appBar: AppBar(title: const Text('Passbook scanner')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.document_scanner),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload'),
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
                aspectRatio: 3 / 4,
                child: Image.file(File(_image!.path), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_details != null && _details!.hasAnyData)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Extracted', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(height: 20),
                    _row('Account name', _details!.accountHolderName ?? '—'),
                    _row('Account number', _details!.accountNumber ?? '—'),
                    _row('IFSC', _details!.ifscCode ?? '—'),
                  ],
                ),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Material(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade900),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!)),
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
          SizedBox(width: 120, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: SelectableText(v)),
        ],
      ),
    );
  }
}
