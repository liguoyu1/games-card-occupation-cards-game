import 'dart:ui';

/// ============================================================
/// 职业卡牌 - 全局视觉常量系统
/// 深空商务风配色 + 精细尺寸体系
/// ============================================================

// ==================== 世界坐标系 ====================
class GameDimensions {
  static const double worldWidth = 1280.0;
  static const double worldHeight = 720.0;

  // 战场区域 Y 坐标
  static const double enemyMinionAreaY = 120.0;
  static const double enemyMinionAreaH = 120.0;
  static const double enemyHandAreaY = 250.0;
  static const double enemyHandAreaH = 80.0;

  static const double dividerY = 360.0;

  static const double myHandAreaY = 420.0;
  static const double myHandAreaH = 80.0;
  static const double myMinionAreaY = 510.0;
  static const double myMinionAreaH = 120.0;

  // 英雄区
  static const double enemyHeroY = 30.0;
  static const double myHeroY = 630.0;

  // 随从槽
  static const double minionSlotWidth = 110.0;
  static const double maxMinions = 7;
  static const double minionAreaStartX = 80.0;
}

// ==================== 卡牌尺寸 ====================
class CardSizes {
  // 手牌尺寸
  static const double handCardW = 120.0;
  static const double handCardH = 168.0;

  // 悬浮放大
  static const double hoverScale = 1.16;
  static const double hoverCardW = handCardW * hoverScale;
  static const double hoverCardH = handCardH * hoverScale;

  // 战场随从尺寸
  static const double minionCardW = 100.0;
  static const double minionCardH = 140.0;

  // 详情卡尺寸
  static const double detailCardW = 280.0;
  static const double detailCardH = 392.0;
}

// ==================== 配色方案 - 深空商务风 ====================
class AppColors {
  // 主背景
  static const Color primaryBg = Color(0xFF0A0E27);    // 深海夜空蓝
  static const Color secondaryBg = Color(0xFF141831);  // 深蓝灰面板

  // 强调色
  static const Color accent = Color(0xFFFFB800);        // 琥珀金
  static const Color success = Color(0xFF00E676);       // 荧光绿
  static const Color danger = Color(0xFFFF3D00);        // 烈焰红
  static const Color freeze = Color(0xFF00B4D8);        // 冰川蓝
  static const Color divineShield = Color(0xFFFFD600);   // 圣光金

  // 文字色
  static const Color textPrimary = Color(0xFFE8EAF0);   // 柔白
  static const Color textSecondary = Color(0xFF8892B0); // 灰蓝
  static const Color textDisabled = Color(0xFF4A5270);  // 暗灰

  // 卡牌边框
  static const Color cardBorderOuter = Color(0xFF1A1F35);
  static const Color cardBorderInner = Color(0xFF3A4070);

  // 法力水晶
  static const Color manaFull = Color(0xFF4488FF);
  static const Color manaEmpty = Color(0xFF2A3050);

  // 攻击力/生命值
  static const Color attackColor = Color(0xFFFF4444);
  static const Color healthColor = Color(0xFF44CC44);
  static const Color healthLow = Color(0xFFFF4444);     // 低血量警告

  // 卡牌稀有度底板
  static const Color rarityCommon = Color(0xFF2C3E50);
  static const Color rarityRare = Color(0xFF1A3A5C);
  static const Color rarityEpic = Color(0xFF3D1A6B);
  static const Color rarityLegendary = Color(0xFF4A3500);
}

// ==================== 职业配色 ====================
class ProfessionColors {
  static const Color deliveryRider = Color(0xFFFFD700);   // 黄色
  static const Color cashier = Color(0xFF4CAF50);         // 绿色
  static const Color mechanic = Color(0xFF607D8B);        // 深灰
  static const Color nurse = Color(0xFFE53935);           // 红色
  static const Color construction = Color(0xFFFF5722);     // 橙色
  static const Color teacher = Color(0xFF2196F3);         // 蓝色
  static const Color programmer = Color(0xFF00BCD4);     // 深绿
  static const Color police = Color(0xFF1A237E);          // 深蓝
  static const Color chef = Color(0xFF795548);            // 棕色
}

// ==================== 阴影层级 ====================
class Shadows {
  static List<Shadow> cardHover = [
    const Shadow(
      color: Color(0x40000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static List<Shadow> cardBase = [
    const Shadow(
      color: Color(0x25000000),
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
  ];

  static List<Shadow> panelCard = [
    const Shadow(
      color: Color(0x25000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static List<Shadow> buttonPressed = [
    const Shadow(
      color: Color(0x20000000),
      blurRadius: 4,
      offset: Offset(0, 0),
    ),
  ];
}

// ==================== 动画时长 ====================
class AnimDurations {
  static const Duration hoverScale = Duration(milliseconds: 200);
  static const Duration cardPlay = Duration(milliseconds: 400);
  static const Duration cardAttack = Duration(milliseconds: 300);
  static const Duration cardHurt = Duration(milliseconds: 150);
  static const Duration cardDeath = Duration(milliseconds: 600);
  static const Duration cardDraw = Duration(milliseconds: 350);
  static const Duration battlecry = Duration(milliseconds: 500);
  static const Duration damageNumber = Duration(milliseconds: 800);
}

// ==================== 游戏数值常量 ====================
class GameConfig {
  static const int maxMana = 10;
  static const int startHealth = 30;
  static const int maxHandSize = 10;
  static const int maxMinions = 7;
  static const int deckSize = 30;
  static const int heroSkillCost = 2;
}
