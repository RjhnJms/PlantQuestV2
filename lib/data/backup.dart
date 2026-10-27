import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';

/// Why a backup file couldn't be loaded.
enum BackupProblem {
  /// Not a PlantQuest progress file at all.
  notABackup,

  /// Saved by a newer PlantQuest than this one.
  tooNew,
}

class BackupException implements Exception {
  const BackupException(this.problem);
  final BackupProblem problem;

  @override
  String toString() => 'BackupException($problem)';
}

/// Saving all of a child's progress to one file and loading it back
/// (PLAN.md §5h). The file is plain JSON: every table's rows exactly as
/// stored, so nothing is lost and older backups load into newer versions
/// (new columns take their defaults, new tables start empty).
class Backup {
  Backup(this.db, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final AppDatabase db;
  final DateTime Function() _now;

  static const marker = 'PlantQuest progress';

  Iterable<String> get _tables => db.allTables.map((t) => t.actualTableName);

  /// Everything, as the bytes of a JSON file.
  Future<Uint8List> export() async {
    final tables = <String, List<Map<String, Object?>>>{};
    for (final t in _tables) {
      final rows = await db.customSelect('SELECT * FROM "$t"').get();
      tables[t] = [for (final r in rows) r.data];
    }
    final file = {'app': marker, 'schema': db.schemaVersion, 'savedAt': _now().toIso8601String(), 'tables': tables};
    return Uint8List.fromList(utf8.encode(const JsonEncoder.withIndent(' ').convert(file)));
  }

  /// Replaces all progress with the backup in [bytes]. Throws a
  /// [BackupException] (and changes nothing) if the file can't be used.
  Future<void> restore(List<int> bytes) async {
    final Map<String, Object?> file;
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?> || decoded['app'] != marker || decoded['tables'] is! Map) {
        throw const BackupException(BackupProblem.notABackup);
      }
      file = decoded;
    } on FormatException {
      throw const BackupException(BackupProblem.notABackup);
    }
    final schema = file['schema'];
    if (schema is! int) throw const BackupException(BackupProblem.notABackup);
    if (schema > db.schemaVersion) throw const BackupException(BackupProblem.tooNew);
    final saved = file['tables']! as Map<String, Object?>;

    await db.transaction(() async {
      for (final t in _tables) {
        final columns = {
          for (final c in await db.customSelect('PRAGMA table_info("$t")').get()) c.read<String>('name'),
        };
        await db.customStatement('DELETE FROM "$t"');
        final rows = saved[t];
        if (rows is! List) continue;
        for (final row in rows.whereType<Map<String, Object?>>()) {
          // Only columns this version knows; missing ones get their defaults.
          final keys = [
            for (final k in row.keys)
              if (columns.contains(k)) k,
          ];
          if (keys.isEmpty) continue;
          await db.customInsert(
            'INSERT INTO "$t" (${keys.map((k) => '"$k"').join(', ')}) '
            'VALUES (${List.filled(keys.length, '?').join(', ')})',
            variables: [for (final k in keys) Variable(row[k])],
            updates: {db.allTables.firstWhere((x) => x.actualTableName == t)},
          );
        }
      }
    });
    // Tell every screen that watches a table to read it again.
    db.notifyUpdates({for (final t in db.allTables) TableUpdate.onTable(t)});
  }

  /// A friendly file name, e.g. "PlantQuest-Jamie-2026-10-26.json".
  static String fileName(String? childName, DateTime when) {
    final name = (childName ?? 'Explorer').replaceAll(RegExp(r'[^A-Za-z0-9]+'), '');
    String two(int n) => n.toString().padLeft(2, '0');
    return 'PlantQuest-${name.isEmpty ? 'Explorer' : name}-${when.year}-${two(when.month)}-${two(when.day)}.json';
  }
}
