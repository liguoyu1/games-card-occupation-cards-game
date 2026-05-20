import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../game/constants.dart';
import '../../models/minion_instance.dart';
import '../../data/keyword.dart' as kw;

/// ============================================================
/// 随从卡组件（战场版本）
/// ============================================================
class MinionCardComponent extends PositionComponent {
  final MinionInstance instance;
  final bool isEnemy;
  bool isSelected;

  MinionCardComponent({
    required this.instance,
    required this.isEnemy,
    required Vector2 position,
    this.isSelected = false,
  }) : super(position: position, size: Vector2(CardSizes.minionCardW, CardSizes.minionCardH));

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final r = 8.0;

    // ===== 底板 =====
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(r),
    );

    // 稀有度底色
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          instance.cardData.rarityColor.withValues(alpha: 0.8),
          instance.cardData.rarityColor.withValues(alpha: 0.5),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(baseRect, basePaint);

    // 深色内层
    final innerPaint = Paint()..color = AppColors.secondaryBg.withValues(alpha: 0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, w - 4, h - 4), Radius.circular(r - 1)),
      innerPaint,
    );

    // ===== 圣盾效果 =====
    if (instance.hasDivineShield) {
      final shieldPaint = Paint()
        ..color = AppColors.divineShield.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, w - 2, h - 2), Radius.circular(r)),
        shieldPaint,
      );
      // 圣盾图标
      _drawShieldIcon(canvas, w / 2, h / 2 - 5, 12);
    }

    // ===== 冻结效果 =====
    if (instance.isFrozen) {
      _drawFrozenOverlay(canvas, w, h, r);
    }

    // ===== 嘲讽标记 =====
    if (instance.keywords.contains(kw.Keyword.taunt)) {
      _drawTauntIcon(canvas, w / 2, 12);
    }

    // ===== 职业图标 =====
    final iconText = _getIcon();
    final iconPainter = TextPainter(
      text: TextSpan(
        text: iconText,
        style: const TextStyle(fontSize: 24),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(w / 2 - iconPainter.width / 2, h / 2 - iconPainter.height / 2 - 8),
    );

    // ===== 名称（截断）====
    final namePainter = TextPainter(
      text: TextSpan(
        text: _truncateName(instance.cardData.name, 6),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout(maxWidth: w - 4);
    namePainter.paint(canvas, Offset(2, 4));

    // ===== 攻击力（左下）====
    _drawStat(canvas, 0, h - 14, instance.currentAttack, AppColors.attackColor, false);

    // ===== 生命值（右下）====
    final hpColor = instance.currentHealth <= instance.maxHealth * 0.3
        ? AppColors.danger
        : AppColors.healthColor;
    _drawStat(canvas, w, h - 14, instance.currentHealth, hpColor, true);

    // ===== 选中高亮 =====
    if (isSelected) {
      final selectPaint = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(r)),
        selectPaint,
      );
    }

    // ===== 边框 =====
    final borderPaint = Paint()
      ..color = instance.cardData.rarityBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, w - 2, h - 2), Radius.circular(r)),
      borderPaint,
    );
  }

  void _drawStat(Canvas canvas, double x, double y, int value, Color color, bool isRight) {
    final cx = isRight ? x - 10 : 10.0;
    final r = 10.0;

    // 背景
    canvas.drawCircle(Offset(cx, y), r, Paint()..color = AppColors.primaryBg.withValues(alpha: 0.8));

    // 边框
    canvas.drawCircle(
      Offset(cx, y),
      r,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 数值
    final painter = TextPainter(
      text: TextSpan(
        text: '$value',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(canvas, Offset(cx - painter.width / 2, y - painter.height / 2));
  }

  void _drawShieldIcon(Canvas canvas, double cx, double cy, double r) {
    final paint = Paint()
      ..color = AppColors.divineShield.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // 十字
    canvas.drawLine(
      Offset(cx - r * 0.5, cy),
      Offset(cx + r * 0.5, cy),
      Paint()
        ..color = AppColors.divineShield
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(cx, cy - r * 0.5),
      Offset(cx, cy + r * 0.5),
      Paint()
        ..color = AppColors.divineShield
        ..strokeWidth = 1.5,
    );
  }

  void _drawTauntIcon(Canvas canvas, double cx, double cy) {
    final paint = Paint()
      ..color = AppColors.freeze.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    // 三角形（警告标志简化）
    final path = Path()
      ..moveTo(cx, cy - 8)
      ..lineTo(cx + 7, cy + 6)
      ..lineTo(cx - 7, cy + 6)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawFrozenOverlay(Canvas canvas, double w, double h, double r) {
    final overlayPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.freeze.withValues(alpha: 0.4),
          AppColors.freeze.withValues(alpha: 0.2),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(r)), overlayPaint);

    // 冰晶装饰
    final icePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(w * 0.3, h * (0.2 + i * 0.3)),
        Offset(w * 0.7, h * (0.3 + i * 0.3)),
        icePaint,
      );
    }
  }

  String _getIcon() {
    final icons = ['📦', '💰', '🔧', '➕', '🔨', '📚', '💻', '👮', '🍳', '🚒', '🎨', '💼', '🏥', '🎖', '⭐', '🎓'];
    final idx = instance.cardData.profession.hashCode.abs() % icons.length;
    return icons[idx];
  }

  String _truncateName(String name, int maxLen) {
    if (name.length <= maxLen) return name;
    return '${name.substring(0, maxLen - 1)}…';
  }
}
