@TestOn('vm')
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

/// Drift's `useNativeFunctions()` registers `moor_contains` and
/// `current_time_millis` as drift-specific helpers; `pow`, `sqrt`, the
/// trig functions are SQLite math builtins (when compiled with
/// `SQLITE_ENABLE_MATH_FUNCTIONS`, which `package:sqlite3` is), so
/// registering them is just a shadow and skipping the registration does
/// not surface as a "no such function" error.
///
/// We therefore use `moor_contains` (drift-only, function-call syntax)
/// as the gate canary. It is unambiguous: if registration is skipped,
/// the function does not exist; if registration runs, `moor_contains`
/// returns 0/1 for substring match.
void main() {
  group('enableNativeFunctions gate (in-process)', () {
    test('default true registers moor_contains()', () async {
      final db = NativeDatabase.memory();
      await db.ensureOpen(_FakeExecutorUser());
      final result = await db.runSelect(
        "SELECT moor_contains('haystack', 'hay') AS r;",
        const [],
      );
      expect(result.single['r'], 1);
      await db.close();
    });

    test('false skips moor_contains() registration', () async {
      final db = NativeDatabase.memory(enableNativeFunctions: false);
      await db.ensureOpen(_FakeExecutorUser());
      await expectLater(
        () => db.runSelect(
          "SELECT moor_contains('haystack', 'hay');",
          const [],
        ),
        throwsA(
          isA<SqliteException>().having(
            (e) => e.message,
            'message',
            contains('no such function: moor_contains'),
          ),
        ),
      );
      await db.close();
    });

    test('false skips current_time_millis() registration', () async {
      final db = NativeDatabase.memory(enableNativeFunctions: false);
      await db.ensureOpen(_FakeExecutorUser());
      await expectLater(
        () => db.runSelect('SELECT current_time_millis();', const []),
        throwsA(
          isA<SqliteException>().having(
            (e) => e.message,
            'message',
            contains('no such function: current_time_millis'),
          ),
        ),
      );
      await db.close();
    });
  });

  group('enableNativeFunctions gate (background isolate)', () {
    late File tempFile;

    setUp(() async {
      tempFile = File('${Directory.systemTemp.path}/'
          'drift-gate-test-${DateTime.now().microsecondsSinceEpoch}.db');
      if (tempFile.existsSync()) tempFile.deleteSync();
    });

    tearDown(() async {
      if (tempFile.existsSync()) tempFile.deleteSync();
    });

    test('default true registers moor_contains() in worker isolate',
        () async {
      final executor = NativeDatabase.createInBackground(tempFile);
      await executor.ensureOpen(_FakeExecutorUser());
      final result = await executor.runSelect(
        "SELECT moor_contains('haystack', 'hay') AS r;",
        const [],
      );
      expect(result.single['r'], 1);
      await executor.close();
    });

    test('false skips moor_contains() in worker isolate', () async {
      final executor = NativeDatabase.createInBackground(
        tempFile,
        enableNativeFunctions: false,
      );
      await executor.ensureOpen(_FakeExecutorUser());
      // The SqliteException is wrapped in a DriftRemoteException when it
      // crosses the isolate boundary. Match on the rendered message
      // rather than the exception type — what matters is that the gate
      // suppressed the function registration in the worker.
      await expectLater(
        () => executor.runSelect(
          "SELECT moor_contains('haystack', 'hay');",
          const [],
        ),
        throwsA(
          predicate(
            (e) => e.toString().contains('no such function: moor_contains'),
            'wraps "no such function: moor_contains"',
          ),
        ),
      );
      await executor.close();
    });
  });
}

class _FakeExecutorUser extends QueryExecutorUser {
  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) {
    return Future.value();
  }

  @override
  int get schemaVersion => 1;
}
