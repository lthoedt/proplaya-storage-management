import 'package:proplaya_storage_management/proplaya_storage_management.dart';

int getBatchsizeOf(StorageTypes type) => switch (type) {
      StorageTypes.playlist => 10,
      StorageTypes.song => 10,
    };
