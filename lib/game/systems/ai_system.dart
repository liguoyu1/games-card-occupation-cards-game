import 'dart:math' as math;
import '../../data/card_data.dart';
import '../../data/keyword.dart';
import '../../models/player_state.dart';
import '../../models/minion_instance.dart';
import 'keyword_effect_system.dart';

/// ============================================================
/// AI 对手系统 — 智能出牌与攻击
/// ============================================================
class AISystem {
  final PlayerState ai;
  final PlayerState player;
  final math.Random _rng;

  AISystem({required this.ai, required this.player}) : _rng = math.Random();

  /// AI 出牌阶段
  void playCards() {
    while (ai.minions.length < 7) {
      final playable = ai.playableCards;
      if (playable.isEmpty) break;

      // 优先出高费卡（但保留一些关键卡）
      playable.sort((a, b) => b.cost.compareTo(a.cost));

      CardData? bestCard;
      for (final card in playable) {
        if (ai.currentMana < card.cost) continue;
        // 保留传说卡到后期
        if (card.rarity == Rarity.legendary && ai.health > 20) continue;
        bestCard = card;
        break;
      }

      if (bestCard == null) break;

      ai.spendMana(bestCard.cost);
      ai.useCard(bestCard);
      final minion = ai.summonMinion(bestCard);

      // 触发战吼
      if (bestCard.battlecryEffectId != null) {
        _executeBattlecry(minion, bestCard.battlecryEffectId!);
      }
    }
  }

  /// AI 攻击阶段
  void attackPhase() {
    // 按威胁度排序随从
    final attackers = ai.minions.where((m) => m.canCurrentlyAttack).toList();
    if (attackers.isEmpty) return;

    for (final attacker in attackers) {
      _chooseAttackTarget(attacker);
      attacker.hasAttackedThisTurn = true;

      // 风怒检查
      if (attacker.keywords.contains(Keyword.windfury)) {
        attacker.hasAttackedThisTurn = false;
      }
    }
  }

  void _chooseAttackTarget(MinionInstance attacker) {
    // 嘲讽优先
    final taunts = player.minions.where((m) => m.keywords.contains(Keyword.taunt)).toList();
    if (taunts.isNotEmpty) {
      _attackMinion(attacker, taunts[0]);
      return;
    }

    // 优先击杀低血量威胁随从
    final threats = player.minions.where((m) => m.currentAttack >= attacker.currentAttack).toList();
    if (threats.isNotEmpty && threats.length <= 2) {
      threats.sort((a, b) => b.currentAttack.compareTo(a.currentAttack));
      // 击杀收益评估
      final best = threats.first;
      if (best.currentHealth <= attacker.currentAttack || best.currentAttack >= 5) {
        _attackMinion(attacker, best);
        return;
      }
    }

    // 英雄攻击（如果随从威胁不大）
    final highThreat = player.minions.where((m) => m.currentAttack >= 4).toList();
    if (highThreat.isEmpty || _rng.nextDouble() < 0.3) {
      _attackHero(attacker);
    } else {
      // 攻击中等威胁随从
      final targets = player.minions.where((m) => !m.keywords.contains(Keyword.taunt)).toList();
      if (targets.isNotEmpty) {
        targets.sort((a, b) => b.currentAttack.compareTo(a.currentAttack));
        _attackMinion(attacker, targets.first);
      } else {
        _attackHero(attacker);
      }
    }
  }

  void _attackMinion(MinionInstance attacker, MinionInstance defender) {
    // 圣盾
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

    // 冻结
    if (attacker.keywords.contains(Keyword.freeze)) {
      defender.isFrozen = true;
    }
  }

  void _attackHero(MinionInstance attacker) {
    player.health -= attacker.currentAttack;
  }

  void _executeBattlecry(MinionInstance minion, String effectId) {
    // 战吼效果执行
    switch (effectId) {
      case 'heal_2':
        // 治疗随机友方
        if (ai.minions.isNotEmpty) {
          final target = ai.minions[_rng.nextInt(ai.minions.length)];
          target.heal(2);
        } else {
          ai.health = (ai.health + 2).clamp(0, ai.maxHealth);
        }
        break;

      case 'heal_all_1':
        for (final m in ai.minions) {
          m.heal(1);
        }
        ai.health = (ai.health + 1).clamp(0, ai.maxHealth);
        break;

      case 'freeze_1':
        if (player.minions.isNotEmpty) {
          final target = player.minions[_rng.nextInt(player.minions.length)];
          target.isFrozen = true;
        }
        break;

      case 'destroy_2cost':
        final lowCost = player.minions.where((m) => m.cardData.cost <= 2).toList();
        if (lowCost.isNotEmpty) {
          lowCost[0].currentHealth = 0;
        }
        break;

      case 'summon_student':
        // 召唤学生随从
        final studentCard = _findCardById('student');
        if (studentCard != null) {
          ai.summonMinion(studentCard);
        }
        break;

      default:
        // 通用效果执行
        KeywordEffectSystem.executeBattlecry(effectId, {'player': ai, 'enemy': player});
    }
  }

  CardData? _findCardById(String id) {
    // 简化：从全部卡牌中查找
    final allCards = _getAllCards();
    try {
      return allCards.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<CardData> _getAllCards() {
    // 这里应该导入所有卡牌数据
    // 临时返回空列表，由外部提供
    return [];
  }
}

/// ============================================================
/// 回合管理器
/// ============================================================
class TurnManager {
  final PlayerState player;
  final PlayerState enemy;
  final AISystem aiSystem;
  int turnNumber = 0;

  TurnManager({required this.player, required this.enemy})
      : aiSystem = AISystem(ai: enemy, player: player);

  /// 开始玩家回合
  void startPlayerTurn() {
    turnNumber++;
    player.startTurn();
    player.drawCard();
  }

  /// 结束玩家回合 → AI回合
  void endPlayerTurnAndExecuteEnemy() {
    player.endTurn();

    // AI 回合
    enemy.startTurn();
    enemy.drawCard();

    // AI 出牌
    aiSystem.playCards();

    // AI 攻击
    aiSystem.attackPhase();

    enemy.endTurn();

    // 清理死亡随从
    _processDeaths();
  }

  void _processDeaths() {
    // 处理亡语
    final playerDead = player.minions.where((m) => !m.isAlive).toList();
    final enemyDead = enemy.minions.where((m) => !m.isAlive).toList();

    player.removeDeadMinions();
    enemy.removeDeadMinions();

    for (final minion in playerDead) {
      _triggerDeathrattle(minion, player);
    }
    for (final minion in enemyDead) {
      _triggerDeathrattle(minion, enemy);
    }
  }

  void _triggerDeathrattle(MinionInstance minion, PlayerState owner) {
    if (minion.cardData.deathrattleEffectId == null) return;

    final effectId = minion.cardData.deathrattleEffectId!;

    switch (effectId) {
      case 'draw_1':
        owner.drawCard();
        break;
      case 'aoe_3':
        final target = owner == player ? enemy : player;
        for (final m in target.minions) {
          m.takeDamage(3);
        }
        break;
      default:
        KeywordEffectSystem.executeDeathrattle(effectId, {'player': owner, 'enemy': owner == player ? enemy : player});
    }
  }

  /// 检查胜负
  GameEndResult? checkGameEnd() {
    if (!player.isAlive) {
      return GameEndResult(winner: GameWinner.enemy, reason: '你的生命值降至 0');
    }
    if (!enemy.isAlive) {
      return GameEndResult(winner: GameWinner.player, reason: '对手的生命值降至 0');
    }
    if (player.deckEmpty && player.hand.isEmpty) {
      return GameEndResult(winner: GameWinner.enemy, reason: '你的牌库耗尽');
    }
    if (enemy.deckEmpty && enemy.hand.isEmpty) {
      return GameEndResult(winner: GameWinner.player, reason: '对手牌库耗尽');
    }
    return null;
  }
}

enum GameWinner { player, enemy }

class GameEndResult {
  final GameWinner winner;
  final String reason;

  GameEndResult({required this.winner, required this.reason});

  String get winnerName => winner == GameWinner.player ? '玩家' : '对手';
}