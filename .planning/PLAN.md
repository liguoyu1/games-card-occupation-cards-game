# 职业卡牌 (Occupation Cards) — 执行计划

**项目**：职业卡牌游戏 (Flutter+Flame)  
**目标**：现实职业卡牌体系，对标炉石传说，iOS 首发

---

## 执行概览

| Phase | 任务 | 文件产出 |
|-------|------|----------|
| 0 | 项目初始化 + Flame 骨架 + 视觉系统常量 | 跑通 iOS 构建 |
| 1 | 卡牌数据层 + 精美卡牌渲染组件 | 卡牌展示 demo |
| 2 | 战斗界面 + 战场布局 + 手牌动画 | 精美对战界面 |
| 3 | 出牌/攻击 + 关键词效果系统 | 可交互对战 |
| 4 | AI 对手 + 回合控制 + 胜负结算 | 完整单机对战 |
| 5 | 主菜单 + 牌库构建 + 卡牌图鉴 | 完整前端 |
| 6 | 音效 + 全部粒子特效 + 视觉打磨 | 精品化 |
| 7 | iOS/Android/Web 构建发布 | 三端发布 |

---

## 详细执行

### Phase 0: 项目初始化 + Flame 骨架 + 视觉常量

**目标**: Flutter + Flame 项目跑通 iOS 构建，定义全局视觉常量

**任务**:
0.1 `flutter create` + 添加 flame/flame_audio 依赖
0.2 创建 `lib/game/constants.dart` — 所有视觉常量（配色/尺寸/字体/阴影）
0.3 创建 `lib/game/game.dart` — 空 FlameGame 骨架
0.4 配置 pubspec.yaml 字体 + 资源路径
0.5 验证: `flutter analyze` + `flutter build ios --simulator`

---

### Phase 1: 卡牌数据层 + 精美渲染

**目标**: 卡牌数据显示在 Flame 世界中，外观精美

**任务**:
1.1 `lib/data/card_data.dart` — CardData 数据模型
1.2 `lib/data/keyword.dart` — 关键词枚举 + 稀有度枚举
1.3 `lib/data/profession.dart` — 职业/派系枚举
1.4 `lib/data/card_registry.dart` — 单例注册表
1.5 `lib/data/all_cards.dart` — 13 张核心卡牌数据
1.6 `lib/game/components/card_component.dart` — **精美卡牌渲染组件**
   - 分层绘制（法力水晶/插画区/名称栏/关键词标签/攻击生命）
   - 稀有度配色（普通/稀有/史诗/传说底板不同）
   - 双线描边 + 金属铆钉装饰
   - Hover 放大 1.16× + 上浮 6px + 阴影
1.7 demo 场景：横向排列 5 张不同稀有度卡牌
1.8 验证: iOS 构建

---

### Phase 2: 战斗界面 + 战场布局 + 手牌动画

**目标**: 实现精美战斗界面，卡牌在手牌/战场/牌库之间流转

**任务**:
2.1 `lib/game/components/hero_display.dart` — 英雄头像组件（含生命/护甲圆环）
2.2 `lib/game/components/mana_bar.dart` — 法力水晶发光球体 Bar
2.3 `lib/game/components/board_area.dart` — 战场区域（最多 7 随从槽）
2.4 `lib/game/components/hand_area.dart` — 手牌区（弧形排列, 超过 7 张可滑动）
2.5 `lib/game/components/deck_component.dart` — 牌库立方体
2.6 集成所有组件到战斗场景
2.7 手牌 Hover 动画（悬浮上浮 + 放大）
2.8 验证: iOS 构建

---

### Phase 3: 出牌 + 攻击 + 关键词效果系统

**目标**: 实现完整交互对战流程

**任务**:
3.1 出牌拖拽系统（手牌 → 战场随从槽）
3.2 `lib/game/systems/mana_system.dart` — 法力消耗/恢复
3.3 `lib/game/systems/combat_system.dart` — 攻击逻辑 + 伤害计算
3.4 `lib/game/systems/card_effect_system.dart` — 关键词效果引擎
3.5 战吼/冲锋/圣盾 效果实现
3.6 亡语效果实现
3.7 嘲讽机制（须先攻击嘲讽目标）
3.8 验证: 可出牌 → 攻击 → 关键词触发

---

### Phase 4: AI 对手 + 回合控制 + 胜负结算

**目标**: 可与 AI 完成完整一局对战

**任务**:
4.1 `lib/game/systems/turn_controller.dart` — 回合切换/抽牌/法力水晶
4.2 `lib/game/systems/ai_controller.dart` — AI 决策（简单贪心）
4.3 回合开始/结束动效
4.4 胜负判定 + 结算界面动画
4.5 验证: AI 可完成完整对战流程

---

### Phase 5: 主菜单 + 牌库构建 + 卡牌图鉴

**目标**: 完整游戏前端

**任务**:
5.1 `lib/screens/home_screen.dart` — 精美主菜单（含星云粒子背景）
5.2 `lib/screens/deck_builder_screen.dart` — 牌库构建（拖拽组卡 + 法力曲线）
5.3 `lib/screens/card_collection_screen.dart` — 卡牌图鉴（网格 + 筛选）
5.4 `lib/screens/battle_screen.dart` — 战斗界面嵌 FlameGame
5.5 `lib/services/storage_service.dart` — 本地持久化（卡组/收藏进度）
5.6 所有屏幕间路由动效
5.7 验证: 菜单 → 组卡 → 对战 → 完整循环

---

### Phase 6: 音效 + 全部粒子特效 + 视觉打磨

**目标**: 精品化，不输商业品质

**任务**:
6.1 Python 合成 11 种音效 WAV
6.2 `lib/game/audio/sound_manager.dart` — 音效管理
6.3 `lib/game/components/damage_number.dart` — 伤害/治疗跳字
6.4 `lib/game/components/particle_effects.dart` — 全部粒子特效
6.5 卡牌入场/死亡/战吼动画
6.6 英雄受伤/护甲缓冲动画
6.7 验证: 所有交互有视觉/听觉反馈

---

### Phase 7: iOS/Android/Web 三端发布

**目标**: 正式发布

**任务**:
7.1 生成游戏图标（PIL 真彩色）
7.2 iOS 配置（Info.plist/BundleID/图标）
7.3 iOS 构建 + 模拟器测试
7.4 Android APK 构建
7.5 Web 构建
7.6 验证: 三端可运行

---

## 总体验证

每个 Phase 完成后必须验证：

```bash
cd /Users/guoyuli/Documents/code_s/card_game
flutter analyze 2>&1 | grep -E "(error|warning|found)"
# 必须: 0 错误, 0 警告
flutter build ios --simulator --no-codesign 2>&1 | tail -3
# 必须: ✓ Built build/ios/iphonesimulator/Runner.app
```

成功验证后同步飞书：
- Phase 名称
- 完成项
- 下一步

---

## UI 品质承诺

所有 Phase 均遵循 DESIGN.md 中的精品化视觉规范：
- 深空商务风配色（#0A0E27 主背景）
- 每张卡牌：双线描边 + 金属质感 + 稀有度光效
- 所有交互：动效先行，用户操作必须有视觉/听觉反馈
- 法力水晶：发光球体，非简单图标
- 战斗界面：星云粒子背景，精细的阴影层级

---

*本计划共 7 个 Phase，每 Phase 需验证 iOS 构建通过*