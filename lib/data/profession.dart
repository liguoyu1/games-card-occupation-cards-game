// ============================================================
// 职业枚举 + 派系枚举
// ============================================================

// 派系
enum Faction {
  civilian,  // 平民
  government, // 公职
  technical, // 技艺
  business,  // 商界
}

extension FactionExtension on Faction {
  String get nameCn {
    switch (this) {
      case Faction.civilian:   return '平民';
      case Faction.government: return '公职';
      case Faction.technical:  return '技艺';
      case Faction.business:   return '商界';
    }
  }
}

// 职业
enum Profession {
  deliveryRider,  // 外卖骑手
  cashier,         // 超市收银员
  mechanic,        // 汽修师傅
  nurse,           // 医护护士
  construction,    // 建筑工人
  teacher,         // 人民教师
  programmer,      // 程序员
  police,          // 警察警员
  chef,            // 厨师大厨
  firefighter,     // 消防员
  designer,        // 设计师
  executive,       // 企业高管
  doctor,          // 医生主任
  soldier,         // 军人战士
  craftsman,       // 大国工匠
  student,         // 在校学生
}

extension ProfessionExtension on Profession {
  String get nameCn {
    switch (this) {
      case Profession.deliveryRider:  return '外卖骑手';
      case Profession.cashier:        return '超市收银员';
      case Profession.mechanic:       return '汽修师傅';
      case Profession.nurse:           return '医护护士';
      case Profession.construction:    return '建筑工人';
      case Profession.teacher:         return '人民教师';
      case Profession.programmer:      return '程序员';
      case Profession.police:          return '警察警员';
      case Profession.chef:            return '厨师大厨';
      case Profession.firefighter:      return '消防员';
      case Profession.designer:        return '设计师';
      case Profession.executive:       return '企业高管';
      case Profession.doctor:          return '医生主任';
      case Profession.soldier:         return '军人战士';
      case Profession.craftsman:       return '大国工匠';
      case Profession.student:         return '在校学生';
    }
  }

  /// 该职业所属派系
  Faction get faction {
    switch (this) {
      case Profession.deliveryRider:
      case Profession.cashier:
      case Profession.nurse:
      case Profession.student:
        return Faction.civilian;  // 平民
      case Profession.police:
      case Profession.firefighter:
        return Faction.government; // 公职
      case Profession.mechanic:
      case Profession.chef:
      case Profession.programmer:
        return Faction.technical; // 技艺
      case Profession.construction:
      case Profession.teacher:
      case Profession.designer:
      case Profession.executive:
      case Profession.doctor:
      case Profession.soldier:
      case Profession.craftsman:
        return Faction.business;  // 商界
    }
  }
}
