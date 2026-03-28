import 'dart:collection';

/// Ring-buffer debug log for sync diagnostics.
///
/// Keeps the last [maxEntries] log lines in memory. Can be exported as a
/// text file for troubleshooting.
class DebugLogService {
  DebugLogService({this.maxEntries = 500});

  final int maxEntries;
  final _entries = ListQueue<DebugLogEntry>();
  bool enabled = false;

  List<DebugLogEntry> get entries => _entries.toList();

  void log(String message) {
    if (!enabled) return;
    _entries.addLast(DebugLogEntry(
      timestamp: DateTime.now(),
      message: message,
    ));
    while (_entries.length > maxEntries) {
      _entries.removeFirst();
    }
  }

  void clear() => _entries.clear();

  /// Exports the full log as a plain-text string.
  String export() {
    final buf = StringBuffer();
    buf.writeln('GitSyncMarks Debug Log');
    buf.writeln('Exported: ${DateTime.now().toIso8601String()}');
    buf.writeln('Entries: ${_entries.length}');
    buf.writeln('---');
    for (final e in _entries) {
      buf.writeln('[${e.timestamp.toIso8601String()}] ${e.message}');
    }
    return buf.toString();
  }
}

class DebugLogEntry {
  DebugLogEntry({required this.timestamp, required this.message});

  final DateTime timestamp;
  final String message;
}

/// Global singleton for convenient access.
final debugLog = DebugLogService();
