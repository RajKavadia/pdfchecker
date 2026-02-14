import 'package:pdf_checker/src/pdf_checker.dart';

void main() async {
  // Check an unprotected PDF from a file path
  final isUnprotectedPdfProtected = await PdfChecker.instance.isProtectedFromFile('assets/pdf/sample.pdf');
  print('Is sample.pdf protected? $isUnprotectedPdfProtected');

  // Check a protected PDF from a file path
  final isProtectedPdfProtected = await PdfChecker.instance.isProtectedFromFile('assets/pdf/sample_protected.pdf');
  print('Is sample_protected.pdf protected? $isProtectedPdfProtected');
}
