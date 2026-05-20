# 联网对战 - 设计方案

## 架构概览

```
┌─────────────┐        WebSocket         ┌──────────────┐
│  Flutter     │ ◄──────────────────────► │  Node.js     │
│  Client A    │        JSON Protocol     │  Server      │
└─────────────┘                          │  (Railway)   │
                                         └──────────────┘
┌─────────────┐                                │
│  Client B   │ ◄──────────────────────────────┘
└─────────────┘
```

## 技术栈

| 层     | 技术              | 理由               |
|--------|-------------------|--------------------|
| Server | Node.js + ws      | 轻量、广泛支持      |
| Deploy | Railway           | 免费、简单部署      |
| Client | web_socket_channel | Dart 官方 WebSocket |
| Proto  | JSON              | 简单、可调试        |

## 消息协议

### 客户端 → 服务端

```json
// 匹配
{"type":"match","playerId":"xxx","deck":[...]}

// 出牌
{"type":"play_card","cardIndex":2}

// 攻击随从
{"type":"attack_minion","fromIdx":0,"toIdx":1}

// 攻击英雄
{"type":"attack_hero","fromIdx":0}

// 结束回合
{"type":"end_turn"}
```

### 服务端 → 客户端

```json
// 匹配成功
{"type":"match_found","opponentId":"yyy","goingFirst":true}

// 游戏状态同步
{"type":"game_state","player":{"health":30,...},"enemy":{...}}

// 对方出牌
{"type":"opponent_played_card","card":{"id":"p1","name":"初级码农"}}

// 对方攻击
{"type":"opponent_attacked","fromIdx":0,"toIdx":1,"damage":3}

// 游戏结束
{"type":"game_over","winner":"player","reason":"对手生命值降至0"}
```

## 服务器文件结构

```
server/
├── package.json
├── server.js          # 入口
├── matchmaker.js      # 匹配队列
├── gameRoom.js        # 游戏房间状态
├── gameLogic.js        # 服务端验证
└── protocol.js        # 消息定义
```

## 客户端文件结构

```
lib/
├── network/
│   ├── game_client.dart     # WebSocket 封装
│   └── protocol.dart        # 消息模型
├── screens/
│   └── matchmaking_screen.dart  # 匹配界面
```

## Phase 划分

| Phase | 内容                          | 预计   |
|-------|-------------------------------|--------|
| L1    | 服务器框架 + 匹配系统         | 30min  |
| L2    | 客户端网络层 + 匹配界面       | 30min  |
| L3    | 游戏状态同步 + 回合同步       | 30min  |
| L4    | 联机战斗测试 + Railway 部署   | 15min  |
