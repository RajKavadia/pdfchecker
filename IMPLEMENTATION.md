# IMPLEMENTATION.md: Phased Plan for pdf_checker (Manual Parser)

This document outlines the step-by-step plan to implement the `pdf_checker` package by building a manual, pure Dart PDF parser.

After completing a task, if you added any TODOs to the code or didn't fully implement anything, make sure to add new tasks to this plan so that you can come back and complete them later.

## Phase 1: Project Scaffolding and Setup (Completed)

The goal of this phase was to create a valid Dart package and then pivot away from third-party dependencies.

- [x] Create a new, pure Dart package named `pdf_checker`.
- [x] Remove the `dart_pdf_reader` package dependency.
- [x] Ensure `pubspec.yaml` has the correct `description` and `version` (`0.1.0`).
- [x] Create a placeholder `README.md` and `CHANGELOG.md`.

## Phase 2: Core Parsing - Finding the Trailer (Completed)

This phase focuses on the most critical part of the manual parser: reading the file from the end to locate the main trailer dictionary.

- [x] Implement a private helper `_findXrefOffset(List<int> pdfBytes)` in `lib/src/pdf_checker.dart`. This function will read the last ~1KB of the file, find the `startxref` keyword, and parse the integer byte offset that follows it. (Temporarily made public as `findXrefOffset` for testing).
- [x] Implement a private helper `_parseTrailer(String trailerString)` that can parse a simple dictionary string (e.g., `<< /Key1 val /Key2 val >>`) into a `Map<String, String>`. (Temporarily made public as `parseTrailer` for testing).
- [x] Implement a private helper `_findTrailer(List<int> pdfBytes)` that orchestrates the process:
    - It will call `_findXrefOffset` to get the cross-reference offset.
    - It will jump to that offset and read the subsequent bytes.
    - It will locate the `trailer` keyword and extract the dictionary string that follows.
    - It will use `_parseTrailer` to convert the string into a map. (Temporarily made public as `findTrailer` for testing).
- [x] Add unit tests for `_findXrefOffset`. This will require a sample PDF byte array where the `startxref` address is known.
- [x] Add unit tests for `_parseTrailer` with sample dictionary strings.

## Phase 3: Implement `isProtected()` Using the Manual Parser

With the core parsing logic in place, this phase connects it to the public API.

- [x] Re-implement the public method `Future<bool> isProtected(List<int> pdfBytes)`. It will now use the `_findTrailer` helper.
- [x] The method will check if the map returned by `_findTrailer` contains the `/Encrypt` key.
- [x] Update the tests in `test/pdf_checker_test.dart` for `isProtected` to use the new manual implementation. The tests will still be skipped if the runtime file paths are not provided.

## Phase 4: Implement `checkPassword()` Functionality

This phase remains a complex, future goal.

- [ ] Implement the public method `Future<bool> checkPassword(List<int> pdfBytes, String password)`.
- [ ] This will require extending the manual parser to not just find the `/Encrypt` key, but to parse the full encryption dictionary object it points to.
- [ ] Implement the password validation algorithm from the PDF specification.
- [ ] Add extensive unit tests.

## Phase 5: Documentation and Finalization

The final phase is to ensure the package is well-documented.

- [ ] Create a comprehensive `README.md` file.
- [ ] Create a `GEMINI.md` file.
- [ ] Ask the user to inspect the final package and confirm if they are satisfied.

---

### Post-Phase Checklist

After each phase, the following steps must be completed:

- [ ] Create or modify unit tests for the code added or modified in this phase.
- [ ] Run the `dart_fix` tool to clean up the code.
- [ ] Run the `analyze_files` tool and fix any reported issues.
- [ ] Run all tests to ensure they pass.
- [ ] Run `dart_format` to ensure all code is correctly formatted.
- [ ] Re-read this `IMPLEMENTATION.md` file.
- [ ] Update this `IMPLEMENTATION.md` file with the current state, checking off completed tasks and adding notes to the Journal.

---

## Journal

### Phase 1 (Completed)
*Initial plan created and project scaffolded.*
*Pivoted from using a third-party library to a manual parsing approach based on user feedback. The `dart_pdf_reader` dependency has been removed.*

### Phase 2 (Completed)
*Implemented `findXrefOffset`, `parseTrailer`, `findTrailer` helper methods.*
*Implemented `isProtected` method using the new manual parsing helpers.*
*Updated `test/pdf_checker_test.dart` with new unit tests for `findXrefOffset` and `parseTrailer`.*
*Temporarily made `findXrefOffset`, `parseTrailer`, and `findTrailer` public for testing purposes.*
*Fixed `allowError` parameter in `utf8.decode` calls.*
*Fixed invalid `skip` calls in `test/pdf_checker_test.dart`.*
*Successfully passed all direct unit tests for helper methods.*
*`dart_fix`, `analyze_files`, and `dart_format` run successfully.*

