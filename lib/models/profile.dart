import '../config/github_credentials.dart';

/// Maximum number of profiles (matches the browser extension).
const int maxProfiles = 10;

/// Sync profile presets (matches extension).
const Map<String, int> syncProfileIntervals = {
  'realtime': 1,
  'frequent': 5,
  'normal': 15,
  'powersave': 60,
};

/// A named profile wrapping GitHub credentials and folder selection.
class Profile {
  Profile({
    required this.id,
    required this.name,
    required this.credentials,
    List<String>? selectedRootFolders,
    this.autoSyncEnabled = false,
    this.syncProfile = 'normal',
    this.customIntervalMinutes = 15,
    this.syncOnStart = false,
    this.allowMoveReorder = false,
    this.viewRootFolder,
  }) : selectedRootFolders = selectedRootFolders ?? [];

  factory Profile.fromJson(Map<String, dynamic> json) {
    final folders = json['selectedRootFolders'];
    return Profile(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? 'Default',
      credentials: GithubCredentials.fromJson(json),
      selectedRootFolders: folders is List
          ? folders.map((e) => e.toString()).toList()
          : [],
      autoSyncEnabled: json['autoSyncEnabled'] == true,
      syncProfile: json['syncProfile'] as String? ?? 'normal',
      customIntervalMinutes: (json['customIntervalMinutes'] as num?)?.toInt() ?? 15,
      syncOnStart: json['syncOnStart'] == true,
      allowMoveReorder: false,
      viewRootFolder: json['viewRootFolder'] as String?,
    );
  }

  final String id;
  final String name;
  final GithubCredentials credentials;
  final List<String> selectedRootFolders;
  final bool autoSyncEnabled;
  final String syncProfile;
  final int customIntervalMinutes;
  final bool syncOnStart;
  final bool allowMoveReorder;

  /// When set, this folder's children become the tab-bar tabs instead of
  /// the top-level root folders.  Supports nested paths ("toolbar/dev-tools").
  final String? viewRootFolder;

  /// Sync interval in minutes for this profile.
  int get syncIntervalMinutes {
    if (syncProfile == 'custom') return customIntervalMinutes;
    return syncProfileIntervals[syncProfile] ?? 15;
  }

  Profile copyWith({
    String? id,
    String? name,
    GithubCredentials? credentials,
    List<String>? selectedRootFolders,
    bool? autoSyncEnabled,
    String? syncProfile,
    int? customIntervalMinutes,
    bool? syncOnStart,
    bool? allowMoveReorder,
    String? viewRootFolder,
    bool clearViewRootFolder = false,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      credentials: credentials ?? this.credentials,
      selectedRootFolders: selectedRootFolders ?? this.selectedRootFolders,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncProfile: syncProfile ?? this.syncProfile,
      customIntervalMinutes: customIntervalMinutes ?? this.customIntervalMinutes,
      syncOnStart: syncOnStart ?? this.syncOnStart,
      allowMoveReorder: allowMoveReorder ?? this.allowMoveReorder,
      viewRootFolder: clearViewRootFolder ? null : (viewRootFolder ?? this.viewRootFolder),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        ...credentials.toJson(),
        'selectedRootFolders': selectedRootFolders,
        'autoSyncEnabled': autoSyncEnabled,
        'syncProfile': syncProfile,
        'customIntervalMinutes': customIntervalMinutes,
        'syncOnStart': syncOnStart,
        if (viewRootFolder != null) 'viewRootFolder': viewRootFolder,
      };
}
