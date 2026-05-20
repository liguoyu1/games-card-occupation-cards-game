import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

extension _V2Ext on Vector2 {
  Offset toOff() => Offset(x, y);
}

/// ============================================================
/// 伤害数字飘字动画
/// ============================================================
class DamageNumberComponent extends PositionComponent {
  final String text;
  final Color color;
  final double fontSize;
  double _progress = 0.0;
  final double speed;

  DamageNumberComponent({
    required Vector2 position,
    required this.text,
    this.color = AppColors.danger,
    this.fontSize = 24,
    this.speed = 1.5,
  }) : super(
          position: position,
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _progress += dt * speed;

    // 上移动画
    position.y -= dt * 40;

    // 淡出
    if (_progress > 0.6) {
      final alpha = 1.0 - (_progress - 0.6) / 0.4;
      // 透明度通过隐藏处理
      if (_progress >= 1.0) {
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final alpha = _progress < 0.6 ? 1.0 : 1.0 - (_progress - 0.6) / 0.4;
    final scale = _progress < 0.2 ? 0.5 + _progress / 0.2 * 0.5 : 1.0;

    canvas.save();
    canvas.scale(scale, scale);

    // 文字描边（黑边白字）
    final shadowPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black.withValues(alpha: alpha * 0.8),
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    shadowPainter.layout();
    shadowPainter.paint(
      canvas,
      Offset(-shadowPainter.width / 2 - 1, -shadowPainter.height / 2 - 1),
    );
    shadowPainter.paint(
      canvas,
      Offset(-shadowPainter.width / 2 + 1, -shadowPainter.height / 2 + 1),
    );

    // 主文字
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withValues(alpha: alpha),
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }
}

/// ============================================================
/// 攻击指示线
/// ============================================================
class AttackLineComponent extends PositionComponent {
  final Vector2 start;
  final Vector2 end;
  final Color color;
  double _progress = 0.0;
  double _duration = 0.3;
  bool _done = false;

  AttackLineComponent({
    required this.start,
    required this.end,
    this.color = AppColors.danger,
  }) : super(anchor: Anchor.topLeft);

  @override
  void update(double dt) {
    super.update(dt);
    _progress += dt / _duration;
    _progress = _progress.clamp(0.0, 1.0);
    if (_progress >= 1.0 && !_done) {
      _done = true;
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // 当前端点（从起点到终点）
    final currentEnd = Vector2(
      start.x + (end.x - start.x) * _progress,
      start.y + (end.y - start.y) * _progress,
    );

    // 发光效果
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawLine(start.toOff(), currentEnd.toOff(), glowPaint);

    // 主线
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start.toOff(), currentEnd.toOff(), linePaint);

    // 箭头
    if (_progress > 0.8) {
      final arrowAlpha = (_progress - 0.8) / 0.2;
      _drawArrow(canvas, currentEnd, end, color.withValues(alpha: arrowAlpha));
    }
  }

  void _drawArrow(Canvas canvas, Vector2 from, Vector2 to, Color color) {
    final angle = (to - from).angleTo(Vector2(0, 0));
    const arrowSize = 10.0;

    final path = Path()
      ..moveTo(to.x, to.y)
      ..lineTo(
        to.x - arrowSize * 1.5 * (to - from).normalized().x + arrowSize * 0.5 * (to - from).normalized().y,
        to.y - arrowSize * 1.5 * (to - from).normalized().y - arrowSize * 0.5 * (to - from).normalized().x,
      )
      ..lineTo(
        to.x - arrowSize * 1.5 * (to - from).normalized().x - arrowSize * 0.5 * (to - from).normalized().y,
        to.y - arrowSize * 1.5 * (to - from).normalized().y + arrowSize * 0.5 * (to - from).normalized().x,
      )
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }
}

extension on Vector2 {
  Offset toOffset() => Offset(x, y);
}
