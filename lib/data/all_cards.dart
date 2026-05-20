import 'card_data.dart';
import 'keyword.dart';
import 'profession.dart';

/// ============================================================
/// 全卡牌数据库 — 32 张（16职业各2张）
/// ============================================================
class AllCards {
  static final List<CardData> cards = [
    // ===== 程序员 =====
    CardData(id:'p1', name:'初级码农', cost:2, attack:3, health:2,
      keywords:[Keyword.charge], description:'冲锋', rarity:Rarity.common,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.technical, profession:Profession.programmer),
    CardData(id:'p2', name:'高级架构师', cost:6, attack:5, health:6,
      keywords:[Keyword.battlecry], description:'战吼：召唤1个学生', rarity:Rarity.rare,
      battlecryEffectId:'summon_student', deathrattleEffectId:null,
      faction:Faction.technical, profession:Profession.programmer),

    // ===== 医生 =====
    CardData(id:'d1', name:'见习医生', cost:3, attack:2, health:4,
      keywords:[Keyword.battlecry], description:'战吼：治疗所有友方2点', rarity:Rarity.common,
      battlecryEffectId:'heal_all_2', deathrattleEffectId:null,
      faction:Faction.business, profession:Profession.doctor),
    CardData(id:'d2', name:'外科主任', cost:7, attack:4, health:7,
      keywords:[Keyword.battlecry, Keyword.divineShield], description:'战吼：圣盾，治疗所有友方3点', rarity:Rarity.legendary,
      battlecryEffectId:'heal_all_3', deathrattleEffectId:null,
      faction:Faction.business, profession:Profession.doctor),

    // ===== 护士 =====
    CardData(id:'n1', name:'实习护士', cost:1, attack:1, health:2,
      keywords:[], description:'', rarity:Rarity.common,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.civilian, profession:Profession.nurse),
    CardData(id:'n2', name:'护士长', cost:3, attack:2, health:4,
      keywords:[Keyword.battlecry], description:'战吼：治疗英雄3点', rarity:Rarity.rare,
      battlecryEffectId:'heal_3', deathrattleEffectId:null,
      faction:Faction.civilian, profession:Profession.nurse),

    // ===== 消防员 =====
    CardData(id:'f1', name:'消防兵', cost:2, attack:2, health:3,
      keywords:[Keyword.taunt], description:'嘲讽', rarity:Rarity.common,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.government, profession:Profession.firefighter),
    CardData(id:'f2', name:'消防队长', cost:5, attack:4, health:5,
      keywords:[Keyword.taunt, Keyword.divineShield], description:'嘲讽，圣盾', rarity:Rarity.epic,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.government, profession:Profession.firefighter),

    // ===== 警察 =====
    CardData(id:'g1', name:'巡警', cost:2, attack:2, health:2,
      keywords:[Keyword.freeze], description:'冻结', rarity:Rarity.common,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.government, profession:Profession.police),
    CardData(id:'g2', name:'警长', cost:5, attack:3, health:5,
      keywords:[Keyword.battlecry], description:'战吼：冻结所有敌方随从', rarity:Rarity.epic,
      battlecryEffectId:'freeze_all', deathrattleEffectId:null,
      faction:Faction.government, profession:Profession.police),

    // ===== 外卖骑手 =====
    CardData(id:'r1', name:'外卖骑手', cost:1, attack:2, health:1,
      keywords:[Keyword.charge], description:'冲锋', rarity:Rarity.common,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.civilian, profession:Profession.deliveryRider),
    CardData(id:'r2', name:'配送站长', cost:4, attack:3, health:4,
      keywords:[Keyword.deathrattle], description:'亡语：抽1张牌', rarity:Rarity.rare,
      battlecryEffectId:null, deathrattleEffectId:'draw_1',
      faction:Faction.civilian, profession:Profession.deliveryRider),

    // ===== 收银员 =====
    CardData(id:'c1', name:'超市收银', cost:1, attack:1, health:2,
      keywords:[Keyword.deathrattle], description:'亡语：抽1张牌', rarity:Rarity.common,
      battlecryEffectId:null, deathrattleEffectId:'draw_1',
      faction:Faction.civilian, profession:Profession.cashier),
    CardData(id:'c2', name:'店长', cost:5, attack:3, health:4,
      keywords:[Keyword.battlecry], description:'战吼：你的法力水晶充满', rarity:Rarity.epic,
      battlecryEffectId:'fill_mana', deathrattleEffectId:null,
      faction:Faction.civilian, profession:Profession.cashier),

    // ===== 汽修师傅 =====
    CardData(id:'m1', name:'汽修学徒', cost:2, attack:2, health:3,
      keywords:[Keyword.divineShield], description:'圣盾', rarity:Rarity.rare,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.technical, profession:Profession.mechanic),
    CardData(id:'m2', name:'汽修大师', cost:4, attack:3, health:5,
      keywords:[Keyword.battlecry], description:'战吼：使一个友方随从+2/+2', rarity:Rarity.rare,
      battlecryEffectId:'buff_2_2', deathrattleEffectId:null,
      faction:Faction.technical, profession:Profession.mechanic),

    // ===== 厨师 =====
    CardData(id:'h1', name:'厨房学徒', cost:1, attack:2, health:1,
      keywords:[], description:'', rarity:Rarity.common,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.technical, profession:Profession.chef),
    CardData(id:'h2', name:'主厨', cost:4, attack:3, health:5,
      keywords:[Keyword.deathrattle], description:'亡语：恢复英雄5点生命', rarity:Rarity.rare,
      battlecryEffectId:null, deathrattleEffectId:'heal_5',
      faction:Faction.technical, profession:Profession.chef),

    // ===== 建筑工人 =====
    CardData(id:'b1', name:'泥瓦工', cost:2, attack:3, health:1,
      keywords:[Keyword.charge], description:'冲锋', rarity:Rarity.common,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.business, profession:Profession.construction),
    CardData(id:'b2', name:'建筑师', cost:4, attack:3, health:5,
      keywords:[Keyword.battlecry], description:'战吼：对全体敌方造成1点伤害', rarity:Rarity.epic,
      battlecryEffectId:'aoe_1', deathrattleEffectId:null,
      faction:Faction.business, profession:Profession.construction),

    // ===== 教师 =====
    CardData(id:'t1', name:'助教', cost:2, attack:1, health:4,
      keywords:[Keyword.taunt], description:'嘲讽', rarity:Rarity.common,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.business, profession:Profession.teacher),
    CardData(id:'t2', name:'教授', cost:6, attack:3, health:6,
      keywords:[Keyword.battlecry], description:'战吼：抽2张牌', rarity:Rarity.epic,
      battlecryEffectId:'draw_2', deathrattleEffectId:null,
      faction:Faction.business, profession:Profession.teacher),

    // ===== 设计师 =====
    CardData(id:'ds1', name:'UI设计师', cost:2, attack:2, health:3,
      keywords:[Keyword.battlecry], description:'战吼：使一个友方随从+1/+1', rarity:Rarity.common,
      battlecryEffectId:'buff_1_1', deathrattleEffectId:null,
      faction:Faction.business, profession:Profession.designer),
    CardData(id:'ds2', name:'UX总监', cost:4, attack:2, health:5,
      keywords:[Keyword.deathrattle], description:'亡语：使所有友方+1/+1', rarity:Rarity.epic,
      battlecryEffectId:null, deathrattleEffectId:'buff_all_1_1',
      faction:Faction.business, profession:Profession.designer),

    // ===== 企业高管 =====
    CardData(id:'e1', name:'部门经理', cost:3, attack:2, health:3,
      keywords:[Keyword.stealth], description:'潜行', rarity:Rarity.common,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.business, profession:Profession.executive),
    CardData(id:'e2', name:'CEO', cost:8, attack:6, health:8,
      keywords:[Keyword.battlecry], description:'战吼：召唤3个学生', rarity:Rarity.legendary,
      battlecryEffectId:'summon_3_student', deathrattleEffectId:null,
      faction:Faction.business, profession:Profession.executive),

    // ===== 军人 =====
    CardData(id:'s1', name:'列兵', cost:2, attack:2, health:3,
      keywords:[Keyword.taunt], description:'嘲讽', rarity:Rarity.common,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.business, profession:Profession.soldier),
    CardData(id:'s2', name:'将军', cost:8, attack:7, health:7,
      keywords:[Keyword.taunt, Keyword.divineShield, Keyword.charge], description:'嘲讽，圣盾，冲锋', rarity:Rarity.legendary,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.business, profession:Profession.soldier),

    // ===== 大国工匠 =====
    CardData(id:'cr1', name:'钳工', cost:3, attack:3, health:3,
      keywords:[Keyword.windfury], description:'风怒', rarity:Rarity.rare,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.business, profession:Profession.craftsman),
    CardData(id:'cr2', name:'大国工匠', cost:6, attack:4, health:6,
      keywords:[Keyword.battlecry, Keyword.divineShield], description:'战吼：圣盾', rarity:Rarity.legendary,
      battlecryEffectId:'divine_shield_self', deathrattleEffectId:null,
      faction:Faction.business, profession:Profession.craftsman),

    // ===== 学生 =====
    CardData(id:'st1', name:'优秀学生', cost:1, attack:1, health:1,
      keywords:[Keyword.charge], description:'冲锋', rarity:Rarity.common,
      battlecryEffectId:null, deathrattleEffectId:null,
      faction:Faction.civilian, profession:Profession.student),
    CardData(id:'st2', name:'学霸', cost:3, attack:2, health:3,
      keywords:[Keyword.battlecry], description:'战吼：敌方失去1个法力水晶', rarity:Rarity.rare,
      battlecryEffectId:'enemy_mana_minus_1', deathrattleEffectId:null,
      faction:Faction.civilian, profession:Profession.student),
  ];

  static CardData? findById(String id) {
    try { return cards.firstWhere((c) => c.id == id); } catch (_) { return null; }
  }

  static List<CardData> byProfession(Profession p) => cards.where((c) => c.profession == p).toList();
}
