import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where backup files go: the phone's own "save as" and "open" choosers
/// (Downloads, Google Drive, a USB stick…). No permissions are needed.
class BackupFiles {
  const BackupFiles();

  /// Lets the child (or a grown-up) save [bytes] as [name]. False if they
  /// cancelled.
  Future<bool> save(String name, Uint8List bytes) async {
    final uri = await FilePicker.saveFile(fileName: name, bytes: bytes, mimeType: 'application/json');
    // On the web the browser downloads it and there is nothing to return.
    return uri != null || kIsWeb;
  }

  /// Lets them pick a saved file. Null if they cancelled.
  Future<Uint8List?> pick() async {
    final file = await FilePicker.pickFile();
    return file == null ? null : await file.readAsBytes();
  }
}

/// The app's backup chooser (tests replace it with a fake).
final backupFilesProvider = Provider<BackupFiles>((ref) => const BackupFiles());
