
library pdf_checker;

import 'dart:convert';
import 'dart:io';

class PdfChecker {
  // Private constructor
  PdfChecker._internal();

  // Singleton instance
  static final PdfChecker _instance = PdfChecker._internal();

  // Public accessor for the singleton instance
  static PdfChecker get instance => _instance;

  Future<bool> isProtectedFromFile(String path) async {
    try {
      final file = File(path);
      final pdfBytes = await file.readAsBytes();
      return isProtected(pdfBytes);
    } catch (e) {
      print('Error reading or checking file: $e');
      return false;
    }
  }

  /// Searches for the `startxref` keyword at the end of the PDF and
  /// extracts the byte offset of the cross-reference table.
  ///
  /// Throws [FormatException] if `startxref` or its offset is not found.
  int findXrefOffset(List<int> pdfBytes) {
    // Read the last 1024 bytes (or less if the file is smaller)
    // The startxref keyword and its offset are typically near the end of the file.
    final int searchLength = 1024;
    final int start =
        (pdfBytes.length - searchLength).clamp(0, pdfBytes.length);
    final List<int> searchWindow = pdfBytes.sublist(start);

    // Convert the search window to a string for easier searching
    final String searchString = utf8.decode(searchWindow);

    // Search for '%%EOF' backwards
    final int eofIndex = searchString.lastIndexOf('%%EOF');
    if (eofIndex == -1) {
      throw FormatException('PDF Eof marker (%%EOF) not found.');
    }

    // Search for 'startxref' backwards from '%%EOF'
    final int startxrefIndex = searchString.lastIndexOf('startxref', eofIndex);
    if (startxrefIndex == -1) {
      throw FormatException('PDF startxref keyword not found.');
    }

    // The offset is after 'startxref' and before '%%EOF'
    final String xrefSegment = searchString
        .substring(startxrefIndex + 'startxref'.length, eofIndex)
        .trim();

    // The xrefSegment should contain the integer offset, possibly followed by comments or whitespace.
    // We need to extract the first sequence of digits.
    final RegExp digitRegex = RegExp(r'(\d+)');
    final Match? match = digitRegex.firstMatch(xrefSegment);

    if (match == null) {
      throw FormatException('Xref offset not found after startxref keyword.');
    }

    try {
      return int.parse(match.group(1)!);
    } catch (e) {
      throw FormatException('Invalid xref offset format: $e');
    }
  }

  Map<String, String> findTrailer(List<int> pdfBytes) {
    final int xrefOffset = findXrefOffset(pdfBytes);

    // Read a chunk of bytes around the xrefOffset to find the trailer
    // The trailer dictionary typically follows the xref table or xref stream.
    // We'll read a reasonable buffer size to capture it.
    final int readLength = 2048; // Read 2KB around the xrefOffset
    final int start = xrefOffset.clamp(0, pdfBytes.length - 1);
    final int end = (start + readLength).clamp(0, pdfBytes.length);

    // Ensure we don't read beyond the end of the file
    final List<int> searchWindow = pdfBytes.sublist(start, end);
    final String searchString = utf8.decode(searchWindow);

    // Look for the 'trailer' keyword
    final int trailerIndex = searchString.indexOf('trailer');
    if (trailerIndex == -1) {
      throw FormatException('PDF trailer keyword not found near xref offset.');
    }

    // The trailer dictionary follows the 'trailer' keyword.
    // It starts with '<<' and ends with '>>'.
    final int dictStartIndex = searchString.indexOf('<<', trailerIndex);
    if (dictStartIndex == -1) {
      throw FormatException(
          'PDF trailer dictionary start (<<) not found after trailer keyword.');
    }

    final int dictEndIndex = searchString.indexOf('>>', dictStartIndex);
    if (dictEndIndex == -1) {
      throw FormatException(
          'PDF trailer dictionary end (>>) not found after its start.');
    }

    final String trailerDictString =
        searchString.substring(dictStartIndex, dictEndIndex + 2);
    return parseTrailer(trailerDictString);
  }

  Map<String, String> parseTrailer(String trailerString) {
    final Map<String, String> trailerMap = {};

    // Remove leading/trailing '<<' and '>>' and trim whitespace
    String cleanedString = trailerString.trim();
    if (cleanedString.startsWith('<<') && cleanedString.endsWith('>>')) {
      cleanedString =
          cleanedString.substring(2, cleanedString.length - 2).trim();
    } else {
      // Not a valid dictionary string, but we'll try to parse what we can
    }

    // Use a regex to find key-value pairs.
    // Keys start with '/', values can be names, numbers, or indirect references (e.g., 21 0 R)
    // Refined regex to better capture values like "21 0 R"
    final RegExp keyValueRegex =
        RegExp(r'\/([a-zA-Z0-9]+)\s*([^\/>>\s]+(?:(?:\s+\d+\s+R)?))?');

    for (final Match match in keyValueRegex.allMatches(cleanedString)) {
      final String key = '/${match.group(1)!}';
      String? value = match.group(2)?.trim();
      if (value != null && value.isNotEmpty) {
        trailerMap[key] = value;
      }
    }
    return trailerMap;
  }

  bool isProtected(List<int> pdfBytes) {
    try {
      final Map<String, String> trailer = findTrailer(pdfBytes);
      return trailer.containsKey('/Encrypt');
    } on FormatException catch (e) {
      print('Error checking if PDF is protected: $e'); // For debugging purposes
      return false;
    } catch (e) {
      print('An unexpected error occurred: $e');
      return false;
    }
  }

  bool checkPassword(List<int> pdfBytes, String password) {
    if (!isProtected(pdfBytes)) {
      return false;
    }
    // TODO: Implement the full password check logic
    return false;
  }

}
