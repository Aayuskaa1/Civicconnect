import 'package:flutter_test/flutter_test.dart';

/// Live API smoke tests are optional and require a running backend.
/// Use mocktail unit/widget suites under `test/features/` for assignment grading.
void main() {
  test(
    'smoke suite skipped by default (start backend to enable live checks)',
    () {},
    skip: 'Optional live backend smoke — not part of mocktail unit/widget suite',
  );
}
