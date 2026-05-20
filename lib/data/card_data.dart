import 'package:flutter/material.dart';
import 'keyword.dart';
import 'profession.dart';
import '../game/constants.dart';

/// ============================================================
/// 卡牌数据模型 — 核心数据结构
/// ============================================================
class CardData {
  final String id;           // 唯一标识
  final String name;         // 卡牌名称
  final int cost;           // 法力费用 (1-10)
  final int attack;         // 攻击力
  final int health;         // 生命值
  final List<Keyword> keywords; // 关键词列表
  final String? battlecryEffectId;   // 战吼效果 ID
  final String? deathrattleEffectId;  // 亡语效果 ID
  final String? passiveEffectId;      // 被动效果 ID
  final String? auraEffectId;         // 光环效果 ID
  final Faction faction;      // 派系
  final Profession profession; // 职业（所属职业）
  final String description;   // 描述文本
  final Rarity rarity;        // 稀有度

  const CardData({
    required this.id,
    required this.name,
    required this.cost,
    required this.attack,
    required this.health,
    this.keywords = const [],
    this.battlecryEffectId,
    this.deathrattleEffectId,
    this.passiveEffectId,
    this.auraEffectId,
    required this.faction,
    required this.profession,
    required this.description,
    required this.rarity,
  });

  /// 是否为随从卡（所有卡牌都是随从，暂不区分法术）
  bool get isMinion => true;

  /// 是否为嘲讽
  bool get hasTaunt => keywords.contains(Keyword.taunt);

  /// 稀有度对应颜色
  Color get rarityColor {
    switch (rarity) {
      case Rarity.common:    return AppColors.rarityCommon;
      case Rarity.rare:      return AppColors.rarityRare;
      case Rarity.epic:     return AppColors.rarityEpic;
      case Rarity.legendary: return AppColors.rarityLegendary;
    }
  }

  /// 稀有度边框颜色
  Color get rarityBorderColor {
    switch (rarity) {
      case Rarity.common:    return AppColors.textDisabled;
      case Rarity.rare:      return const Color(0xFF4A90D9);
      case Rarity.epic:     return const Color(0xFF9C27B0);
      case Rarity.legendary: return AppColors.accent;
    }
  }

  /// 职业对应颜色
  Color get professionColor {
    switch (profession) {
      case Profession.deliveryRider: return const Color(0xFFFFD700);
      case Profession.cashier:        return const Color(0xFF4CAF50);
      case Profession.mechanic:       return const Color(0xFF607D8B);
      case Profession.nurse:          return const Color(0xFFE53935);
      case Profession.construction:    return const Color(0xFFFF5722);
      case Profession.teacher:        return const Color(0xFF2196F3);
      case Profession.programmer:     return const Color(0xFF00BCD4);
      case Profession.police:         return const Color(0xFF1A237E);
      case Profession.chef:           return const Color(0xFF795548);
      case Profession.firefighter:     return const Color(0xFFFF5722);
      case Profession.designer:       return const Color(0xFF9C27B0);
      case Profession.executive:      return const Color(0xFF4CAF50);
      case Profession.doctor:         return const Color(0xFFE53935);
      case Profession.soldier:       return const Color(0xFF607D8B);
      case Profession.craftsman:      return const Color(0xFFFFD700);
      case Profession.student:        return const Color(0xFF2196F3);
    }
  }

  @override
  String toString() => 'CardData($name, $cost mana, $attack/$health)';
}
