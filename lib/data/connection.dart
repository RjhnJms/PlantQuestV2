import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Opens the on-device database file `plantquest.sqlite`.
///
/// On Android and iOS it lives in the app's private documents folder (no
/// storage permission needed). The browser preview stores it in the
/// browser, using `web/sqlite3.wasm` and `web/drift_worker.js`.
QueryExecutor openPlantQuestDatabase() => driftDatabase(
  name: 'plantquest',
  web: DriftWebOptions(sqlite3Wasm: Uri.parse('sqlite3.wasm'), driftWorker: Uri.parse('drift_worker.js')),
);
