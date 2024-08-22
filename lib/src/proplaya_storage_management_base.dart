import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:proplaya_storage_management/proplaya_storage_management.dart';
import 'package:proplaya_storage_management/src/def/batch_sizes.dart';
import 'dart:async';
import 'package:proplaya_storage_management/src/def/storage_paths.dart';
import 'package:proplaya_storage_management/src/entities/serializable.dart';
import 'package:proplaya_storage_management/src/helpers/batch_handler.dart';

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
  Future<bool?> download(Serializable item) async {
    /// Sets the download status according to the downloaded content.
    /// null: No content to download.
    /// true: Content downloaded.
    /// false: Content failed to download.
    final downloaded = await _downloadContent(item);
    item.downloaded = downloaded;

    if (item.children != null) {
      final allDownloaded = await _downloadAsBatch(item.children!, item);
      if (allDownloaded != null) {
        item.downloaded = (allDownloaded) ? item.downloaded ?? true : false;
      }
    }

    // This has to be done last so that all fields are updated.
    await _downloadItem(item);

    return item.downloaded;
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
  Future<bool?> _downloadContent(Serializable item) async {
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
      try {
        await downloadingFile;
      } catch (e) {
        print(e);
        print("Failed to download ${item.id}.");
        return false;
      }
      print("Downloaded ${item.id}.");
      return true; // If the item as a file to downloaded, then its children are not downloaded. (as they shouldnt exist)
    }
    return null;
  }

  /// Downloads the items.
  /// Stores references to those at the parent.
  Future<bool?> _downloadAsBatch<T extends Serializable>(
    List<T> items,
    Serializable parent,
  ) async {
    final int batchSize = getBatchsizeOf(parent.type);

    parent.batchSize = batchSize;

    final String batchPath = p.join(
      await basePath,
      getContentPath(parent),
    );

    final BatchHandler batchHandler = BatchHandler(
      batchSize: batchSize,
      batchPath: batchPath,
    );

    bool? allDownloaded;

    await batchHandler.handle(items, (item) async {
      final downloaded = await download(item);
      if (downloaded != null) {
        allDownloaded = (downloaded) ? allDownloaded ?? true : false;
      }
      return item.id;
    });

    return allDownloaded;
  }
}
