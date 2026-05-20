import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../data/card_registry.dart';
import '../data/all_cards.dart';
import 'components/card_component.dart';
import 'constants.dart';

/// ============================================================
/// 职业卡牌 - FlameGame 主类
/// Phase 1: 展示不同稀有度的精美卡牌
/// ============================================================
class OccupationCardsGame extends FlameGame {
  @override
  Color backgroundColor() => AppColors.primaryBg;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 初始化卡牌注册表
    cardRegistry.init();

    // Phase 1: 展示不同稀有度的卡牌
    _buildCardDemo();
  }

  /// 构建卡牌展示 Demo
  void _buildCardDemo() {
    // 选择 4 张不同稀有度的代表性卡牌
    final demoCards = [
      AllCards.cards[2],  // cashier - common
      AllCards.cards[5],  // nurse - rare
      AllCards.cards[6],  // teacher - epic
      AllCards.cards[12], // soldier - legendary
    ];

    // 横向排列，从左到右
    final totalWidth = demoCards.length * CardSizes.handCardW + (demoCards.length - 1) * 20;
    final startX = (size.x - totalWidth) / 2;
    final cardY = size.y / 2 - CardSizes.handCardH / 2;

    for (var i = 0; i < demoCards.length; i++) {
      final card = CardComponent(
        cardData: demoCards[i],
        position: Vector2(startX + i * (CardSizes.handCardW + 20), cardY),
      );
      add(card);
    }

    // 底部说明文字
    add(_TitleText(
      position: Vector2(size.x / 2, 80),
      text: '职业卡牌 — Phase 1 卡牌渲染展示',
    ));

    // 稀有度说明
    final labels = ['普通', '稀有', '史诗', '传说'];
    for (var i = 0; i < 4; i++) {
      add(_SubtitleText(
        position: Vector2(
          startX + i * (CardSizes.handCardW + 20) + CardSizes.handCardW / 2,
          cardY + CardSizes.handCardH + 20,
        ),
        text: labels[i],
      ));
    }
  }
}

/// 标题文字
class _TitleText extends PositionComponent {
  final String text;
  _TitleText({required Vector2 position, required this.text}) : super(position: position);

  @override
  void render(Canvas canvas) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'NotoSansSC',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(-painter.width / 2, -painter.height / 2),
    );
  }
}

/// 副标题文字
class _SubtitleText extends PositionComponent {
  final String text;
  _SubtitleText({required Vector2 position, required this.text}) : super(position: position);

  @override
  void render(Canvas canvas) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontFamily: 'NotoSansSC',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(-painter.width / 2, -painter.height / 2),
    );
  }
}
