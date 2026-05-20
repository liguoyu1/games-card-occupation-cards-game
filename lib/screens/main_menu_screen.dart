import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../game/constants.dart';

/// ============================================================
/// 主菜单界面
/// ============================================================
class MainMenuGame extends FlameGame with TapCallbacks {
  final VoidCallback? onStartGame;
  final VoidCallback? onCollection;
  final VoidCallback? onOnlineBattle;

  MainMenuGame({this.onStartGame, this.onCollection, this.onOnlineBattle});

  @override
  Color backgroundColor() => AppColors.primaryBg;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _buildUI();
  }

  void _buildUI() {
    // 背景粒子
    add(_Particles());

    // 标题
    add(_MainTitle(position: Vector2(size.x / 2, 150)));

    // 副标题
    add(_SubTitleText(position: Vector2(size.x / 2, 200), text: '现实职业 · 牌面对决'));

    // 开始按钮
    add(_MenuButton(
      position: Vector2(size.x / 2, 350),
      text: '开始对战',
      onTap: onStartGame,
    ));

    // 牌库按钮
    add(_MenuButton(
      position: Vector2(size.x / 2, 420),
      text: '牌库图鉴',
      onTap: onCollection,
    ));

    // 联网对战按钮
    add(_MenuButton(
      position: Vector2(size.x / 2, 490),
      text: '联网对战',
      onTap: onOnlineBattle,
    ));
  }
}

class _Particles extends PositionComponent {
  @override
  void render(Canvas canvas) {
    final pts = [
      Offset(100, 200), Offset(300, 150), Offset(500, 300), Offset(700, 180),
      Offset(900, 250), Offset(1100, 160), Offset(200, 500), Offset(600, 400),
      Offset(400, 600), Offset(800, 550), Offset(1000, 450), Offset(1200, 500),
    ];
    for (final pt in pts) {
      canvas.drawCircle(pt, 2,
        Paint()..color = AppColors.accent.withValues(alpha: 0.12)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
  }
}

class _MainTitle extends PositionComponent {
  _MainTitle({required Vector2 position}) : super(position: position);

  @override
  void render(Canvas canvas) {
    // 背景装饰
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-180, -40, 360, 80), const Radius.circular(16)),
      Paint()..color = AppColors.secondaryBg,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-180, -40, 360, 80), const Radius.circular(16)),
      Paint()..color = AppColors.accent..style = PaintingStyle.stroke..strokeWidth = 2,
    );

    final t = TextPainter(
      text: const TextSpan(text: '职业卡牌', style: TextStyle(color: AppColors.accent, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4)),
      textDirection: TextDirection.ltr,
    )..layout();
    t.paint(canvas, Offset(-t.width / 2, -t.height / 2));
  }
}

class _SubTitleText extends PositionComponent {
  final String text;
  _SubTitleText({required Vector2 position, required this.text}) : super(position: position);

  @override
  void render(Canvas canvas) {
    final t = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, letterSpacing: 2)),
      textDirection: TextDirection.ltr,
    )..layout();
    t.paint(canvas, Offset(-t.width / 2, -t.height / 2));
  }
}

class _MenuButton extends PositionComponent with TapCallbacks {
  final String text;
  final VoidCallback? onTap;

  _MenuButton({required Vector2 position, required this.text, this.onTap})
      : super(position: position, size: Vector2(240, 50));

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(12)),
      Paint()..shader = const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
      ).createShader(Rect.fromLTWH(0, 0, 240, 50)),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(12)),
      Paint()..color = Colors.white.withValues(alpha: 0.1)..style = PaintingStyle.stroke..strokeWidth = 1,
    );

    final t = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Color(0xFF0A0E27), fontSize: 16, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    t.paint(canvas, Offset(size.x / 2 - t.width / 2, size.y / 2 - t.height / 2));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap?.call();
  }
}
