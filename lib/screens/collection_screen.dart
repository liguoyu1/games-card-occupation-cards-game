import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../data/card_data.dart';
import '../data/all_cards.dart';
import '../data/keyword.dart';
import '../game/constants.dart';

/// ============================================================
/// 牌库图鉴界面
/// 展示所有卡牌 + 筛选/详情
/// ============================================================
class CollectionGame extends FlameGame with TapCallbacks {
  @override
  Color backgroundColor() => AppColors.primaryBg;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _buildUI();
  }

  void _buildUI() {
    add(_Title(position: Vector2(size.x / 2, 40), text: '牌库图鉴'));

    // 显示全部16张卡牌
    final cards = AllCards.cards;
    const cols = 4;
    const rows = 4;

    final startX = (size.x - cols * (CardSizes.detailCardW * 0.35 + 8)) / 2;
    final startY = 80.0;
    final cardW = CardSizes.detailCardW * 0.35;
    final cardH = CardSizes.detailCardH * 0.35;

    for (var i = 0; i < cards.length; i++) {
      final row = i ~/ cols;
      final col = i % cols;
      final card = cards[i];

      add(_CollectionCard(
        card: card,
        position: Vector2(startX + col * (cardW + 8), startY + row * (cardH + 20)),
        size: Vector2(cardW, cardH),
      ));
    }

    // 返回按钮占位
    add(_BackButtonHint(position: Vector2(60, size.y - 30)));
  }
}

class _CollectionCard extends PositionComponent {
  final CardData card;

  _CollectionCard({
    required this.card,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    const r = 6.0;

    // 底板
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(r)),
      Paint()..shader = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [card.rarityColor.withValues(alpha: 0.8), card.rarityColor.withValues(alpha: 0.5)],
      ).createShader(Rect.fromLTWH(0, 0, w, h)));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, w - 4, h - 4), const Radius.circular(r - 1)),
      Paint()..color = AppColors.secondaryBg.withValues(alpha: 0.9));

    // 费用
    canvas.drawCircle(const Offset(12, 12), 10,
      Paint()..color = AppColors.manaFull..style = PaintingStyle.fill);
    final fee = TextPainter(text: TextSpan(text: '${card.cost}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)
      ..layout();
    fee.paint(canvas, Offset(12 - fee.width / 2, 12 - fee.height / 2));

    // 名称
    final name = card.name.length > 6 ? '${card.name.substring(0, 5)}…' : card.name;
    final nm = TextPainter(text: TextSpan(text: name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 9, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)
      ..layout(maxWidth: w - 28);
    nm.paint(canvas, Offset(26, (28 - nm.height) / 2));

    // 攻/血
    final atk = TextPainter(text: TextSpan(text: '${card.attack}/', style: const TextStyle(color: AppColors.attackColor, fontSize: 9, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)
      ..layout();
    final hp = TextPainter(text: TextSpan(text: '${card.health}', style: const TextStyle(color: AppColors.healthColor, fontSize: 9, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)
      ..layout();
    atk.paint(canvas, Offset(8, h - 16));
    hp.paint(canvas, Offset(8 + atk.width, h - 16));

    // 稀有度标记
    final rarity = TextPainter(
      text: TextSpan(text: card.rarity.nameCn, style: TextStyle(color: card.rarityBorderColor, fontSize: 7)),
      textDirection: TextDirection.ltr)
      ..layout();
    rarity.paint(canvas, Offset(w - rarity.width - 4, h - 14));

    // 边框
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, w - 2, h - 2), const Radius.circular(r)),
      Paint()..color = card.rarityBorderColor..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // 传说呼吸光效
    if (card.rarity == Rarity.legendary) {
      final pulse = (math.sin(DateTime.now().millisecondsSinceEpoch / 1000.0 * 2) * 0.15 + 0.2);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(r)),
        Paint()..color = AppColors.accent.withValues(alpha: pulse)..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }
}

class _Title extends PositionComponent {
  final String text;
  _Title({required Vector2 position, required this.text}) : super(position: position);

  @override
  void render(Canvas canvas) {
    final t = TextPainter(text: TextSpan(text: text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)
      ..layout();
    t.paint(canvas, Offset(-t.width / 2, -t.height / 2));
  }
}

class _BackButtonHint extends PositionComponent {
  _BackButtonHint({required Vector2 position}) : super(position: position);

  @override
  void render(Canvas canvas) {
    final t = TextPainter(text: const TextSpan(text: '← 返回', style: TextStyle(color: AppColors.accent, fontSize: 14)), textDirection: TextDirection.ltr)
      ..layout();
    t.paint(canvas, Offset(-t.width / 2, -t.height / 2));
  }
}
