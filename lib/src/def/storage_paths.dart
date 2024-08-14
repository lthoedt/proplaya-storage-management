import 'package:proplaya_storage_management/proplaya_storage_management.dart';

String getStoragePathOf(StorageTypes type) => switch (type) {
      StorageTypes.playlist => "playlists/",
      StorageTypes.song => "songs/",
    };
