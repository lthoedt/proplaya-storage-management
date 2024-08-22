import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:proplaya_storage_management/proplaya_storage_management.dart';
import 'package:proplaya_storage_management/src/def/batch_sizes.dart';
import 'dart:async';
import 'package:proplaya_storage_management/src/def/storage_paths.dart';
import 'package:proplaya_storage_management/src/entities/serializable.dart';

class ProplayaStorageManagement {
  String? _basePath;

  Future<String> get basePath async {
    if (_basePath != null) return _basePath!;
    _basePath = p.join(
      (await getApplicationDocumentsDirectory()).path,
      "storage",
    );
    return _basePath!;
  }

  // TODO: Error handling.
  /// Downloads the item and its children.
  Future<void> download(Serializable item) async {
    await _downloadItem(item);

    await _downloadContent(item);

    if (item.children == null) return;

    await _downloadAsBatch(item.children!, item);
  }

  /// Serializes @item to a json file.
  Future<void> _downloadItem(Serializable item) async {
    // Create a file of the serialized item.
    final File file = File(
      p.join(
        await basePath,
        getItemInfoPath(item),
      ),
    );

    await file.create(recursive: true);
    await file.writeAsString(item.serialize().toString());
  }

  /// Downloads the content of an item.
  Future<void> _downloadContent(Serializable item) async {
    // Downloads the corresponding data.
    // Example: If item is a song, download the audio.
    final downloadingFile = item.download(
      p.join(
        await basePath,
        getItemDataPath(item),
      ),
    );

    if (downloadingFile is Future) {
      print("Downloading ${item.id}...");
      await downloadingFile;
      print("Downloaded ${item.id}.");
      return; // If the item as a file to downloaded, then its children are not downloaded. (as they shouldnt exist)
    }
  }

  Future<void> _downloadAsBatch<T extends Serializable>(
    List<T> items,
    Serializable parent,
  ) async {
    final int batchSize = getBatchsizeOf(parent.type);
    File? batchfile;
    Map<String, String>? batch; // Index: id (jsonEncode doesnt like int keys)

    final String batchPath = p.join(
      await basePath,
      getContentPath(parent),
    );

    // Downloads the children of the item.
    for (final iv in items.indexed) {
      final index = iv.$1;
      final child = iv.$2;
      if (index % batchSize == 0) {
        batchfile = File(
          p.setExtension(
            p.join(
              batchPath,
              "${index / batchSize}",
            ),
            ".json",
          ),
        );
        if (await batchfile.exists()) {
          batch = Map.castFrom(jsonDecode(await batchfile.readAsString()));
        } else {
          await batchfile.create(recursive: true);
          batch = {};
        }
      }
      await download(child);
      batch!["$index"] = child.id;
      // Writes the current batch to the batchfile.
      if (index % batchSize == batchSize - 1 || index == items.length - 1) {
        await batchfile!.writeAsString(jsonEncode(batch));
        batch = null;
      }
    }
  }
}
