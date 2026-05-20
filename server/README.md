# 职业卡牌服务器 (Node.js)

WebSocket 联网对战服务器。

## 运行

```bash
cd server
npm start
# 或
node server.js
```

## WebSocket 接口

连接: `ws://localhost:8080/ws`

### 消息协议

| 客户端 → 服务端 | 说明 |
|---|---|
| `{"type":"match","deck":[...]}` | 匹配（可选 deck） |
| `{"type":"play_card","cardIndex":0}` | 出牌 |
| `{"type":"attack_minion","fromIdx":0,"toIdx":1}` | 攻击随从 |
| `{"type":"attack_hero","fromIdx":0}` | 攻击英雄 |
| `{"type":"end_turn"}` | 结束回合 |

| 服务端 → 客户端 | 说明 |
|---|---|
| `{"type":"match_waiting"}` | 等待匹配 |
| `{"type":"match_found","roomId":"xxx","opponentId":"yyy","goingFirst":true}` | 匹配成功 |
| `{"type":"game_state","state":{...}}` | 游戏状态同步 |
| `{"type":"game_over","winner":"xxx","reason":"..."}` | 游戏结束 |
| `{"type":"action_error","message":"..."}` | 操作错误 |
| `{"type":"opponent_disconnected"}` | 对手断线 |

## Railway 部署

1. `railway init`
2. `railway up`
3. 设置环境变量 `PORT=8080`

Railway 免费额度：500h/月，足够开发测试。