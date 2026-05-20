import 'dart:math' as math;
import '../../data/card_data.dart';
import '../../data/keyword.dart';
import '../../models/player_state.dart';
import '../../models/minion_instance.dart';
import 'keyword_effect_system.dart';

/// ============================================================
/// 战斗系统 — 出牌/攻击/回合控制/胜负判定
/// ============================================================
class BattleSystem {
  final PlayerState player;
  final PlayerState enemy;

  bool _isPlayerTurn = true;
  bool _turnInProgress = false;
  int _turnNumber = 1;

  BattleSystem({required this.player, required this.enemy});

  // ---- 回合控制 ----

  bool get isPlayerTurn => _isPlayerTurn;

  /// 开始玩家回合
  void startPlayerTurn() {
    if (_turnInProgress) return;
    _isPlayerTurn = true;
    _turnInProgress = true;
    _turnNumber++;

    // 法力值 +1
    player.startTurn();

    // 抽一张牌
    player.drawCard();
  }

  /// 结束玩家回合
  void endPlayerTurn() {
    if (!_isPlayerTurn || !_turnInProgress) return;
    _isPlayerTurn = false;
    _turnInProgress = false;
    player.endTurn();

    // 触发对手回合
    _executeEnemyTurn();
  }

  /// 敌方 AI 回合
  void _executeEnemyTurn() {
    enemy.startTurn();
    enemy.drawCard();

    // AI 出牌（简化：优先出高费卡）
    _executeEnemyPlayPhase();

    // 敌方随从攻击
    _executeEnemyAttacks();

    // 回合结束
    enemy.endTurn();

    // 切回玩家回合
    _isPlayerTurn = true;
    _turnInProgress = true;
    player.startTurn();
  }

  /// AI 出牌逻辑（简化版）
  void _executeEnemyPlayPhase() {
    final playable = enemy.playableCards;
    playable.sort((a, b) => b.cost.compareTo(a.cost)); // 高费优先

    for (final card in playable) {
      if (enemy.spendMana(card.cost)) {
        enemy.useCard(card);
        final minion = enemy.summonMinion(card);
        _triggerBattlecry(minion);
      }
    }
  }

  /// 敌方随从攻击
  void _executeEnemyAttacks() {
    for (final minion in enemy.minions) {
      if (!minion.canCurrentlyAttack) continue;

      // 优先攻击嘲讽
      final tauntMinions = player.minions.where((m) => m.keywords.contains(Keyword.taunt)).toList();
      if (tauntMinions.isNotEmpty) {
        final target = tauntMinions[math.Random().nextInt(tauntMinions.length)];
        _attackMinion(minion, target);
      } else if (player.minions.isNotEmpty) {
        // 随机选择随从或英雄
        if (math.Random().nextBool() && player.minions.isNotEmpty) {
          final target = player.minions[math.Random().nextInt(player.minions.length)];
          _attackMinion(minion, target);
        } else {
          _attackHero(enemy, player);
        }
      } else {
        _attackHero(enemy, player);
      }
    }
  }

  // ---- 出牌 ----

  /// 玩家打出卡牌
  BattleResult? playCard(CardData card, {int? targetIndex}) {
    if (!_isPlayerTurn) return null;
    if (!player.playableCards.contains(card)) return null;
    if (player.minions.length >= 7) return null; // 场上最多7个随从

    if (!player.spendMana(card.cost)) return null;
    player.useCard(card);

    final minion = player.summonMinion(card);
    _triggerBattlecry(minion);

    return BattleResult(
      success: true,
      type: ResultType.cardPlayed,
      message: '打出: ${card.name}',
      minionInstance: minion,
    );
  }

  // ---- 攻击 ----

  /// 玩家随从攻击敌方随从
  BattleResult? attackMinion(int attackerIndex, int defenderIndex) {
    if (!_isPlayerTurn) return null;
    if (attackerIndex < 0 || attackerIndex >= player.minions.length) return null;
    if (defenderIndex < 0 || defenderIndex >= enemy.minions.length) return null;

    final attacker = player.minions[attackerIndex];
    if (!attacker.canCurrentlyAttack) {
      return BattleResult(success: false, type: ResultType.attackFailed, message: '该随从无法攻击');
    }

    // 检查嘲讽
    final defender = enemy.minions[defenderIndex];
    final hasTaunt = enemy.minions.any((m) => m.keywords.contains(Keyword.taunt));
    if (hasTaunt && !defender.isTaunt) {
      return BattleResult(success: false, type: ResultType.attackFailed, message: '必须先攻击嘲讽随从');
    }

    _attackMinion(attacker, defender);

    return BattleResult(
      success: true,
      type: ResultType.minionAttacked,
      message: '${attacker.cardData.name} 攻击 ${defender.cardData.name}',
      attackerDamage: attacker.currentAttack,
      defenderDamage: defender.currentAttack,
    );
  }

  /// 玩家随从攻击敌方英雄
  BattleResult? attackHero(int attackerIndex) {
    if (!_isPlayerTurn) return null;
    if (attackerIndex < 0 || attackerIndex >= player.minions.length) return null;

    final attacker = player.minions[attackerIndex];
    if (!attacker.canCurrentlyAttack) {
      return BattleResult(success: false, type: ResultType.attackFailed, message: '该随从无法攻击');
    }

    // 检查嘲讽
    final hasTaunt = enemy.minions.any((m) => m.keywords.contains(Keyword.taunt));
    if (hasTaunt) {
      return BattleResult(success: false, type: ResultType.attackFailed, message: '必须先攻击嘲讽随从');
    }

    _attackHero(player, enemy);
    attacker.hasAttackedThisTurn = true;

    return BattleResult(
      success: true,
      type: ResultType.heroAttacked,
      message: '${attacker.cardData.name} 攻击对手',
      damage: attacker.currentAttack,
    );
  }

  void _attackMinion(MinionInstance attacker, MinionInstance defender) {
    // 圣盾处理
    if (defender.hasDivineShield) {
      defender.hasDivineShield = false;
    } else {
      defender.currentHealth -= attacker.currentAttack;
    }

    if (attacker.hasDivineShield) {
      attacker.hasDivineShield = false;
    } else {
      attacker.currentHealth -= defender.currentAttack;
    }

    // 冻结效果
    if (attacker.keywords.contains(Keyword.freeze)) {
      defender.isFrozen = true;
    }

    // 风怒
    if (attacker.keywords.contains(Keyword.windfury) && !attacker.hasAttackedThisTurn) {
      attacker.hasAttackedThisTurn = false;
    } else {
      attacker.hasAttackedThisTurn = true;
    }

    // 移除死亡随从并触发亡语
    _removeDeadMinions(player);
    _removeDeadMinions(enemy);
  }

  void _attackHero(PlayerState attacker, PlayerState defender) {
    // 找出攻击者
    final attackers = attacker.minions.where((m) => m.canCurrentlyAttack).toList();
    for (final atk in attackers) {
      defender.health -= atk.currentAttack;
      atk.hasAttackedThisTurn = true;
    }
  }

  void _removeDeadMinions(PlayerState p) {
    final dead = p.minions.where((m) => !m.isAlive).toList();
    p.removeDeadMinions();
    for (final minion in dead) {
      _triggerDeathrattle(minion);
    }
  }

  // ---- 战吼/亡语触发 ----

  void _triggerBattlecry(MinionInstance minion) {
    final effectId = minion.cardData.battlecryEffectId;
    if (effectId == null) return;
    KeywordEffectSystem.executeBattlecry(effectId, {
      'player': player,
      'enemy': enemy,
    });
  }

  void _triggerDeathrattle(MinionInstance minion) {
    final effectId = minion.cardData.deathrattleEffectId;
    if (effectId == null) return;
    KeywordEffectSystem.executeDeathrattle(effectId, {
      'player': player,
      'enemy': enemy,
    });
  }

  // ---- 胜负判定 ----

  bool get isGameOver => !player.isAlive || !enemy.isAlive;

  String get winner {
    if (!player.isAlive) return '对手';
    if (!enemy.isAlive) return '玩家';
    return '';
  }
}

// ---- 扩展 MinionInstance ----
extension MinionInstanceX on MinionInstance {
  bool get isTaunt => keywords.contains(Keyword.taunt);
}

// ---- 战斗结果 ----
enum ResultType {
  cardPlayed,
  minionAttacked,
  heroAttacked,
  turnEnded,
  attackFailed,
}

class BattleResult {
  final bool success;
  final ResultType type;
  final String message;
  final MinionInstance? minionInstance;
  final int? damage;
  final int? attackerDamage;
  final int? defenderDamage;

  BattleResult({
    required this.success,
    required this.type,
    required this.message,
    this.minionInstance,
    this.damage,
    this.attackerDamage,
    this.defenderDamage,
  });
}
