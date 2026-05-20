import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../data/card_data.dart';
import '../../data/keyword.dart';
import '../constants.dart';

/// ============================================================
/// 精美卡牌渲染组件
/// Phase 1: 实现稀有度配色/双线描边/金属质感/悬浮动画
/// ============================================================
class CardComponent extends PositionComponent with HoverCallbacks {
  final CardData cardData;

  /// 悬浮状态
  bool _isHovered = false;
  double _hoverProgress = 0.0; // 0=正常, 1=悬浮

  /// 是否显示正面
  bool showFront;

  double? _initialY;

  /// 构造函数
  CardComponent({
    required this.cardData,
    required super.position,
    this.showFront = true,
    super.anchor = Anchor.topLeft,
  }) : super(
          size: Vector2(CardSizes.handCardW, CardSizes.handCardH),
        );

  @override
  void update(double dt) {
    super.update(dt);
    // 悬浮动画插值
    final targetProgress = _isHovered ? 1.0 : 0.0;
    _hoverProgress += (targetProgress - _hoverProgress) * dt * 8.0;
    _hoverProgress = _hoverProgress.clamp(0.0, 1.0);

    // 悬浮时上浮 + 放大
    final hoverScale = 1.0 + _hoverProgress * (CardSizes.hoverScale - 1.0);
    final hoverOffset = -_hoverProgress * 10.0;
    scale = Vector2.all(hoverScale);
    position.y = (_initialY ?? position.y) + hoverOffset;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _initialY ??= position.y;
  }

  /// 设置悬浮状态
  void setHovered(bool hovered) {
    _isHovered = hovered;
  }

  @override
  void onHoverEnter() {
    _isHovered = true;
  }

  @override
  void onHoverExit() {
    _isHovered = false;
  }

  @override
  void render(Canvas canvas) {
    if (!showFront) {
      _renderCardBack(canvas);
      return;
    }
    _renderCardFront(canvas);
  }

  /// 渲染卡牌正面 — 分层绘制
  void _renderCardFront(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final r = 10.0; // 圆角

    // ===== ① 底板 + 稀有度 =====
    _drawCardBase(canvas, w, h, r);

    // ===== ② 法力水晶（左上角）=====
    _drawManaCrystal(canvas, w, h);

    // ===== ③ 卡牌插画区 =====
    _drawIllustration(canvas, w, h);

    // ===== ④ 名称栏 =====
    _drawNameBar(canvas, w, h);

    // ===== ⑤ 关键词标签行 =====
    _drawKeywordTags(canvas, w, h);

    // ===== ⑥ 描述文本 =====
    _drawDescription(canvas, w, h);

    // ===== ⑦ 攻击力（左下） / 生命值（右下）=====
    _drawStats(canvas, w, h);

    // ===== ⑧ 边框光泽 =====
    _drawGloss(canvas, w, h, r);

    // ===== ⑨ 金属铆钉装饰 =====
    _drawRivets(canvas, w, h);
  }

  /// 底板绘制
  void _drawCardBase(Canvas canvas, double w, double h, double r) {
    // 外阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 4, w, h),
        Radius.circular(r),
      ),
      shadowPaint,
    );

    // 主底板（稀有度颜色）
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(r),
    );

    // 稀有度渐变底板
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cardData.rarityColor.withValues(alpha: 0.9),
          cardData.rarityColor.withValues(alpha: 0.6),
          cardData.rarityColor.withValues(alpha: 0.8),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(baseRect, basePaint);

    // 内层底色（深色）
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, w - 6, h - 6),
      Radius.circular(r - 2),
    );
    final innerPaint = Paint()..color = AppColors.secondaryBg;
    canvas.drawRRect(innerRect, innerPaint);
  }

  /// 法力水晶
  void _drawManaCrystal(Canvas canvas, double w, double h) {
    final cx = 16.0;
    final cy = 16.0;
    final radius = 14.0;

    // 外发光
    final glowPaint = Paint()
      ..color = AppColors.manaFull.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(cx, cy), radius + 4, glowPaint);

    // 水晶主体
    final gradient = RadialGradient(
      colors: [
        Colors.white.withValues(alpha: 0.9),
        AppColors.manaFull,
        AppColors.manaFull.withValues(alpha: 0.7),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(cx - radius, cy - radius, radius * 2, radius * 2));
    final manaPaint = Paint()..shader = gradient;
    canvas.drawCircle(Offset(cx, cy), radius, manaPaint);

    // 内圈高光
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(cx - 4, cy - 4), 5, highlightPaint);

    // 费用数字
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${cardData.cost}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'JetBrainsMono',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );
  }

  /// 插画区
  void _drawIllustration(Canvas canvas, double w, double h) {
    // 插画区域
    final illustRect = Rect.fromLTWH(6, 28, w - 12, 65);

    // 背景渐变
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          cardData.professionColor.withValues(alpha: 0.3),
          AppColors.secondaryBg.withValues(alpha: 0.5),
        ],
      ).createShader(illustRect);
    canvas.drawRect(illustRect, bgPaint);

    // 职业图标占位（圆圈内一个大写字母或图标）
    final iconCenterX = illustRect.center.dx;
    final iconCenterY = illustRect.center.dy;

    // 图标底圆
    final iconPaint = Paint()
      ..color = cardData.professionColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(iconCenterX, iconCenterY), 28, iconPaint);

    // 图标边框
    final iconBorderPaint = Paint()
      ..color = cardData.professionColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(iconCenterX, iconCenterY), 28, iconBorderPaint);

    // 职业图标文字
    final iconText = _getProfessionIcon(cardData.profession);
    final iconPainter = TextPainter(
      text: TextSpan(
        text: iconText,
        style: TextStyle(
          color: cardData.professionColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(iconCenterX - iconPainter.width / 2, iconCenterY - iconPainter.height / 2),
    );

    // 传说级特殊光效
    if (cardData.rarity == Rarity.legendary) {
      _drawLegendaryGlow(canvas, w, h);
    }
  }

  /// 传说级呼吸光效
  void _drawLegendaryGlow(Canvas canvas, double w, double h) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final pulse = (math.sin(time * 2) + 1) / 2; // 0~1

    final glowPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: pulse * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, w - 4, h - 4),
        const Radius.circular(10),
      ),
      glowPaint,
    );
  }

  /// 名称栏
  void _drawNameBar(Canvas canvas, double w, double h) {
    final y = 96.0;
    final barH = 18.0;

    // 名称背景渐变
    final nameBarPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          cardData.professionColor.withValues(alpha: 0.6),
          cardData.professionColor.withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromLTWH(0, y, w, barH));
    canvas.drawRect(Rect.fromLTWH(4, y, w - 8, barH), nameBarPaint);

    // 名称文字
    final namePainter = TextPainter(
      text: TextSpan(
        text: cardData.name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'NotoSerifSC',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout(maxWidth: w - 16);
    namePainter.paint(canvas, Offset(8, y + 2));
  }

  /// 关键词标签行
  void _drawKeywordTags(Canvas canvas, double w, double h) {
    if (cardData.keywords.isEmpty) return;

    final y = 116.0;
    var xOffset = 6.0;

    for (final keyword in cardData.keywords) {
      final tagText = keyword.nameCn;
      final tagPainter = TextPainter(
        text: TextSpan(
          text: tagText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tagPainter.layout();

      final tagW = tagPainter.width + 8;
      final tagH = 14.0;

      // 标签背景
      final color = _keywordToColor(keyword);
      final tagPaint = Paint()..color = color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(xOffset, y, tagW, tagH),
          const Radius.circular(4),
        ),
        tagPaint,
      );

      tagPainter.paint(canvas, Offset(xOffset + 4, y + 2));

      xOffset += tagW + 4;
      if (xOffset > w - 20) break; // 超出则截断
    }
  }

  Color _keywordToColor(Keyword k) {
    switch (k) {
      case Keyword.charge:     return const Color(0xFFFFB800);
      case Keyword.taunt:     return const Color(0xFFFF5722);
      case Keyword.divineShield: return const Color(0xFFFFD600);
      case Keyword.battlecry:  return const Color(0xFF00E676);
      case Keyword.deathrattle: return const Color(0xFF9C27B0);
      case Keyword.windfury:   return const Color(0xFF2196F3);
      case Keyword.freeze:    return const Color(0xFF00B4D8);
      case Keyword.stealth:   return const Color(0xFF607D8B);
    }
  }

  /// 描述文本
  void _drawDescription(Canvas canvas, double w, double h) {
    final descRect = Rect.fromLTWH(6, 132, w - 12, 26);

    // 描述文字
    final descPainter = TextPainter(
      text: TextSpan(
        text: cardData.description,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 8,
          height: 1.3,
          fontFamily: 'NotoSansSC',
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 3,
    );
    descPainter.layout(maxWidth: descRect.width);
    descPainter.paint(canvas, Offset(descRect.left, descRect.top));
  }

  /// 攻击力 / 生命值
  void _drawStats(Canvas canvas, double w, double h) {
    // 左下：攻击力（红色）
    _drawStatCircle(canvas, 0, h - 4, cardData.attack, AppColors.attackColor, '⚔');

    // 右下：生命值（绿色/红色）
    final healthColor = cardData.health <= 2
        ? AppColors.danger
        : AppColors.healthColor;
    _drawStatCircle(canvas, w, h - 4, cardData.health, healthColor, '♥');
  }

  void _drawStatCircle(Canvas canvas, double x, double y, int value, Color color, String icon) {
    final cx = x == 0 ? 14.0 : x - 14.0;
    final cy = y;
    final r = 12.0;

    // 背景圆
    final bgPaint = Paint()..color = AppColors.primaryBg.withValues(alpha: 0.8);
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    // 边框
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cy), r, borderPaint);

    // 数值
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$value',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'JetBrainsMono',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );
  }

  /// 边框光泽
  void _drawGloss(Canvas canvas, double w, double h, double r) {
    // 外层深线
    final outerPaint = Paint()
      ..color = cardData.rarityBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, w - 2, h - 2),
        Radius.circular(r),
      ),
      outerPaint,
    );

    // 内层亮线
    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 3, w - 6, h - 6),
        Radius.circular(r - 1),
      ),
      innerPaint,
    );
  }

  /// 金属铆钉
  void _drawRivets(Canvas canvas, double w, double h) {
    final rivetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final rivetShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // 四个角
    final rivets = [
      Offset(6, 6),
      Offset(w - 6, 6),
      Offset(6, h - 6),
      Offset(w - 6, h - 6),
    ];

    for (final pos in rivets) {
      // 阴影
      canvas.drawCircle(pos + const Offset(1, 1), 2, rivetShadow);
      // 高光
      canvas.drawCircle(pos, 2, rivetPaint);
    }
  }

  /// 卡牌背面
  void _renderCardBack(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final r = 10.0;

    // 底板
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1A237E),
          const Color(0xFF0A0E27),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(r)),
      basePaint,
    );

    // 边框
    final borderPaint = Paint()
      ..color = const Color(0xFF3A4070)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, w - 4, h - 4), Radius.circular(r - 2)),
      borderPaint,
    );

    // 中心 Logo 圆
    final logoPaint = Paint()
      ..color = const Color(0xFF3A4070)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), 25, logoPaint);

    // 内部装饰线
    final innerPaint = Paint()
      ..color = const Color(0xFFFFB800).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 8, w - 16, h - 16),
        Radius.circular(r - 4),
      ),
      innerPaint,
    );

    // 斜线纹理
    for (var i = -h.toInt(); i < w.toInt() + h.toInt(); i += 8) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble() + h, h),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..strokeWidth = 1,
      );
    }
  }

  /// 获取职业图标文字
  String _getProfessionIcon(dynamic profession) {
    // 使用 profession 的 hashCode 生成对应图标
    final icons = ['📦', '💰', '🔧', '➕', '🔨', '📚', '💻', '👮', '🍳', '🚒', '🎨', '💼', '🏥', '🎖', '⭐', '🎓'];
    final idx = profession.hashCode.abs() % icons.length;
    return icons[idx];
  }
}
