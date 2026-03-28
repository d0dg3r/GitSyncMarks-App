import '../models/bookmark_node.dart';
import 'linkwarden_api.dart';

class LinkwardenSyncResult {
  const LinkwardenSyncResult({
    required this.collections,
    required this.totalLinks,
    required this.folder,
  });

  final int collections;
  final int totalLinks;
  final BookmarkFolder folder;
}

/// Fetches collections and links from a Linkwarden instance and builds
/// a virtual [BookmarkFolder] tree mirroring the Linkwarden structure.
Future<LinkwardenSyncResult> fetchLinkwardenAsFolder(
  LinkwardenAPI api,
) async {
  final collections = await api.getCollections();
  final allLinks = await api.getLinks();

  final collectionMap = <int?, List<LinkwardenLink>>{};
  collectionMap[null] = [];
  for (final c in collections) {
    collectionMap[c.id] = [];
  }

  for (final link in allLinks) {
    final colId = link.collectionId;
    if (collectionMap.containsKey(colId)) {
      collectionMap[colId]!.add(link);
    } else {
      collectionMap[null]!.add(link);
    }
  }

  final subFolders = <BookmarkNode>[];

  for (final c in collections) {
    final links = collectionMap[c.id] ?? [];
    if (links.isEmpty) continue;
    subFolders.add(BookmarkFolder(
      title: c.name,
      children: links
          .map((l) => Bookmark(title: l.name, url: l.url))
          .toList(),
      dirName: 'lw-${c.id}',
    ));
  }

  final unorganized = collectionMap[null] ?? [];
  if (unorganized.isNotEmpty) {
    subFolders.insert(
      0,
      BookmarkFolder(
        title: 'Unorganized',
        children: unorganized
            .map((l) => Bookmark(title: l.name, url: l.url))
            .toList(),
        dirName: 'lw-unorganized',
      ),
    );
  }

  final rootFolder = BookmarkFolder(
    title: 'Linkwarden',
    children: subFolders,
    dirName: '_linkwarden',
  );

  return LinkwardenSyncResult(
    collections: collections.length,
    totalLinks: allLinks.length,
    folder: rootFolder,
  );
}
