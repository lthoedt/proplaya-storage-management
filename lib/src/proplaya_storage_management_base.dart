import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:proplaya_storage_management/src/def/storage_paths.dart';
import 'package:proplaya_storage_management/src/entities/serializable.dart';

class ProplayaStorageManagement {
  // TODO: Error handling.
  /// Creates a json file for the item.
  /// Downloads the data of the item.
  /// Downloads the children of the item.
  Future<void> download(Serializable item) async {
    final String itemPath = p.join(
      (await getApplicationDocumentsDirectory()).path,
      "storage",
      getStoragePathOf(item.type),
    );

    // Create a file of the serialized item.
    final File file = File(
      p.setExtension(
        p.join(
          itemPath,
          item.id,
        ),
        ".json",
      ),
    );
    await file.create(recursive: true);
    await file.writeAsString(item.serialize().toString());

    // Downloads the corresponding data.
    // Example: If item is a song, download the audio.
    final downloadingFile = item.download(
      p.join(
        itemPath,
        item.id,
      ),
    );

    if (downloadingFile is Future) {
      print("Downloading ${item.id}...");
      await downloadingFile;
      print("Downloaded ${item.id}.");
      return; // If the item as a file to downloaded, then its children are not downloaded. (as they shouldnt exist)
    }

    if (item.children == null) return;

    // TODO: Implement batching as now the children are downloaded one by one.
    // Downloads the children of the item.
    for (final Serializable child in item.children!) {
      await download(child);
    }
  }
}
