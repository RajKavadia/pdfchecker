
import 'dart:io';
import 'package:test/test.dart';
import 'package:pdf_checker/src/pdf_checker.dart';

void main() {
  group('PdfChecker', () {
    late List<int> unprotectedPdfBytes;
    late List<int> protectedPdfBytes;
    const unprotectedPdfPath = 'assets/pdf/sample.pdf';
    const protectedPdfPath = 'assets/pdf/sample_protected.pdf';

    setUpAll(() async {
      unprotectedPdfBytes = await File(unprotectedPdfPath).readAsBytes();
      protectedPdfBytes = await File(protectedPdfPath).readAsBytes();
    });

    test('should return false for an unprotected PDF from bytes', () {
      final isProtected = PdfChecker.instance.isProtected(unprotectedPdfBytes);
      expect(isProtected, isFalse);
    });

    test('should return true for a protected PDF from bytes', () {
      final isProtected = PdfChecker.instance.isProtected(protectedPdfBytes);
      expect(isProtected, isTrue);
    });

    test('should return false for an unprotected PDF from file path', () async {
      final isProtected =
          await PdfChecker.instance.isProtectedFromFile(unprotectedPdfPath);
      expect(isProtected, isFalse);
    });

    test('should return true for a protected PDF from file path', () async {
      final isProtected =
          await PdfChecker.instance.isProtectedFromFile(protectedPdfPath);
      expect(isProtected, isTrue);
    });

    // TODO: Add tests for checkPassword
  });
}
