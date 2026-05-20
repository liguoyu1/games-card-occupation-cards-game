import 'dart:math' as math;
import '../data/card_data.dart';
import 'minion_instance.dart';

/// ============================================================
/// 玩家状态模型 — 包含手牌/牌库/场上/生命值/法力值
/// ============================================================
class PlayerState {
  final bool isEnemy;             // 是否为敌方
  String name;                   // 玩家名称

  int health;                    // 当前生命值
  int maxHealth;                 // 最大生命值
  int currentMana;               // 当前法力值
  int maxMana;                   // 当前法力上限
  int heroPowerCost;             // 英雄技能费用

  final List<CardData> deck;      // 牌库
  final List<CardData> hand;     // 手牌
  final List<MinionInstance> minions; // 场上随从

  int deckDrawIndex;             // 抽牌索引（随机用）
  final math.Random _rng;

  PlayerState({
    required this.isEnemy,
    required this.name,
    int initialHealth = 30,
    int initialDeckSize = 30,
  })  : health = initialHealth,
        maxHealth = initialHealth,
        currentMana = 1,
        maxMana = 1,
        heroPowerCost = 2,
        deck = [],
        hand = [],
        minions = [],
        deckDrawIndex = 0,
        _rng = math.Random();

  /// 初始化牌库（复制卡牌列表并洗牌）
  void initDeck(List<CardData> cardList) {
    deck.clear();
    deck.addAll(cardList);
    deck.shuffle(_rng);
  }

  /// 抽一张牌
  CardData? drawCard() {
    if (deck.isEmpty) return null;
    if (hand.length >= 10) return null; // 手牌上限10张

    final card = deck.removeLast();
    hand.add(card);
    return card;
  }

  /// 初始抽牌（开局抽3/4张）
  void drawInitialCards(int count) {
    for (var i = 0; i < count; i++) {
      drawCard();
    }
  }

  /// 使用一张手牌（从手牌移除）
  CardData? useCard(CardData card) {
    final idx = hand.indexWhere((c) => c.id == card.id);
    if (idx == -1) return null;
    return hand.removeAt(idx);
  }

  /// 出牌消耗法力
  bool spendMana(int amount) {
    if (currentMana < amount) return false;
    currentMana -= amount;
    return true;
  }

  /// 回合开始：法力值+1（上限10）
  void startTurn() {
    if (maxMana < 10) maxMana++;
    currentMana = maxMana;

    // 重置随从状态
    for (final minion in minions) {
      minion.resetTurn();
    }
  }

  /// 回合结束
  void endTurn() {}

  /// 召唤随从
  MinionInstance summonMinion(CardData card) {
    final instance = MinionInstance(
      instanceId: '${card.id}_${DateTime.now().millisecondsSinceEpoch}',
      cardData: card,
    );
    minions.add(instance);
    return instance;
  }

  /// 移除死亡随从
  void removeDeadMinions() {
    minions.removeWhere((m) => !m.isAlive);
  }

  /// 是否存活
  bool get isAlive => health > 0;

  /// 可用手牌（费用 <= 当前法力）
  List<CardData> get playableCards =>
      hand.where((c) => c.cost <= currentMana).toList();

  /// 手牌是否已满
  bool get handFull => hand.length >= 10;

  /// 牌库是否为空
  bool get deckEmpty => deck.isEmpty;
}
