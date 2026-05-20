# 职业卡牌 (Occupation Cards)

一款基于 Flutter + Flame 引擎开发的集换式卡牌游戏（CCG），支持 iOS/Android/Web 三平台。

## 游戏特色

- **32 张卡牌**：16 种职业，每种 2 张，含 4 张传说卡
- **8 种关键词**：冲锋、嘲讽、圣盾、战吼、亡语、风怒、冻结、潜行
- **完整战斗系统**：出牌、攻击、回合管理、AI 对手
- **精美 UI**：深空商务风（#0A0E27 主色），稀有度发光，粒子背景
- **跨平台**：iOS/Android/Web（Flame 固定 1280×720 世界坐标系）

## 项目结构

```
lib/
├── main.dart                 # 入口
├── game/
│   ├── battle_game.dart      # 战斗界面 Game
│   ├── game.dart             # 卡牌展示 Demo
│   ├── constants.dart        # 全量视觉常量
│   ├── audio/
│   │   └── audio_manager.dart # 音效/震动
│   ├── components/
│   │   ├── card_component.dart        # 卡牌渲染
│   │   ├── minion_card_component.dart # 战场随从
│   │   ├── mana_crystal_component.dart# 六边形法力水晶
│   │   └── damage_number_component.dart# 伤害飘字
│   └── systems/
│       ├── battle_system.dart         # 战斗系统
│       ├── ai_system.dart             # AI 对手 + 回合管理
│       └── keyword_effect_system.dart # 关键词效果
├── data/
│   ├── card_data.dart       # 卡牌数据模型
│   ├── all_cards.dart       # 32 张卡牌
│   ├── card_registry.dart   # 卡牌注册表
│   ├── keyword.dart         # 关键词枚举
│   └── profession.dart      # 职业 + 派系枚举
├── models/
│   ├── player_state.dart    # 玩家状态
│   └── minion_instance.dart # 随从实例
└── screens/
    ├── main_menu_screen.dart   # 主菜单
    └── collection_screen.dart  # 牌库图鉴
```

## 构建

### iOS

```bash
flutter pub get
flutter build ios --simulator --no-codesign
```

### Android

```bash
flutter build apk --debug
```

## 技术栈

- Flutter 3.11+
- Flame 1.37+
- Dart 3.0+

## 版本历史

- v1.0.0 (2026-05-20): 初始版本，32 张卡牌，完整战斗系统
