import 'package:flutter_test/flutter_test.dart';
import 'package:gitsyncmarks/services/git_tree_batch.dart';

void main() {
  group('chunkAtomicCommitShaTreeBatches', () {
    test('empty inputs yield no batches', () {
      expect(chunkAtomicCommitShaTreeBatches([], []), isEmpty);
    });

    test('uploads use blob sha refs', () {
      final batches = chunkAtomicCommitShaTreeBatches(
        [],
        [ShaTreeUploadEntry('bookmarks/a.json', 'abc123')],
      );
      expect(batches, hasLength(1));
      expect(batches.first.single['sha'], 'abc123');
      expect(batches.first.single.containsKey('content'), isFalse);
    });

    test('deletions set sha null', () {
      final batches = chunkAtomicCommitShaTreeBatches(
        ['bookmarks/old.json'],
        [],
      );
      expect(batches.first.single['sha'], isNull);
    });
  });
}
