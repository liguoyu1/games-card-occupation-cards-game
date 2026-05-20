import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../network/game_client.dart';
import '../game/constants.dart';

/// 联网匹配界面
class MatchmakingGame extends FlameGame {
  NetworkClient? _client;
  String _status = '连接中...';
  double _phase = 0;
  bool _matched = false;
  MatchFoundInfo? _matchInfo;

  final VoidCallback? onMatched;
  final VoidCallback? onBack;

  MatchmakingGame({this.onMatched, this.onBack});

  @override
  Color backgroundColor() => AppColors.primaryBg;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _connectAndMatch();
  }

  void _connectAndMatch() {
    _client = NetworkClient();
    _client!.addListener(_handleMessage);
    try {
      _client!.connect('localhost', 8080);
      _status = '寻找对手...';
      _client!.requestMatch();
    } catch (e) {
      _status = '连接失败\n$e';
    }
  }

  void _handleMessage(String type, dynamic data) {
    switch (type) {
      case 'match_waiting':
        _status = '寻找对手中...';
        break;
      case 'match_found':
        _matchInfo = data as MatchFoundInfo;
        _matched = true;
        _status = '✅ 匹配成功！';
        Future.delayed(const Duration(milliseconds: 800), () => onMatched?.call());
        break;
      case 'error':
        _status = '错误: $data';
        break;
      case 'disconnected':
        _status = '连接断开';
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _phase += dt * 2;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = AppColors.primaryBg);

    // 标题
    final title = TextPainter(
      text: const TextSpan(text: '联网对战', style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    title.paint(canvas, Offset(size.x / 2 - title.width / 2, 120));

    if (!_matched) {
      // 旋转动画点
      final cx = size.x / 2;
      final cy = 280.0;
      for (var i = 0; i < 6; i++) {
        final a = _phase + i * math.pi / 3;
        final sx = cx + 60 * math.cos(a);
        final sy = cy + 30 * math.sin(a);
        final alpha = 0.6 + 0.4 * math.sin(_phase + i * math.pi / 3);
        canvas.drawCircle(Offset(sx, sy), 5, Paint()..color = AppColors.accent.withValues(alpha: alpha));
      }
    }

    // 状态文字
    final st = TextPainter(
      text: TextSpan(text: _status, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
      textDirection: TextDirection.ltr,
    )..layout();
    st.paint(canvas, Offset(size.x / 2 - st.width / 2, 340));

    // 返回提示
    if (onBack != null) {
      final back = TextPainter(
        text: const TextSpan(text: '← 返回主菜单', style: TextStyle(color: AppColors.accent, fontSize: 12)),
        textDirection: TextDirection.ltr,
      )..layout();
      back.paint(canvas, const Offset(20, 680));
    }
  }

  @override
  void onDispose() {
    _client?.disconnect();
    super.onDispose();
  }
}