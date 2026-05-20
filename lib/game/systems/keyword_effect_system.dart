/// ============================================================
/// 关键词效果系统 — 全部 16 种效果 ID
/// ============================================================
class KeywordEffectSystem {
  /// 执行战吼效果
  static BattlecryResult executeBattlecry(String effectId, Map<String, dynamic> ctx) {
    final player = ctx['player'] as dynamic;
    final enemy = ctx['enemy'] as dynamic;

    switch (effectId) {
      // ===== 治疗 =====
      case 'heal_2':
        if (player.minions.isNotEmpty) {
          final m = player.minions.first;
          m.heal(2);
        } else {
          player.health = (player.health + 2).clamp(0, player.maxHealth);
        }
        return BattlecryResult(message: '治疗 2 点');

      case 'heal_3':
        if (player.minions.isNotEmpty) {
          final m = player.minions.first;
          m.heal(3);
        } else {
          player.health = (player.health + 3).clamp(0, player.maxHealth);
        }
        return BattlecryResult(message: '治疗 3 点');

      case 'heal_all_1':
        for (final m in player.minions) m.heal(1);
        player.health = (player.health + 1).clamp(0, player.maxHealth);
        return BattlecryResult(message: '全体治疗 1 点');

      case 'heal_all_2':
        for (final m in player.minions) m.heal(2);
        player.health = (player.health + 2).clamp(0, player.maxHealth);
        return BattlecryResult(message: '全体治疗 2 点');

      case 'heal_all_3':
        for (final m in player.minions) m.heal(3);
        player.health = (player.health + 3).clamp(0, player.maxHealth);
        return BattlecryResult(message: '全体治疗 3 点');

      case 'heal_5':
        player.health = (player.health + 5).clamp(0, player.maxHealth);
        return BattlecryResult(message: '恢复 5 点生命');

      // ===== 召唤 =====
      case 'summon_student':
        final student = player.summonMinion(_findCardById('st1', player)!);
        return BattlecryResult(message: '召唤了学生');

      case 'summon_3_student':
        _findCardById('st1', player);
        if (_findCardById('st1', player) != null) {
          for (var i = 0; i < 3; i++) {
            if (player.minions.length < 7) {
              player.summonMinion(_findCardById('st1', player)!);
            }
          }
        }
        return BattlecryResult(message: '召唤了 3 个学生');

      // ===== 冻结 =====
      case 'freeze_1':
        if (enemy.minions.isNotEmpty) {
          final idx = DateTime.now().millisecond % enemy.minions.length;
          enemy.minions[idx].isFrozen = true;
        }
        return BattlecryResult(message: '冻结了 1 个敌方随从');

      case 'freeze_all':
        for (final m in enemy.minions) m.isFrozen = true;
        return BattlecryResult(message: '冻结所有敌方随从');

      // ===== Buff =====
      case 'buff_1_1':
        if (player.minions.isNotEmpty) {
          final idx = DateTime.now().millisecond % player.minions.length;
          player.minions[idx].currentAttack += 1;
          player.minions[idx].maxHealth += 1;
          player.minions[idx].currentHealth += 1;
        }
        return BattlecryResult(message: '+1/+1');

      case 'buff_2_2':
        if (player.minions.isNotEmpty) {
          final idx = DateTime.now().millisecond % player.minions.length;
          player.minions[idx].currentAttack += 2;
          player.minions[idx].maxHealth += 2;
          player.minions[idx].currentHealth += 2;
        }
        return BattlecryResult(message: '+2/+2');

      case 'buff_self_2':
        if (player.minions.isNotEmpty) {
          final m = player.minions.last;
          m.currentAttack += 2;
        }
        return BattlecryResult(message: '自身 +2 攻击');

      // ===== 法力 =====
      case 'fill_mana':
        player.currentMana = player.maxMana;
        return BattlecryResult(message: '法力水晶充满');

      // ===== AOE =====
      case 'aoe_1':
        for (final m in enemy.minions) {
          m.currentHealth -= 1;
        }
        return BattlecryResult(message: '对全体敌方造成 1 点伤害');

      case 'aoe_3':
        for (final m in enemy.minions) {
          m.currentHealth -= 3;
        }
        return BattlecryResult(message: '对全体敌方造成 3 点伤害');

      // ===== 圣盾 =====
      case 'divine_shield_self':
        if (player.minions.isNotEmpty) {
          player.minions.last.hasDivineShield = true;
        }
        return BattlecryResult(message: '获得圣盾');

      // ===== 抽牌 =====
      case 'draw_2':
        player.drawCard();
        player.drawCard();
        return BattlecryResult(message: '抽 2 张牌');

      // ===== 沉默 =====
      case 'silence_1':
        if (enemy.minions.isNotEmpty) {
          final idx = DateTime.now().millisecond % enemy.minions.length;
          enemy.minions[idx].silence();
        }
        return BattlecryResult(message: '沉默 1 个敌方随从');

      default:
        return BattlecryResult(message: '触发战吼');
    }
  }

  /// 执行亡语效果
  static DeathrattleResult executeDeathrattle(String effectId, Map<String, dynamic> ctx) {
    final player = ctx['player'] as dynamic;
    final enemy = ctx['enemy'] as dynamic;

    switch (effectId) {
      case 'draw_1':
        player.drawCard();
        return DeathrattleResult(message: '亡语：抽 1 张牌');

      case 'heal_5':
        player.health = (player.health + 5).clamp(0, player.maxHealth);
        return DeathrattleResult(message: '亡语：恢复 5 点生命');

      case 'buff_all_1_1':
        for (final m in player.minions) {
          m.currentAttack += 1;
          m.maxHealth += 1;
          m.currentHealth += 1;
        }
        return DeathrattleResult(message: '亡语：全体 +1/+1');

      case 'mana_1':
        // 当前版本不增加法力水晶
        return DeathrattleResult(message: '亡语：法力恢复');

      case 'aoe_3':
        for (final m in enemy.minions) {
          m.currentHealth -= 3;
        }
        return DeathrattleResult(message: '亡语：对全体敌方造成 3 点伤害');

      case 'destroy_random':
        if (enemy.minions.isNotEmpty) {
          final idx = DateTime.now().millisecond % enemy.minions.length;
          enemy.minions[idx].currentHealth = 0;
        }
        return DeathrattleResult(message: '亡语：消灭一个随机敌方随从');

      default:
        return DeathrattleResult(message: '亡语触发');
    }
  }
}

dynamic _findCardById(String id, dynamic owner) {
  try {
    return owner.deck.firstWhere((c) => c.id == id);
  } catch (_) {
    // 返回默认学生卡
    try {
      return owner.deck.firstWhere((c) => c.id == 'st1');
    } catch (_) {
      return null;
    }
  }
}

class BattlecryResult {
  final String message;
  BattlecryResult({required this.message});
}

class DeathrattleResult {
  final String message;
  DeathrattleResult({required this.message});
}
