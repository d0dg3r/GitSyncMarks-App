import 'dart:convert';

import 'package:http/http.dart' as http;

class LinkwardenCollection {
  const LinkwardenCollection({required this.id, required this.name});

  final int id;
  final String name;
}

class LinkwardenLink {
  const LinkwardenLink({
    required this.id,
    required this.url,
    required this.name,
    this.description,
    this.collectionId,
    this.tags = const [],
  });

  final int id;
  final String url;
  final String name;
  final String? description;
  final int? collectionId;
  final List<String> tags;
}

class LinkwardenAPI {
  LinkwardenAPI({required this.baseUrl, required this.token})
      : _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');

  final String baseUrl;
  final String token;
  final String _baseUrl;

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>> _fetch(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    late http.Response res;

    switch (method) {
      case 'POST':
        res = await http.post(
          uri,
          headers: {..._headers, 'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
      case 'DELETE':
        res = await http.delete(uri, headers: _headers);
      default:
        res = await http.get(uri, headers: _headers);
    }

    if (res.statusCode == 204) return {};

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'HTTP ${res.statusCode}';
      try {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        msg = data['error']?.toString() ??
            data['message']?.toString() ??
            msg;
      } catch (_) {}
      throw Exception('Linkwarden API error: $msg');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> _fetchAll(String endpoint) async {
    final all = <Map<String, dynamic>>[];
    final seenIds = <int>{};
    int page = 1;

    while (true) {
      final sep = endpoint.contains('?') ? '&' : '?';
      final paginated = endpoint.contains('/links')
          ? (all.isEmpty
              ? endpoint
              : '$endpoint${sep}cursor=${all.last['id']}')
          : '$endpoint${sep}page=$page';

      final data = await _fetch(paginated);
      final items = (data['response'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      if (items.isEmpty) break;

      int newCount = 0;
      for (final item in items) {
        final id = item['id'] as int;
        if (!seenIds.contains(id)) {
          seenIds.add(id);
          all.add(item);
          newCount++;
        }
      }

      if (newCount == 0 || items.length < 50) break;
      if (all.length >= 10000 || page > 200) break;
      page++;
    }

    return all;
  }

  Future<bool> testConnection() async {
    await _fetch('/api/v1/collections?limit=1');
    return true;
  }

  Future<List<LinkwardenCollection>> getCollections() async {
    final items = await _fetchAll('/api/v1/collections');
    return items
        .map((c) => LinkwardenCollection(
              id: c['id'] as int,
              name: (c['name'] as String?) ?? '',
            ))
        .toList();
  }

  Future<List<LinkwardenLink>> getLinks({int? collectionId}) async {
    var endpoint = '/api/v1/links';
    if (collectionId != null) {
      endpoint += '?collectionId=$collectionId';
    }
    final items = await _fetchAll(endpoint);
    return items
        .map((l) => LinkwardenLink(
              id: l['id'] as int,
              url: (l['url'] as String?) ?? '',
              name: (l['name'] as String?) ?? (l['url'] as String?) ?? '',
              description: l['description'] as String?,
              collectionId: (l['collection'] as Map?)?['id'] as int?,
              tags: ((l['tags'] as List?) ?? [])
                  .map((t) => (t as Map)['name']?.toString() ?? '')
                  .where((n) => n.isNotEmpty)
                  .toList(),
            ))
        .toList();
  }

  Future<LinkwardenLink> saveLink({
    required String url,
    required String name,
    String? description,
    int? collectionId,
    List<String>? tags,
  }) async {
    final payload = <String, dynamic>{
      'url': url,
      'name': name,
      'description': description ?? '',
      'tags': (tags ?? []).map((t) => {'name': t.trim()}).toList(),
    };
    if (collectionId != null) {
      payload['collection'] = {'id': collectionId};
    }

    final data = await _fetch('/api/v1/links', method: 'POST', body: payload);
    final r = data['response'] as Map<String, dynamic>;
    return LinkwardenLink(
      id: r['id'] as int,
      url: r['url'] as String,
      name: (r['name'] as String?) ?? url,
    );
  }

  Future<void> deleteLink(int id) async {
    await _fetch('/api/v1/links/$id', method: 'DELETE');
  }
}
