import 'package:proplaya_storage_management/proplaya_storage_management.dart';
import 'package:path/path.dart' as p;

String getStoragePathOf(StorageTypes type) => switch (type) {
      StorageTypes.playlist => "playlists/",
      StorageTypes.song => "songs/",
    };

String getContentPath(Serializable item) => p.join(
      getStoragePathOf(item.type),
      item.id,
      "content",
    );

String getItemPath(Serializable item) => p.join(
      getStoragePathOf(item.type),
      item.id,
    );

String getItemInfoPath(Serializable item) => p.setExtension(
      p.join(
        getItemPath(item),
        "info",
      ),
      ".json",
    );

String getItemDataPath(Serializable item) => p.join(
      getItemPath(item),
      "data",
    );
