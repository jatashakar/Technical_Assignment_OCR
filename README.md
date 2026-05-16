# Technical Assignment — Flutter Developer (OCR)

Mobile app per **Technical Assignment - Flutter Developer**: scan **payment cards** and **passbook / bank documents** with the device camera or gallery, run **on-device OCR** (ML Kit), then extract structured fields using **only manual parsing** in Dart (no parsing libraries). **Luhn** validation is implemented manually.

## Location

This project was created at:

`Documents/Demo/technical_assignment_flutter_ocr`

To move it next to your other folders under `Documents` only:

```bash
mv ~/Documents/Demo/technical_assignment_flutter_ocr ~/Documents/technical_assignment_flutter_ocr
```

## How to run

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (stable).
2. From the project root:

```bash
cd technical_assignment_flutter_ocr   # or the path above
flutter pub get
flutter run                           # Android (required) or iOS
```

3. Run tests:

```bash
flutter test
```

## Libraries used

| Package | Purpose |
|--------|---------|
| `google_mlkit_text_recognition` | On-device OCR (text only) |
| `image_picker` | Camera + gallery image capture |

**Not used for parsing:** no regex/card/bank parsing packages — only `RegExp` / string logic in `lib/core/`.

## Project structure

- `lib/core/luhn.dart` — `isValidCard` (Luhn)
- `lib/core/ocr_normalize.dart` — OCR character fixes (O→0, etc.)
- `lib/core/parsers/card_parser.dart` — `parseCard`
- `lib/core/parsers/passbook_parser.dart` — `parsePassbook`
- `lib/services/ocr_service.dart` — ML Kit wrapper → raw string
- `lib/ui/` — Card & passbook screens + image preview + errors
- `test/` — One test file each for Luhn, card parser, passbook parser

## Assumptions

- **India IFSC** pattern: 4 letters + literal `0` + 6 alphanumeric (`SBIN0001234`).
- **Account number**: 9–18 consecutive digits after OCR normalization; heuristics may pick wrong candidate if many numbers appear (documented for interview).
- **Card PAN**: first substring of length 13–19 (longest-first) that passes **Luhn**; otherwise longest tail slice is shown with Luhn = false.
- **Cardholder / account name**: heuristic on alphabetic lines (no ML for names).

## What was skipped / limitations

- **No backend** (per assignment).
- **No ML for field detection** — only OCR + rules (acceptable per spec).
- **iOS** is supported in project template but **Android is mandatory** for submission focus.
- **Heavy skew / glare** may still mis-OCR; parsers try common O/0 swaps only in digit paths.

## GitHub submission

Initialize and push:

```bash
git init
git add .
git commit -m "Technical assignment: OCR card & passbook scanner"
# create repo on GitHub, then:
git remote add origin <your-repo-url>
git push -u origin main
```

## AI usage note (from PDF)

You may use AI tools during development; you should be ready to **explain and modify** the parsing code in interview.
