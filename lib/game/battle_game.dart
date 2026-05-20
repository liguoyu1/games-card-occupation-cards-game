import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import '../data/card_registry.dart';
import '../data/all_cards.dart';
import '../data/card_data.dart';
import '../models/player_state.dart';
import '../models/minion_instance.dart';
import '../data/keyword.dart' as kw;
import 'systems/battle_system.dart';
import 'systems/ai_system.dart';
import 'audio/audio_manager.dart';
import 'constants.dart';

class BattleGame extends FlameGame with TapCallbacks {
  late PlayerState player;
  late PlayerState enemy;
  late BattleSystem battleSystem;
  late TurnManager turnManager;
  final _audio = AudioManager();
  bool isPlayerTurn = true;

  _ManaCrystal? manaCrystal;
  _HeroStatus? playerHeroStatus;
  _HeroStatus? enemyHeroStatus;
  _EndTurnButton? endTurnBtn;
  List<_HandCard> handCards = [];
  List<_MinionSlot> minionSlots = [];

  @override
  Color backgroundColor() => AppColors.primaryBg;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    cardRegistry.init();

    player = PlayerState(isEnemy: false, name: '玩家');
    player.initDeck(List.from(AllCards.cards));
    player.drawInitialCards(4);

    enemy = PlayerState(isEnemy: true, name: '对手');
    enemy.initDeck(List.from(AllCards.cards));
    enemy.drawInitialCards(4);

    battleSystem = BattleSystem(player: player, enemy: enemy);
    turnManager = TurnManager(player: player, enemy: enemy);
    turnManager.startPlayerTurn();
    _buildAll();
    _audio.play('draw');
  }

  void _buildAll() {
    add(_ParticleBackground());
    add(_BattleDivider());

    enemyHeroStatus = _HeroStatus(
      position: Vector2(size.x / 2, 40),
      playerName: '对手', health: enemy.health, isEnemy: true,
    );
    add(enemyHeroStatus!);

    playerHeroStatus = _HeroStatus(
      position: Vector2(size.x / 2, size.y - 50),
      playerName: '玩家', health: player.health, isEnemy: false,
    );
    add(playerHeroStatus!);

    _refreshEnemyHand();
    _refreshMinions();
    _refreshPlayerHand();

    manaCrystal = _ManaCrystal(
      position: Vector2(20, size.y - 80),
      maxCrystals: player.maxMana,
      currentMana: player.currentMana,
    );
    add(manaCrystal!);

    add(_TurnHint(position: Vector2(size.x / 2, 200)));

    endTurnBtn = _EndTurnButton(
      position: Vector2(size.x - 80, size.y - 50),
      onTap: _onEndTurn,
    );
    add(endTurnBtn!);
  }

  // ---- Refresh ----

  void _refreshEnemyHand() {
    children.whereType<_CardBack>().toList().forEach(remove);
    final count = enemy.hand.length;
    if (count == 0) return;
    final totalW = count * 25.0;
    final startX = (size.x - totalW) / 2;
    for (var i = 0; i < count; i++) {
      add(_CardBack(position: Vector2(startX + i * 25, 90)));
    }
  }

  void _refreshPlayerHand() {
    handCards.forEach(remove);
    handCards.clear();
    final count = player.hand.length;
    if (count == 0) return;
    final spacing = CardSizes.handCardW + 10;
    final totalW = count * spacing - 10;
    final startX = (size.x - totalW) / 2;
    final y = size.y - CardSizes.handCardH - 30;
    for (var i = 0; i < count; i++) {
      final card = player.hand[i];
      final comp = _HandCard(
        card: card,
        position: Vector2(startX + i * spacing, y),
        isPlayable: player.currentMana >= card.cost,
      );
      comp.onCardTap = () => _onPlayCard(card);
      handCards.add(comp);
      add(comp);
    }
  }

  void _refreshMinions() {
    minionSlots.forEach(remove);
    minionSlots.clear();
    _renderMinions(player.minions, false);
    _renderMinions(enemy.minions, true);
  }

  void _renderMinions(List<MinionInstance> minions, bool isEnemy) {
    if (minions.isEmpty) return;
    final slotW = GameDimensions.minionSlotWidth + 10;
    final totalW = minions.length * slotW;
    final startX = (size.x - totalW) / 2;
    final y = isEnemy ? GameDimensions.enemyMinionAreaY + 10 : GameDimensions.myMinionAreaY + 20;
    for (var i = 0; i < minions.length; i++) {
      final comp = _MinionSlot(
        instance: minions[i],
        position: Vector2(startX + i * slotW, y),
      );
      minionSlots.add(comp);
      add(comp);
    }
  }

  void _refreshMana() {
    if (manaCrystal != null) {
      manaCrystal!.maxCrystals = player.maxMana;
      manaCrystal!.currentMana = player.currentMana;
    }
  }

  void _refreshHeroes() {
    if (playerHeroStatus != null) playerHeroStatus!.health = player.health;
    if (enemyHeroStatus != null) enemyHeroStatus!.health = enemy.health;
  }

  // ---- Interaction ----

  void _onPlayCard(CardData card) {
    if (!isPlayerTurn) return;
    if (player.currentMana < card.cost) {
      _showToast('法力不足');
      _audio.play('error');
      return;
    }
    if (player.minions.length >= 7) {
      _showToast('随从已满');
      _audio.play('error');
      return;
    }
    final result = battleSystem.playCard(card);
    if (result != null) {
      _audio.play('card_play');
      _showToast(result.message);
      _refreshPlayerHand();
      _refreshMinions();
      _refreshMana();
      _refreshHeroes();
      _checkGameOver();
    }
  }

  void _onEndTurn() {
    if (!isPlayerTurn) return;
    isPlayerTurn = false;
    _showToast('对手回合...');
    battleSystem.endPlayerTurn();

    Future.delayed(const Duration(milliseconds: 600), () {
      // 敌方AI执行完毕后刷新
      _refreshMinions();
      _refreshEnemyHand();
      _refreshHeroes();
      _checkGameOver();

      if (!battleSystem.isGameOver) {
        isPlayerTurn = true;
        _refreshPlayerHand();
        _refreshMana();
        _showToast('你的回合');
      }
    });
  }

  void _showToast(String msg) {
    final comp = _ToastText(text: msg);
    add(comp);
  }

  void _checkGameOver() {
    if (battleSystem.isGameOver) {
      add(_GameOverOverlay(position: Vector2(size.x / 2, size.y / 2), winner: battleSystem.winner));
    }
  }
}

// ===== 组件 =====

class _ParticleBackground extends PositionComponent {
  @override
  void render(Canvas canvas) {
    final offsets = [100.0, 300.0, 500.0, 700.0, 200.0, 600.0, 900.0, 1100.0];
    final heights = [100.0, 200.0, 150.0, 250.0, 400.0, 450.0, 300.0, 180.0];
    for (var i = 0; i < offsets.length; i++) {
      canvas.drawCircle(
        Offset(offsets[i], heights[i]), 2,
        Paint()..color = AppColors.accent.withValues(alpha: 0.12)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }
}

class _BattleDivider extends PositionComponent {
  @override
  void render(Canvas canvas) {
    const dy = GameDimensions.dividerY;
    final gradient = const LinearGradient(
      colors: [Colors.transparent, Color(0x4DFFB800), Color(0x80FFB800), Color(0x4DFFB800), Colors.transparent],
      stops: [0.0, 0.2, 0.5, 0.8, 1.0],
    );
    final paint = Paint()..shader = gradient.createShader(const Rect.fromLTWH(0, 360, 1280, 2));
    canvas.drawRect(const Rect.fromLTWH(0, 360, 1280, 2), paint);
    canvas.drawCircle(const Offset(640, 360), 4,
      Paint()..color = AppColors.accent.withValues(alpha: 0.6)..style = PaintingStyle.fill);
  }
}

class _HeroStatus extends PositionComponent {
  int health;
  final String playerName;
  final bool isEnemy;

  _HeroStatus({
    required Vector2 position,
    required this.playerName,
    required this.health,
    required this.isEnemy,
  }) : super(position: position, size: Vector2(120, 60));

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2, h = size.y / 2;
    canvas.drawCircle(Offset(cx, h), 25, Paint()..color = AppColors.secondaryBg);
    canvas.drawCircle(Offset(cx, h), 25,
      Paint()..color = AppColors.accent..style = PaintingStyle.stroke..strokeWidth = 2);

    final icon = TextPainter(text: TextSpan(text: isEnemy ? '😈' : '😊', style: const TextStyle(fontSize: 24)), textDirection: TextDirection.ltr);
    icon.layout();
    icon.paint(canvas, Offset(cx - icon.width / 2, h - icon.height / 2));

    final hpColor = health <= 10 ? AppColors.danger : AppColors.healthColor;
    final hp = TextPainter(text: TextSpan(text: '$health', style: TextStyle(color: hpColor, fontSize: 16, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr);
    hp.layout();
    hp.paint(canvas, Offset(cx + 30, h - hp.height / 2));

    final name = TextPainter(text: TextSpan(text: playerName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)), textDirection: TextDirection.ltr);
    name.layout();
    name.paint(canvas, Offset(cx - name.width / 2, size.y - 12));
  }
}

class _CardBack extends PositionComponent {
  _CardBack({required Vector2 position})
      : super(position: position, size: Vector2(CardSizes.handCardW * 0.25, CardSizes.handCardH * 0.25));

  @override
  void render(Canvas canvas) {
    final w = size.x, h = size.y;
    final basePaint = Paint()..shader = const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF1A237E), Color(0xFF0A0E27)]).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(6)), basePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, w - 2, h - 2), const Radius.circular(5)),
      Paint()..color = const Color(0xFF3A4070)..style = PaintingStyle.stroke..strokeWidth = 1);
  }
}

class _HandCard extends PositionComponent with TapCallbacks {
  final CardData card;
  final bool isPlayable;
  VoidCallback? onCardTap;

  _HandCard({required this.card, required Vector2 position, this.isPlayable = true})
      : super(position: position, size: Vector2(CardSizes.handCardW, CardSizes.handCardH));

  @override
  void render(Canvas canvas) {
    final w = size.x, h = size.y;
    final r = 10.0;

    // 不可用状态半透明
    if (!isPlayable) {
      canvas.save();
    }

    // 底板
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(2, 4, w, h), Radius.circular(r)),
      Paint()..color = Colors.black.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    final basePaint = Paint()..shader = LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [card.rarityColor.withValues(alpha: 0.9), card.rarityColor.withValues(alpha: 0.6)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(r)), basePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(3, 3, w - 6, h - 6), Radius.circular(r - 2)),
      Paint()..color = AppColors.secondaryBg);

    // 法力水晶
    canvas.drawCircle(const Offset(16, 16), 14,
      Paint()..color = AppColors.manaFull.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    final manaPaint = Paint()..shader = const RadialGradient(
      colors: [Colors.white, Color(0xFF4488FF), Color(0x604488FF)],
      stops: [0.0, 0.5, 1.0]).createShader(const Rect.fromLTWH(2, 2, 28, 28));
    canvas.drawCircle(const Offset(16, 16), 14, manaPaint);
    final manaTxt = TextPainter(
      text: TextSpan(text: '${card.cost}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr);
    manaTxt.layout();
    manaTxt.paint(canvas, Offset(16 - manaTxt.width / 2, 16 - manaTxt.height / 2));

    // 名称
    final namePainter = TextPainter(
      text: TextSpan(text: card.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr);
    namePainter.layout(maxWidth: w - 16);
    namePainter.paint(canvas, const Offset(8, 96));

    // 关键词
    const tagY = 116.0;
    var xOff = 6.0;
    for (final k in card.keywords) {
      final tag = TextPainter(text: TextSpan(text: k.nameCn, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr);
      tag.layout();
      final tw = tag.width + 8;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(xOff, tagY, tw, 14), const Radius.circular(4)),
        Paint()..color = _kwColor(k));
      tag.paint(canvas, Offset(xOff + 4, tagY + 2));
      xOff += tw + 4;
    }

    // 攻/血
    _drawStat(canvas, 14, h - 4, card.attack, AppColors.attackColor);
    _drawStat(canvas, w - 14, h - 4, card.health, AppColors.healthColor);

    // 边框
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, w - 2, h - 2), Radius.circular(r)),
      Paint()..color = card.rarityBorderColor..style = PaintingStyle.stroke..strokeWidth = 1.5);

    if (!isPlayable) {
      // 不可用状态：半透明覆盖
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(r)),
        Paint()..color = Colors.black.withValues(alpha: 0.4));
      canvas.restore();
    }
  }

  void _drawStat(Canvas canvas, double cx, double cy, int value, Color color) {
    canvas.drawCircle(Offset(cx, cy), 12, Paint()..color = AppColors.primaryBg.withValues(alpha: 0.8));
    canvas.drawCircle(Offset(cx, cy), 12,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);
    final t = TextPainter(text: TextSpan(text: '$value', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr);
    t.layout();
    t.paint(canvas, Offset(cx - t.width / 2, cy - t.height / 2));
  }

  Color _kwColor(kw.Keyword k) {
    switch (k) {
      case kw.Keyword.charge: return const Color(0xFFFFB800);
      case kw.Keyword.taunt: return const Color(0xFFFF5722);
      case kw.Keyword.divineShield: return const Color(0xFFFFD600);
      case kw.Keyword.battlecry: return const Color(0xFF00E676);
      case kw.Keyword.deathrattle: return const Color(0xFF9C27B0);
      case kw.Keyword.windfury: return const Color(0xFF2196F3);
      case kw.Keyword.freeze: return const Color(0xFF00B4D8);
      case kw.Keyword.stealth: return const Color(0xFF607D8B);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isPlayable) onCardTap?.call();
  }
}

class _MinionSlot extends PositionComponent {
  final MinionInstance instance;

  _MinionSlot({required this.instance, required Vector2 position})
      : super(position: position, size: Vector2(CardSizes.minionCardW, CardSizes.minionCardH));

  @override
  void render(Canvas canvas) {
    final w = size.x, h = size.y;
    const r = 8.0;

    // 底板
    final basePaint = Paint()..shader = LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [instance.cardData.rarityColor.withValues(alpha: 0.8), instance.cardData.rarityColor.withValues(alpha: 0.5)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(r)), basePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, w - 4, h - 4), Radius.circular(r - 1)),
      Paint()..color = AppColors.secondaryBg.withValues(alpha: 0.9));

    // 圣盾
    if (instance.hasDivineShield) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, w - 2, h - 2), Radius.circular(r)),
        Paint()..color = AppColors.divineShield.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 3);
    }
    // 冻结
    if (instance.isFrozen) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(r)),
        Paint()..shader = LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.freeze.withValues(alpha: 0.4), AppColors.freeze.withValues(alpha: 0.2)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)));
    }
    // 嘲讽
    if (instance.keywords.contains(kw.Keyword.taunt)) {
      canvas.drawPath(
        Path()..moveTo(w / 2, 8)..lineTo(w / 2 + 7, 22)..lineTo(w / 2 - 7, 22)..close(),
        Paint()..color = AppColors.freeze.withValues(alpha: 0.6));
    }

    // 名称
    final name = instance.cardData.name.length > 6
        ? '${instance.cardData.name.substring(0, 5)}…' : instance.cardData.name;
    final namePainter = TextPainter(
      text: TextSpan(text: name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 8, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr);
    namePainter.layout(maxWidth: w - 4);
    namePainter.paint(canvas, const Offset(2, 4));

    // 职业图标
    const icons = ['📦', '💰', '🔧', '➕', '🔨', '📚', '💻', '👮', '🍳', '🚒', '🎨', '💼', '🏥', '🎖', '⭐', '🎓'];
    final ic = icons[instance.cardData.profession.hashCode.abs() % icons.length];
    final icP = TextPainter(text: TextSpan(text: ic, style: const TextStyle(fontSize: 24)), textDirection: TextDirection.ltr);
    icP.layout();
    icP.paint(canvas, Offset(w / 2 - icP.width / 2, h / 2 - icP.height / 2 - 8));

    // 攻/血
    _drawStat(canvas, 10, h - 14, instance.currentAttack, AppColors.attackColor);
    final hpColor = instance.currentHealth <= instance.maxHealth * 0.3 ? AppColors.danger : AppColors.healthColor;
    _drawStat(canvas, w - 10, h - 14, instance.currentHealth, hpColor);

    // 生命值低时红色背景闪烁（简化：红色边框）
    if (instance.currentHealth <= 2) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(r)),
        Paint()..color = AppColors.danger.withValues(alpha: 0.1));
    }

    // 边框
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, w - 2, h - 2), Radius.circular(r)),
      Paint()..color = instance.cardData.rarityBorderColor..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  void _drawStat(Canvas canvas, double cx, double cy, int value, Color color) {
    canvas.drawCircle(Offset(cx, cy), 10, Paint()..color = AppColors.primaryBg.withValues(alpha: 0.8));
    canvas.drawCircle(Offset(cx, cy), 10,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);
    final t = TextPainter(text: TextSpan(text: '$value', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr);
    t.layout();
    t.paint(canvas, Offset(cx - t.width / 2, cy - t.height / 2));
  }
}

class _ManaCrystal extends PositionComponent {
  int maxCrystals;
  int currentMana;

  _ManaCrystal({
    required Vector2 position,
    required this.maxCrystals,
    required this.currentMana,
  }) : super(position: position);

  @override
  void render(Canvas canvas) {
    const crystalSize = 28.0;
    const spacing = 32.0;
    for (var i = 0; i < maxCrystals; i++) {
      final cx = i * spacing + crystalSize / 2;
      final cy = crystalSize / 2;
      final filled = i < currentMana;
      if (filled) {
        canvas.drawCircle(Offset(cx, cy), crystalSize / 2 + 4,
          Paint()..color = AppColors.manaFull.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      }

      final path = Path();
      for (var j = 0; j < 6; j++) {
        final angle = j * 3.14159 / 3 - 3.14159 / 6;
        final px = cx + crystalSize / 2 * 0.9 * (angle == 0 ? 1 : (angle > 0 ? 1 : -1)); // simplified
        final px2 = cx + crystalSize / 2 * 0.9 * _cos(angle);
        final py2 = cy + crystalSize / 2 * 0.9 * _sin(angle);
        if (j == 0) path.moveTo(px2, py2);
        else path.lineTo(px2, py2);
      }
      path.close();

      canvas.drawPath(path, Paint()..color = filled
        ? AppColors.manaFull.withValues(alpha: 0.9)
        : AppColors.manaEmpty.withValues(alpha: 0.5));
      canvas.drawPath(path, Paint()..color = filled ? AppColors.manaFull : const Color(0xFF3A4070)..style = PaintingStyle.stroke..strokeWidth = 1.5);

      if (filled) {
        canvas.drawCircle(Offset(cx - 4, cy - 4), 4,
          Paint()..color = Colors.white.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      }
    }
  }

  double _cos(double a) => a == 0 ? 1 : 0.5;
  double _sin(double a) => a == 0 ? 0 : (a < 0 ? -0.866 : 0.866);
}

class _EndTurnButton extends PositionComponent with TapCallbacks {
  final VoidCallback? onTap;

  _EndTurnButton({required Vector2 position, this.onTap}) : super(position: position, size: Vector2(60, 30));

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(6)),
      Paint()..color = AppColors.accent);
    final t = TextPainter(text: const TextSpan(text: '结束', style: TextStyle(color: Color(0xFF0A0E27), fontSize: 12, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr);
    t.layout();
    t.paint(canvas, Offset(size.x / 2 - t.width / 2, size.y / 2 - t.height / 2));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap?.call();
  }
}

class _TurnHint extends PositionComponent {
  _TurnHint({required Vector2 position}) : super(position: position);

  @override
  void render(Canvas canvas) {
    final t = TextPainter(
      text: const TextSpan(text: '⚔ 职业卡牌 — Phase 3', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      textDirection: TextDirection.ltr);
    t.layout();
    t.paint(canvas, Offset(-t.width / 2, -t.height / 2));
  }
}

class _ToastText extends PositionComponent {
  final String text;
  double _alpha = 1.0;

  _ToastText({required this.text}) : super();

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    position = Vector2(gameSize.x / 2, 350);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _alpha -= dt * 0.6;
    if (_alpha <= 0) removeFromParent();
    position.y -= dt * 30;
  }

  @override
  void render(Canvas canvas) {
    final t = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: AppColors.accent.withValues(alpha: _alpha), fontSize: 18, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr);
    t.layout();
    t.paint(canvas, Offset(-t.width / 2, -t.height / 2));
  }
}

class _GameOverOverlay extends PositionComponent {
  final String winner;

  _GameOverOverlay({required Vector2 position, required this.winner})
      : super(position: position, anchor: Anchor.center, size: Vector2(400, 200));

  @override
  void render(Canvas canvas) {
    final w = size.x, h = size.y;
    canvas.drawRect(Rect.fromLTWH(-w / 2, -h / 2, w, h),
      Paint()..color = Colors.black.withValues(alpha: 0.7));

    final win = winner == '玩家';
    final title = win ? '🎉 胜利！' : '💀 失败...';
    final t = TextPainter(
      text: TextSpan(text: title, style: TextStyle(color: win ? AppColors.accent : AppColors.danger, fontSize: 36, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr);
    t.layout();
    t.paint(canvas, Offset(-t.width / 2, -40));

    final sub = TextPainter(
      text: TextSpan(text: win ? '恭喜你战胜了对手！' : '下次再接再厉！', style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
      textDirection: TextDirection.ltr);
    sub.layout();
    sub.paint(canvas, Offset(-sub.width / 2, 10));
  }
}
