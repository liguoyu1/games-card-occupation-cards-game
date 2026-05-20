import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../game/constants.dart';

/// ============================================================
/// 法力水晶组件
/// ============================================================
class ManaCrystalComponent extends PositionComponent {
  final int maxCrystals;   // 最大水晶数（当前法力上限）
  final int currentMana;   // 当前法力值
  final double crystalSize;
  final double spacing;

  ManaCrystalComponent({
    required Vector2 position,
    required this.maxCrystals,
    required this.currentMana,
    this.crystalSize = 28,
    this.spacing = 32,
    super.anchor = Anchor.topLeft,
  }) : super(position: position, size: Vector2(spacing * maxCrystals, crystalSize));

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < maxCrystals; i++) {
      final cx = i * spacing + crystalSize / 2;
      final cy = crystalSize / 2;
      final isFilled = i < currentMana;

      // 外发光（仅已充能）
      if (isFilled) {
        final glowPaint = Paint()
          ..color = AppColors.manaFull.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(Offset(cx, cy), crystalSize / 2 + 4, glowPaint);
      }

      // 水晶形状（菱形/六边形简化）
      _drawCrystal(canvas, cx, cy, crystalSize / 2, isFilled);
    }
  }

  void _drawCrystal(Canvas canvas, double cx, double cy, double r, bool filled) {
    // 六边形顶点
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 - math.pi / 6;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // 填充
    final fillPaint = Paint()
      ..color = filled
          ? AppColors.manaFull.withValues(alpha: 0.9)
          : AppColors.manaEmpty.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 边框
    final borderPaint = Paint()
      ..color = filled ? AppColors.manaFull : const Color(0xFF3A4070)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);

    // 高光
    if (filled) {
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(cx - r * 0.3, cy - r * 0.3), r * 0.25, highlightPaint);
    }
  }
}
