package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/google/uuid"
	"nhooyr.io/websocket"
	"nhooyr.io/websocket/wsjson"
)

// ===== 全局类型 =====

type Message struct {
	Type    string `json:"type"`
	Deck    []CardDef `json:"deck,omitempty"`
	CardIndex int `json:"cardIndex,omitempty"`
	FromIdx int `json:"fromIdx,omitempty"`
	ToIdx   int `json:"toIdx,omitempty"`
}

type CardDef struct {
	ID         string   `json:"id"`
	Name       string   `json:"name"`
	Cost       int      `json:"cost"`
	Attack     int      `json:"attack"`
	Health     int      `json:"health"`
	Keywords   []string `json:"keywords"`
	Profession string   `json:"profession"`
}

// ===== 服务端入口 =====

type PlayerConn struct {
	ID     string
	Conn   *websocket.Conn
	RoomID string
}

var (
	conns   = &sync.Map{} // playerID -> *PlayerConn
	rooms   = &sync.Map{} // roomID -> *GameRoom
	matches = &sync.Map{} // playerID -> string (roomID)
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", rootHandler)
	http.HandleFunc("/ws", wsHandler)
	http.HandleFunc("/health", healthHandler)

	log.Printf("🎴 职业卡牌服务器启动 :%s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "职业卡牌联网对战服务器 v1.0\n用法: ws://host/ws")
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(200)
	fmt.Fprint(w, "ok")
}

// ===== WebSocket 处理 =====

func wsHandler(w http.ResponseWriter, r *http.Request) {
	conn, err := websocket.Accept(w, r, &websocket.AcceptOptions{})
	if err != nil {
		log.Printf("[ERR] WebSocket 接受失败: %v", err)
		return
	}

	playerID := uuid.New().String()
	playerConn := &PlayerConn{ID: playerID, Conn: conn}
	conns.Store(playerID, playerConn)
	log.Printf("[+] 玩家连接: %s", playerID[:8])

	ctx := r.Context()
	for {
		_, data, err := conn.Read(ctx)
		if err != nil {
			if err == io.EOF || websocket.CloseStatus(err) != -1 {
				log.Printf("[-] 玩家断开: %s", playerID[:8])
			} else {
				log.Printf("[ERR] 读取失败 %s: %v", playerID[:8], err)
			}
			handleDisconnect(playerID)
			break
		}

		var msg Message
		if err := json.Unmarshal(data, &msg); err != nil {
			sendError(conn, "无效消息格式")
			continue
		}
		handleMessage(playerConn, &msg)
	}
}

// ===== 消息处理 =====

func handleMessage(p *PlayerConn, msg *Message) {
	switch msg.Type {
	case "match":
		handleMatch(p, msg)
	case "play_card":
		handlePlayCard(p, msg)
	case "attack_minion":
		handleAttackMinion(p, msg)
	case "attack_hero":
		handleAttackHero(p, msg)
	case "end_turn":
		handleEndTurn(p)
	case "ping":
		sendJSON(p.Conn, map[string]string{"type": "pong"})
	default:
		sendError(p.Conn, fmt.Sprintf("未知消息: %s", msg.Type))
	}
}

// ===== 匹配 =====

var matchQueue []*MatchRequest
var matchLock sync.Mutex

type MatchRequest struct {
	PlayerID string
	WS       *websocket.Conn
	Deck     []CardDef
}

func handleMatch(p *PlayerConn, msg *Message) {
	matchLock.Lock()
	defer matchLock.Unlock()

	// 检查是否已在队列
	for _, r := range matchQueue {
		if r.PlayerID == p.ID {
			return
		}
	}

	req := &MatchRequest{PlayerID: p.ID, WS: p.Conn, Deck: msg.Deck}
	matchQueue = append(matchQueue, req)
	sendJSON(p.Conn, map[string]string{"type": "match_waiting"})
	log.Printf("[MQ] 队列人数: %d", len(matchQueue))

	if len(matchQueue) >= 2 {
		p1 := matchQueue[0]
		p2 := matchQueue[1]
		matchQueue = matchQueue[2:]

		room := NewGameRoom(p1, p2)
		rooms.Store(room.ID, room)
		matches.Store(p1.PlayerID, room.ID)
		matches.Store(p2.PlayerID, room.ID)

		// 通知双方
		sendJSON(p1.WS, map[string]interface{}{
			"type":        "match_found",
			"roomId":      room.ID,
			"opponentId":  p2.PlayerID,
			"goingFirst":  true,
		})
		sendJSON(p2.WS, map[string]interface{}{
			"type":        "match_found",
			"roomId":      room.ID,
			"opponentId":  p1.PlayerID,
			"goingFirst":  false,
		})
		log.Printf("[ROOM] %s 匹配完成", room.ID)
	}
}

// ===== 游戏操作 =====

func handlePlayCard(p *PlayerConn, msg *Message) {
	roomID, ok := matches.Load(p.ID)
	if !ok {
		sendError(p.Conn, "不在游戏中")
		return
	}
	room, _ := rooms.Load(roomID.(string))

	result := room.(*GameRoom).PlayCard(p.ID, msg.CardIndex)
	if result.Err != nil {
		sendError(p.Conn, result.Err.Error())
		return
	}
	broadcastRoom(room.(*GameRoom), p.ID)
}

func handleAttackMinion(p *PlayerConn, msg *Message) {
	roomID, ok := matches.Load(p.ID)
	if !ok {
		sendError(p.Conn, "不在游戏中")
		return
	}
	room, _ := rooms.Load(roomID.(string))

	result := room.(*GameRoom).AttackMinion(p.ID, msg.FromIdx, msg.ToIdx)
	if result.Err != nil {
		sendError(p.Conn, result.Err.Error())
		return
	}
	broadcastRoom(room.(*GameRoom), p.ID)

	if result.GameOver {
		broadcastGameOver(room.(*GameRoom), result.Winner)
	}
}

func handleAttackHero(p *PlayerConn, msg *Message) {
	roomID, ok := matches.Load(p.ID)
	if !ok {
		sendError(p.Conn, "不在游戏中")
		return
	}
	room, _ := rooms.Load(roomID.(string))

	result := room.(*GameRoom).AttackHero(p.ID, msg.FromIdx)
	if result.Err != nil {
		sendError(p.Conn, result.Err.Error())
		return
	}
	broadcastRoom(room.(*GameRoom), p.ID)

	if result.GameOver {
		broadcastGameOver(room.(*GameRoom), result.Winner)
	}
}

func handleEndTurn(p *PlayerConn) {
	roomID, ok := matches.Load(p.ID)
	if !ok {
		sendError(p.Conn, "不在游戏中")
		return
	}
	room, _ := rooms.Load(roomID.(string))

	result := room.(*GameRoom).EndTurn(p.ID)
	if result.Err != nil {
		sendError(p.Conn, result.Err.Error())
		return
	}
	broadcastRoom(room.(*GameRoom), p.ID)
}

// ===== 辅助 =====

func sendError(conn *websocket.Conn, msg string) {
	sendJSON(conn, map[string]string{"type": "action_error", "message": msg})
}

func sendJSON(conn *websocket.Conn, v interface{}) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	wsjson.Write(ctx, conn, v)
}

func broadcastRoom(room *GameRoom, excludePlayerID string) {
	state := room.Serialize(excludePlayerID)
	for _, ps := range room.Players {
		if ps.PlayerID != excludePlayerID {
			sendJSON(ps.WS.Conn, map[string]interface{}{
				"type":  "game_state",
				"state": state,
			})
		}
	}
	// 发送给自己确认
	for _, ps := range room.Players {
		if ps.PlayerID == excludePlayerID {
			sendJSON(ps.WS.Conn, map[string]interface{}{
				"type":  "game_state",
				"state": state,
			})
			break
		}
	}
}

func broadcastGameOver(room *GameRoom, winner string) {
	for _, ps := range room.Players {
		sendJSON(ps.WS.Conn, map[string]interface{}{
			"type":   "game_over",
			"winner": winner,
		})
	}
	rooms.Delete(room.ID)
}

func handleDisconnect(playerID string) {
	conns.Delete(playerID)

	// 从匹配队列移除
	matchLock.Lock()
	newQueue := make([]*MatchRequest, 0)
	for _, r := range matchQueue {
		if r.PlayerID != playerID {
			newQueue = append(newQueue, r)
		}
	}
	matchQueue = newQueue
	matchLock.Unlock()

	// 通知对手
	if roomID, ok := matches.Load(playerID); ok {
		matches.Delete(playerID)
		if room, ok := rooms.Load(roomID.(string)); ok {
			r := room.(*GameRoom)
			if opp := r.GetOpponent(playerID); opp != nil {
				sendJSON(opp.WS.Conn, map[string]string{"type": "opponent_disconnected"})
			}
			rooms.Delete(roomID.(string))
		}
	}
}
