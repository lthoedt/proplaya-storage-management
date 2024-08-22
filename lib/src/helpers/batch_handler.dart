import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

enum PositionInBatch {
  first,
  middle,
  last,
}

class BatchHandler {
  final int batchSize;
  final String batchPath;

  BatchHandler({
    required this.batchSize,
    required this.batchPath,
  });

  File? batchfile;
  Map<String, String>? batch; // {index: id} (jsonEncode doesnt like int keys)

  /// Batches the items and places links to the batchfiles in the parent.
  Future<void> handle<T>(
    List<T> items,
    Future<String> Function(T item) handle,
  ) async {
    for (final iv in items.indexed) {
      final index = iv.$1;
      final child = iv.$2;

      final PositionInBatch position = (index % batchSize == 0)
          ? PositionInBatch.first
          : (index % batchSize == batchSize - 1)
              ? PositionInBatch.last
              : PositionInBatch.middle;

      if (position == PositionInBatch.first) {
        batchfile = File(
          p.setExtension(
            p.join(
              batchPath,
              "${index / batchSize}",
            ),
            ".json",
          ),
        );
        if (await batchfile!.exists()) {
          batch = Map.castFrom(jsonDecode(await batchfile!.readAsString()));
        } else {
          await batchfile!.create(recursive: true);
          batch = {};
        }
      }

      batch!["$index"] = await handle(child);

      // Writes the current batch to the batchfile. (if it is full or if it is the last batch)
      if (position == PositionInBatch.last || index == items.length - 1) {
        await batchfile!.writeAsString(jsonEncode(batch));
        batch = null;
      }
    }
  }
}
