import 'dart:math' as math;
import 'package:flutter/services.dart';

/// ============================================================
/// 音效管理器 — 使用 Flutter Asset + 系统音效
/// ============================================================
class AudioManager {
  static final AudioManager _instance = AudioManager._();
  factory AudioManager() => _instance;
  AudioManager._();

  bool _muted = false;
  bool get muted => _muted;

  void toggleMute() => _muted = !_muted;

  /// 播放音效（通过Flutter asset）
  Future<void> play(String soundId) async {
    if (_muted) return;
    // 由于没有实际音频文件，这里通过HapticFeedback模拟
    switch (soundId) {
      case 'card_play':
        await HapticFeedback.lightImpact();
        break;
      case 'attack':
        await HapticFeedback.mediumImpact();
        break;
      case 'death':
        await HapticFeedback.heavyImpact();
        break;
      case 'draw':
        await HapticFeedback.selectionClick();
        break;
      case 'summon':
        await HapticFeedback.lightImpact();
        break;
      case 'heal':
        await HapticFeedback.selectionClick();
        break;
      default:
        await HapticFeedback.lightImpact();
    }
  }

  /// 震动反馈
  Future<void> vibrate(String type) async {
    switch (type) {
      case 'tap':
        await HapticFeedback.selectionClick();
        break;
      case 'success':
        await HapticFeedback.lightImpact();
        break;
      case 'error':
        await HapticFeedback.heavyImpact();
        break;
    }
  }
}
