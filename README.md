# pdf_checker

A pure Dart package to check if PDF files are password-protected without relying on external PDF parsing libraries. This package is designed for environments where minimal dependencies and full control over parsing logic are required.

## Features

*   **Pure Dart:** No external dependencies beyond `crypto` for hashing (if `checkPassword` were fully implemented).
*   **Password Protection Check:** Determine if a PDF file is encrypted and requires a password to open.
*   **Streaming Support:** Designed to work with `RandomAccessFile` to avoid loading entire large PDF files into memory.

## Installation

Add `pdf_checker` to your `pubspec.yaml` file:

```yaml
dependencies:
  pdf_checker: ^0.1.0 # Replace with the latest version
```

Then run `dart pub get`.

## Usage

### Checking if a PDF is protected

You can check if a PDF file is password-protected by passing its bytes (or a `RandomAccessFile` in the future) to the `isProtected` method.

```dart
import 'dart:io';
import 'package:pdf_checker/pdf_checker.dart';

void main() async {
  final checker = PdfChecker();
  final filePath = 'path/to/your/document.pdf'; // Replace with your PDF file path

  if (!await File(filePath).exists()) {
    print('Error: File not found at $filePath');
    return;
  }

  // Current implementation reads whole file, will be updated to use RandomAccessFile
  final pdfBytes = await File(filePath).readAsBytes();
  
  final protected = checker.isProtected(pdfBytes);

  if (protected) {
    print('The PDF file is password-protected.');
  } else {
    print('The PDF file is NOT password-protected.');
  }
}
```

## Limitations

*   **Early Development Stage:** This package is currently in early development (`0.1.0`).
*   **`checkPassword` not fully implemented:** The `checkPassword` method is present but currently only returns `false`. Full password validation requires significant additional development for cryptographic algorithms and PDF security handler revisions.
*   **Basic PDF Parsing:** The internal PDF parsing logic is custom-built and currently only supports finding the trailer dictionary. It may not be robust enough for all PDF variations or edge cases.
*   **No full PDF object parsing:** Complex PDF object parsing (e.g., compressed object streams, object streams) is not supported.

## Future Plans

*   Complete `checkPassword` implementation with full PDF password validation algorithms (Revisions 2, 3, 4, AES, RC4).
*   Improve robustnesse of internal PDF parsing for better compatibility.
*   Refactor `isProtected` to directly accept `RandomAccessFile` to truly stream without loading full file into memory.

## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request.

## License

(Add license information here, e.g., MIT License)
