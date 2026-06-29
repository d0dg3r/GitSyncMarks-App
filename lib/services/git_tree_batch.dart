import 'dart:convert';

const int treeBatchMaxEntries = 400;
const int treeBatchMaxBytes = 28 * 1024 * 1024;

class TreeUploadEntry {
  TreeUploadEntry(this.path, this.content);
  final String path;
  final String content;
}

class ShaTreeUploadEntry {
  ShaTreeUploadEntry(this.path, this.sha);
  final String path;
  final String sha;
}

List<List<Map<String, dynamic>>> chunkAtomicCommitTreeBatches(
  List<String> deletions,
  List<TreeUploadEntry> uploads,
) {
  final batches = <List<Map<String, dynamic>>>[];
  var batch = <Map<String, dynamic>>[];
  var approxBytes = 0;

  void flush() {
    if (batch.isNotEmpty) {
      batches.add(batch);
      batch = <Map<String, dynamic>>[];
      approxBytes = 0;
    }
  }

  int approxItemBytes(Map<String, dynamic> item) {
    var n = 64 + ((item['path'] as String).length * 2);
    if (item.containsKey('content')) {
      n += utf8.encode(item['content'] as String).length;
    }
    return n;
  }

  void push(Map<String, dynamic> item) {
    final ib = approxItemBytes(item);
    if (batch.isNotEmpty &&
        (batch.length >= treeBatchMaxEntries ||
            approxBytes + ib > treeBatchMaxBytes)) {
      flush();
    }
    batch.add(item);
    approxBytes += ib;
  }

  for (final path in deletions) {
    push({'path': path, 'mode': '100644', 'type': 'blob', 'sha': null});
  }
  for (final u in uploads) {
    push({
      'path': u.path,
      'mode': '100644',
      'type': 'blob',
      'content': u.content,
    });
  }
  flush();
  return batches;
}

/// Tree batches for Gitea-family writes after POST /git/blobs (SHA refs, no inline content).
List<List<Map<String, dynamic>>> chunkAtomicCommitShaTreeBatches(
  List<String> deletions,
  List<ShaTreeUploadEntry> uploads,
) {
  final batches = <List<Map<String, dynamic>>>[];
  var batch = <Map<String, dynamic>>[];
  var approxBytes = 0;

  void flush() {
    if (batch.isNotEmpty) {
      batches.add(batch);
      batch = <Map<String, dynamic>>[];
      approxBytes = 0;
    }
  }

  int approxItemBytes(Map<String, dynamic> item) {
    return 64 + ((item['path'] as String).length * 2);
  }

  void push(Map<String, dynamic> item) {
    final ib = approxItemBytes(item);
    if (batch.isNotEmpty &&
        (batch.length >= treeBatchMaxEntries ||
            approxBytes + ib > treeBatchMaxBytes)) {
      flush();
    }
    batch.add(item);
    approxBytes += ib;
  }

  for (final path in deletions) {
    push({'path': path, 'mode': '100644', 'type': 'blob', 'sha': null});
  }
  for (final u in uploads) {
    push({'path': u.path, 'mode': '100644', 'type': 'blob', 'sha': u.sha});
  }
  flush();
  return batches;
}
