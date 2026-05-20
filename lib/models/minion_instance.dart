import '../../data/card_data.dart';
import '../../data/keyword.dart';

/// ============================================================
/// 战场上随从实例 — 运行时数据（区别于静态 CardData）
/// ============================================================
class MinionInstance {
  final String instanceId;     // 唯一实例ID（UUID或时间戳）
  final CardData cardData;     // 对应卡牌数据

  int currentAttack;           // 当前攻击力
  int currentHealth;           // 当前生命值
  int maxHealth;              // 最大生命值
  final Set<Keyword> keywords; // 当前关键词状态

  bool hasDivineShield;       // 圣盾是否激活
  bool isFrozen;              // 是否被冻结
  bool hasAttackedThisTurn;   // 本回合是否已攻击
  bool canAttack;             // 是否可以攻击（冲锋/风怒）

  MinionInstance({
    required this.instanceId,
    required this.cardData,
  })  : currentAttack = cardData.attack,
        currentHealth = cardData.health,
        maxHealth = cardData.health,
        keywords = Set.from(cardData.keywords),
        hasDivineShield = cardData.keywords.contains(Keyword.divineShield),
        isFrozen = false,
        hasAttackedThisTurn = false,
        canAttack = cardData.keywords.contains(Keyword.charge);

  /// 承受伤害
  void takeDamage(int amount) {
    if (hasDivineShield) {
      hasDivineShield = false;
      return;
    }
    currentHealth -= amount;
  }

  /// 回复生命
  void heal(int amount) {
    currentHealth = (currentHealth + amount).clamp(0, maxHealth);
  }

  /// 回合开始重置
  void resetTurn() {
    hasAttackedThisTurn = false;
    if (keywords.contains(Keyword.windfury)) {
      canAttack = true;
    }
    if (isFrozen) {
      isFrozen = false;
      canAttack = false;
    }
  }

  /// 是否存活
  bool get isAlive => currentHealth > 0;

  /// 是否为嘲讽
  bool get isTaunt => keywords.contains(Keyword.taunt);

  /// 沉默（移除所有关键词）
  void silence() {
    keywords.clear();
    hasDivineShield = false;
  }

  /// 是否可以攻击
  bool get canCurrentlyAttack => canAttack && !isFrozen && !hasAttackedThisTurn;

  @override
  String toString() => 'Minion(${cardData.name} $currentAttack/$currentHealth)';
}
