import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../network/game_client.dart';
import 'constants.dart';

/// ============================================================
/// 联网对战 Game
/// ============================================================
class NetworkBattleGame extends FlameGame with TapCallbacks {
  final NetworkClient client;
  late GameState _state;

  NetworkBattleGame({required this.client});

  @override
  Color backgroundColor() => AppColors.primaryBg;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    client.addListener(_msgListener);
  }

  void _msgListener(String type, dynamic data) {
    switch (type) {
      case 'game_state':
        _state = (data as GameStateMessage).state;
        break;
      case 'game_over':
        final info = data as GameOverInfo;
        // 显示结果
        break;
      case 'action_error':
        // 显示错误
        break;
      case 'disconnected':
        break;
    }
  }

  void playCard(int index) => client.playCard(index);
  void attackMinion(int from, int to) => client.attackMinion(from, to);
  void attackHero(int from) => client.attackHero(from);
  void endTurn() => client.endTurn();

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 渲染联网游戏状态（简化版）
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = AppColors.primaryBg);

    final title = TextPainter(
      text: const TextSpan(text: '联网对战', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    title.paint(canvas, Offset(size.x / 2 - title.width / 2, 40));
  }

  @override
  void onDispose() {
    client.removeListener(_msgListener);
    super.onDispose();
  }
}
