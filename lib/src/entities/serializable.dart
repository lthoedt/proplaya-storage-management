import 'dart:convert';
import 'dart:io';

import 'package:proplaya_storage_management/src/def/storage_types.dart';

abstract class Serializable {
  final String id;
  final String url;
  final bool? downloaded;
  abstract final StorageTypes type;
  final List<Serializable>? children;

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
      };

  String serialize() => jsonEncode(toJson());
}
