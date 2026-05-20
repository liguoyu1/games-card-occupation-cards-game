const WebSocket = require('ws');
const http = require('http');
const crypto = require('crypto');

const PORT = process.env.PORT || 8080;
const wss = new WebSocket.Server({ noServer: true });

const httpServer = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('ok');
  } else if (req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('职业卡牌服务器 v1.0\n');
  } else {
    res.writeHead(404);
    res.end();
  }
});

httpServer.on('upgrade', (req, socket, head) => {
  if (req.url === '/ws') {
    wss.handleUpgrade(req, socket, head, (ws) => {
      wss.emit('connection', ws, req);
    });
  } else {
    socket.destroy();
  }
});

httpServer.listen(PORT, () => {
  console.log(`🎴 职业卡牌服务器 :${PORT}`);
});

// 全局数据
const matchQueue = [];
const rooms = new Map();
const playerRooms = new Map();

wss.on('connection', (ws) => {
  const playerId = crypto.randomUUID();
  ws.playerId = playerId;
  ws.alive = true;

  console.log(`[+] 玩家: ${playerId.slice(0, 8)}`);

  ws.on('pong', () => { ws.alive = true; });
  ws.on('message', (d) => { try { handle(ws, JSON.parse(d)); } catch (e) { send(ws, { type: 'error', message: '格式错误' }); } });
  ws.on('close', () => handleDisconnect(ws));
  ws.on('error', () => {});
});

// 心跳
setInterval(() => {
  wss.clients.forEach(ws => {
    if (!ws.alive) return ws.terminate();
    ws.alive = false;
    ws.ping();
  });
}, 30000);

// ===== 消息分发 =====

function handle(ws, msg) {
  switch (msg.type) {
    case 'match':       startMatch(ws); break;
    case 'play_card':   act(ws, msg, 'playCard'); break;
    case 'attack_minion': act(ws, msg, 'attackMinion'); break;
    case 'attack_hero':   act(ws, msg, 'attackHero'); break;
    case 'end_turn':      act(ws, msg, 'endTurn'); break;
    case 'ping': send(ws, { type: 'pong' }); break;
    default: send(ws, { type: 'error', message: `未知: ${msg.type}` });
  }
}

// ===== 匹配 =====

function startMatch(ws) {
  if (matchQueue.find(e => e === ws)) return;
  matchQueue.push(ws);
  send(ws, { type: 'match_waiting' });
  console.log(`[MQ] 队列: ${matchQueue.length}`);

  if (matchQueue.length >= 2) {
    const p1 = matchQueue.shift();
    const p2 = matchQueue.shift();
    const room = createRoom(p1, p2);
    rooms.set(room.id, room);
    playerRooms.set(p1.playerId, room.id);
    playerRooms.set(p2.playerId, room.id);

    send(p1, { type: 'match_found', roomId: room.id, opponentId: p2.playerId, goingFirst: true });
    send(p2, { type: 'match_found', roomId: room.id, opponentId: p1.playerId, goingFirst: false });
    console.log(`[ROOM] ${room.id} 匹配完成`);

    // 发送初始状态
    broadcast(room);
  }
}

// ===== 房间 & 游戏状态 =====

function createRoom(p1, p2) {
  return {
    id: crypto.randomUUID().slice(0, 8),
    turn: 1,
    activeIdx: 0,
    players: [
      { playerId: p1.playerId, ws: p1, health: 30, maxMana: 0, mana: 0, hand: [], deck: makeDeck(), minions: [] },
      { playerId: p2.playerId, ws: p2, health: 30, maxMana: 0, mana: 0, hand: [], deck: makeDeck(), minions: [] },
    ],
    gameOver: false,
    winner: '',
  };
}

function makeDeck() {
  // 简化：4 张固定卡牌用于测试
  return [
    { id: 'st1', name: '学生', cost: 1, attack: 1, health: 1, keywords: [], prof: 'student' },
    { id: 'p1', name: '程序员', cost: 2, attack: 3, health: 2, keywords: ['charge'], prof: 'programmer' },
    { id: 'g1', name: '巡警', cost: 2, attack: 2, health: 2, keywords: ['freeze'], prof: 'police' },
    { id: 's1', name: '列兵', cost: 2, attack: 2, health: 3, keywords: ['taunt'], prof: 'soldier' },
    { id: 'f1', name: '消防兵', cost: 2, attack: 2, health: 3, keywords: ['taunt'], prof: 'firefighter' },
    { id: 'r1', name: '骑手', cost: 1, attack: 2, health: 1, keywords: ['charge'], prof: 'delivery' },
    { id: 'm1', name: '汽修工', cost: 2, attack: 2, health: 3, keywords: ['divineShield'], prof: 'mechanic' },
    { id: 'e1', name: '经理', cost: 3, attack: 2, health: 3, keywords: ['stealth'], prof: 'executive' },
  ].sort(() => Math.random() - 0.5);
}

function initRoom(room) {
  for (const p of room.players) {
    p.deck = makeDeck();
    p.hand = p.deck.slice(0, 4);
    p.deck = p.deck.slice(4);
    p.health = 30;
    p.maxMana = 0;
    p.mana = 0;
    p.minions = [];
  }
  room.activeIdx = 0;
  room.turn = 1;
  room.gameOver = false;
  room.winner = '';
  startTurn(room, room.players[0]);
}

function startTurn(room, p) {
  if (p.maxMana < 10) p.maxMana++;
  p.mana = p.maxMana;
  // 抽牌
  if (p.deck.length > 0) {
    p.hand.push(p.deck.shift());
  }
}

function endTurn(room, idx) {
  // 重置攻击状态
  for (const m of room.players[idx].minions) {
    m.hasAttacked = false;
    m.canAttack = m.keywords.includes('charge') || m.keywords.includes('windfury');
  }
  // 切换回合
  const nextIdx = 1 - idx;
  room.activeIdx = nextIdx;
  room.turn++;
  startTurn(room, room.players[nextIdx]);
}

// ===== 游戏操作 =====

function playCard(room, idx, cardIdx) {
  const p = room.players[idx];
  if (cardIdx < 0 || cardIdx >= p.hand.length) return { err: '无效卡牌索引' };
  if (p.minions.length >= 7) return { err: '场上已满' };
  const card = p.hand[cardIdx];
  if (card.cost > p.mana) return { err: '法力不足' };

  p.mana -= card.cost;
  p.hand.splice(cardIdx, 1);
  p.minions.push({
    card,
    currentAttack: card.attack,
    currentHealth: card.health,
    maxHealth: card.health,
    keywords: [...(card.keywords || [])],
    hasTaunt: (card.keywords || []).includes('taunt'),
    hasDivineShield: (card.keywords || []).includes('divineShield'),
    isFrozen: false,
    canAttack: (card.keywords || []).includes('charge'),
    hasAttacked: false,
  });

  return { err: null };
}

function attackMinion(room, idx, fromIdx, toIdx) {
  const p = room.players[idx];
  const opp = room.players[1 - idx];
  if (fromIdx < 0 || fromIdx >= p.minions.length) return { err: '无效攻击者' };
  if (toIdx < 0 || toIdx >= opp.minions.length) return { err: '无效目标' };
  const atk = p.minions[fromIdx];
  const def = opp.minions[toIdx];

  if (atk.hasAttacked) return { err: '已攻击过' };
  if (atk.isFrozen) return { err: '冻结中' };

  // 嘲讽检查
  const tauntExists = opp.minions.some(m => m.hasTaunt);
  if (tauntExists && !def.hasTaunt) return { err: '必须先攻击嘲讽随从' };

  atk.hasAttacked = true;

  // 攻击
  if (def.hasDivineShield) { def.hasDivineShield = false; }
  else { def.currentHealth -= atk.currentAttack; }

  if (atk.hasDivineShield) { atk.hasDivineShield = false; }
  else { atk.currentHealth -= def.currentAttack; }

  // 冻结
  if (atk.keywords.includes('freeze')) { def.isFrozen = true; }

  // 清理死亡
  cleanupMinions(p);
  cleanupMinions(opp);

  // 胜负检查
  return checkGameOver(room);
}

function attackHero(room, idx, fromIdx) {
  const p = room.players[idx];
  const opp = room.players[1 - idx];
  if (fromIdx < 0 || fromIdx >= p.minions.length) return { err: '无效攻击者' };
  const atk = p.minions[fromIdx];
  if (atk.hasAttacked) return { err: '已攻击过' };

  atk.hasAttacked = true;
  opp.health -= atk.currentAttack;

  return checkGameOver(room);
}

function checkGameOver(room) {
  for (let i = 0; i < 2; i++) {
    if (room.players[i].health <= 0) {
      room.gameOver = true;
      room.winner = room.players[1 - i].playerId;
      return { err: null, gameOver: true, winner: room.winner };
    }
  }
  return { err: null, gameOver: false };
}

function cleanupMinions(p) {
  p.minions = p.minions.filter(m => m.currentHealth > 0);
}

// ===== 游戏动作路由 =====

function act(ws, msg, action) {
  const roomId = playerRooms.get(ws.playerId);
  if (!roomId) return send(ws, { type: 'error', message: '不在游戏中' });
  const room = rooms.get(roomId);
  if (!room) return send(ws, { type: 'error', message: '房间已关闭' });

  const idx = room.players[0].playerId === ws.playerId ? 0 : 1;
  if (room.activeIdx !== idx) return send(ws, { type: 'error', message: '不是你的回合' });

  let result;
  if (action === 'playCard') result = playCard(room, idx, msg.cardIndex);
  else if (action === 'attackMinion') result = attackMinion(room, idx, msg.fromIdx, msg.toIdx);
  else if (action === 'attackHero') result = attackHero(room, idx, msg.fromIdx);
  else if (action === 'endTurn') { endTurn(room, idx); result = { err: null, gameOver: false }; }
  else result = { err: '未知' };

  if (result && result.err) return send(ws, { type: 'action_error', message: result.err });

  broadcast(room);

  if (result && result.gameOver) {
    for (const p of room.players) {
      send(p.ws, { type: 'game_over', winner: result.winner, reason: '对手生命值降至0' });
    }
    rooms.delete(roomId);
    playerRooms.delete(room.players[0].playerId);
    playerRooms.delete(room.players[1].playerId);
  }
}

// ===== 广播 =====

function broadcast(room) {
  for (const p of room.players) {
    const opp = room.players[1 - room.players.indexOf(p)];
    const state = serialize(p, opp);
    send(p.ws, { type: 'game_state', state });
  }
}

function serialize(p, opp) {
  return {
    activePlayer: p.playerId,
    playerView: {
      playerId: p.playerId,
      health: p.health,
      maxMana: p.maxMana,
      currentMana: p.mana,
      handCount: p.hand.length,
      deckCount: p.deck.length,
      hand: p.hand.map(c => ({ id: c.id, name: c.name, cost: c.cost, attack: c.attack, health: c.health, keywords: c.keywords })),
      minions: p.minions.map(m => ({
        card: m.card, currentAttack: m.currentAttack, currentHealth: m.currentHealth,
        maxHealth: m.maxHealth, hasTaunt: m.hasTaunt, hasDivineShield: m.hasDivineShield, isFrozen: m.isFrozen,
      })),
    },
    enemyView: {
      playerId: opp.playerId,
      health: opp.health,
      handCount: opp.hand.length,
      deckCount: opp.deck.length,
      minions: opp.minions.map(m => ({
        card: { id: m.card.id, name: m.card.name, cost: m.card.cost, attack: m.card.attack, health: m.card.health, keywords: m.card.keywords },
        currentAttack: m.currentAttack, currentHealth: m.currentHealth,
        maxHealth: m.maxHealth, hasTaunt: m.hasTaunt, hasDivineShield: m.hasDivineShield, isFrozen: m.isFrozen,
      })),
    },
  };
}

// ===== 断线 =====

function handleDisconnect(ws) {
  const idx = matchQueue.indexOf(ws);
  if (idx >= 0) matchQueue.splice(idx, 1);

  const roomId = playerRooms.get(ws.playerId);
  if (roomId) {
    const room = rooms.get(roomId);
    if (room) {
      const opp = room.players[0].ws === ws ? room.players[1] : room.players[0];
      send(opp.ws, { type: 'opponent_disconnected' });
      rooms.delete(roomId);
    }
    playerRooms.delete(ws.playerId);
  }
  console.log(`[-] 断开: ${ws.playerId ? ws.playerId.slice(0, 8) : '?'}`);
}

function send(ws, msg) {
  if (ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(msg));
  }
}
