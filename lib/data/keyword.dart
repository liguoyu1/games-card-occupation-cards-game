/// ============================================================
/// 关键词枚举 + 效果定义
/// ============================================================
enum Keyword {
  charge,    // 冲锋：登场即可攻击
  taunt,     // 嘲讽：必须先攻击嘲讽目标
  divineShield, // 圣盾：首次伤害免疫
  battlecry, // 战吼：登场时触发
  deathrattle, // 亡语：死亡时触发
  windfury,  // 风怒：一回合可攻击两次
  freeze,    // 冻结：下回合无法攻击
  stealth,   // 潜行：无法被指定为目标
}

extension KeywordExtension on Keyword {
  String get nameCn {
    switch (this) {
      case Keyword.charge:     return '冲锋';
      case Keyword.taunt:      return '嘲讽';
      case Keyword.divineShield: return '圣盾';
      case Keyword.battlecry:  return '战吼';
      case Keyword.deathrattle: return '亡语';
      case Keyword.windfury:   return '风怒';
      case Keyword.freeze:     return '冻结';
      case Keyword.stealth:    return '潜行';
    }
  }

  String get keywordColor {
    switch (this) {
      case Keyword.charge:      return '#FFB800'; // 琥珀金
      case Keyword.taunt:      return '#FF5722'; // 橙色
      case Keyword.divineShield: return '#FFD600'; // 圣光金
      case Keyword.battlecry:  return '#00E676'; // 荧光绿
      case Keyword.deathrattle: return '#9C27B0'; // 紫色
      case Keyword.windfury:   return '#2196F3'; // 蓝色
      case Keyword.freeze:     return '#00B4D8'; // 冰川蓝
      case Keyword.stealth:    return '#607D8B'; // 灰蓝
    }
  }
}

/// 稀有度
enum Rarity {
  common,   // 普通
  rare,     // 稀有
  epic,     // 史诗
  legendary, // 传说
}

extension RarityExtension on Rarity {
  String get nameCn {
    switch (this) {
      case Rarity.common:    return '普通';
      case Rarity.rare:      return '稀有';
      case Rarity.epic:     return '史诗';
      case Rarity.legendary: return '传说';
    }
  }
}
