import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// S / M / L density modes for bookmark list items.
enum AppDensity { small, medium, large }

/// Controls the UI density (list item height, padding, font size).
class AppDensityController extends ChangeNotifier {
  AppDensityController() {
    _load();
  }

  static const _key = 'appDensity';
  AppDensity _density = AppDensity.medium;

  AppDensity get density => _density;

  double get listItemHeight {
    return switch (_density) {
      AppDensity.small => 48,
      AppDensity.medium => 64,
      AppDensity.large => 80,
    };
  }

  double get titleFontSize {
    return switch (_density) {
      AppDensity.small => 13,
      AppDensity.medium => 14,
      AppDensity.large => 16,
    };
  }

  double get subtitleFontSize {
    return switch (_density) {
      AppDensity.small => 11,
      AppDensity.medium => 12,
      AppDensity.large => 13,
    };
  }

  EdgeInsets get listItemPadding {
    return switch (_density) {
      AppDensity.small =>
        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      AppDensity.medium =>
        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      AppDensity.large =>
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    };
  }

  double get iconSize {
    return switch (_density) {
      AppDensity.small => 16,
      AppDensity.medium => 20,
      AppDensity.large => 24,
    };
  }

  Future<void> setDensity(AppDensity d) async {
    if (_density == d) return;
    _density = d;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, d.name);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null) {
      _density = AppDensity.values.firstWhere(
        (v) => v.name == stored,
        orElse: () => AppDensity.medium,
      );
      notifyListeners();
    }
  }
}
