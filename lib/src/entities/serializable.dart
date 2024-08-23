import 'dart:convert';
import 'dart:io';

import 'package:proplaya_storage_management/src/def/storage_types.dart';
import 'package:proplaya_storage_management/src/entities/helpers/cacher.dart';

abstract class Serializable<T> {
  final String id;
  final String url;
  bool? downloaded;
  abstract final StorageTypes type;

  /// If this is null then children are not used.
  late final Cacher<List<T>>? _children;
  int? batchSize;

  Serializable({
    required this.id,
    required this.url,
    this.downloaded,
    List<T>? children,
  }) {
    this._children =
        (getChildren_(this.id) != null) ? Cacher<List<T>>(children) : null;
  }

  /// Downloads the file from the url and saves it to the pathWithName.
  Future<File?>? download(String pathWithName) => null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'downloaded': downloaded,
        'url': url,
        if (batchSize != null) 'batchSize': batchSize,
      };

  /// Encodes the toJson() map to a json string.
  String serialize() => jsonEncode(toJson());

  /// Children getter that returns the value of the cacher.
  /// If they are not loaded yet, it will return null.
  List<T>? get children => this._children?.value;

  /// Children getter that loads the children via the cacher.
  Future<List<T>?>? getChildren(
    String id, {
    bool force = false,
  }) =>
      this._children?.get(() => getChildren_(id), force: force);

  /// @protected
  ///
  /// Override this method with a function to fetch the children via for example an API.
  ///
  /// Return null if you dont use children.
  Future<List<T>?>? getChildren_(String id) => null;
}
