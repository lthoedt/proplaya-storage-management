import 'dart:convert';
import 'dart:io';

import 'package:proplaya_storage_management/src/def/storage_types.dart';
import 'package:proplaya_storage_management/src/entities/helpers/cacher.dart';

abstract class Serializable<T> {
  final String id;
  final String url;
  bool? downloaded;
  abstract final StorageTypes type;
  late final Cacher<List<T>> _children;
  int? batchSize;

  Serializable({
    required this.id,
    required this.url,
    this.downloaded,
    List<T>? children,
  }) {
    this._children = Cacher<List<T>>(children);
  }

  Future<File?>? download(String pathWithName) => null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'downloaded': downloaded,
        'url': url,
        if (batchSize != null) 'batchSize': batchSize,
      };

  String serialize() => jsonEncode(toJson());

  List<T>? get children => this._children.value;

  Future<List<T>?>? getChildren(
    String id, {
    bool force = false,
  }) =>
      this._children.get(() => getChildren_(id), force: force);

  Future<List<T>?>? getChildren_(String id);
}
