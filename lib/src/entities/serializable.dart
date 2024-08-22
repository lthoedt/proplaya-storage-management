import 'dart:convert';
import 'dart:io';

import 'package:proplaya_storage_management/src/def/storage_types.dart';

abstract class Serializable {
  final String id;
  final String url;
  bool? downloaded;
  abstract final StorageTypes type;
  final List<Serializable>? children;
  int? batchSize;

  Serializable({
    required this.id,
    required this.url,
    this.downloaded,
    this.children,
  });

  Future<File?>? download(String pathWithName) => null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'downloaded': downloaded,
        'url': url,
        'batchSize': batchSize,
      };

  String serialize() => jsonEncode(toJson());
}
