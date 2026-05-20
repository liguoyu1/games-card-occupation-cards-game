# PROJECT.md — 职业卡牌 (Occupation Cards)

## 项目概述

**名称**：职业卡牌 (Occupation Cards)  
**类型**：回合制策略卡牌游戏（TCG/CCG）  
**对标**：炉石传说 (Hearthstone)  
**引擎**：Flutter + Flame  
**目标平台**：iOS（首发）、Android、Web

**概述**：以现实职业为题材的卡牌对战游戏，九大职业（外卖骑手、医护护士、程序员等），完整实现炉石传说的法力值、攻击力、生命值、战吼/亡语/嘲讽/冲锋/圣盾等机制。

---

## 当前版本

v0.0 — 规划阶段

---

## 阶段 Roadmap

| # | Phase | 状态 | 说明 |
|---|-------|------|------|
| 0 | 项目初始化 | 待开始 | Flutter + Flame 骨架 |
| 1 | 卡牌数据层 | 待开始 | CardData + Registry |
| 2 | 战斗界面基础 | 待开始 | 战场布局 |
| 3 | 出牌系统 | 待开始 | 出牌/攻击 |
| 4 | 关键词效果 | 待开始 | 战吼/亡语等 |
| 5 | AI 对手 | 待开始 | AI + 回合 |
| 6 | 主菜单 + 完整 UI | 待开始 | 菜单/组卡 |
| 7 | 音效/特效/发布 | 待开始 | VFX + iOS |

---

## 核心文件

- `.planning/DESIGN.md` — 完整设计方案
- `.planning/PLAN.md` — 执行计划

---

## 技术栈

- Flutter + Flame（游戏引擎）
- Riverpod/Provider（状态管理）
- Hive（本地存储）
- Go（后端 AI 服务，待定）

---

## 验证标准

- 每个 Phase 后 `flutter analyze` 0 错误
- 每个 Phase 后 iOS 模拟器构建成功
- 游戏可完成 1 局完整对战
